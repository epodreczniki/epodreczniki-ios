







#import "EPAppleDownloadService.h"
#import "EPURL.h"

@interface EPAppleDownloadService ()

@property (nonatomic, strong) NSURLSessionConfiguration *backgroundConfiguration;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;
@property (nonatomic, strong) NSMutableDictionary *items;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) EPDownloadTextbookProxy *proxy;
@property (nonatomic) BOOL running;
@property (nonatomic) BOOL downloading;

- (void)run;
- (void)runResume;
- (void)resetService;
- (EPDownloadTextbookProxy *)proxyFromDataSource;
- (NSURLSession *)createBackgroundSession;

@end

@implementation EPAppleDownloadService

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {

        self.backgroundQueue = dispatch_queue_create("pl.psnc.download-service", NULL);

        self.items = [NSMutableDictionary new];
        self.running = NO;
        self.downloading = NO;
    }
    return self;
}

- (void)dealloc {
    self.backgroundConfiguration = nil;
    self.backgroundQueue = nil;
    self.downloadTask = nil;
    self.proxy = nil;
}

#pragma mark - Public methods

- (void)startDownloadWithProxy:(EPDownloadTextbookProxy *)proxy {


    if (!self.running) {
        self.running = YES;
        self.proxy = proxy;
        [self run];
    }
}

- (void)cancelDownloadWithProxy:(EPDownloadTextbookProxy *)proxy {


    if (self.running && self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning) {

        if ([self.downloadTask.taskDescription isEqualToString:proxy.downloadID]) {
            [self.downloadTask cancel];
        }
    }
}

- (void)clearCorruptedData {


    NSString *downloadTmpPath = [self.configuration.pathModel pathForDownloadTmp];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:downloadTmpPath]) {
        
        NSArray *directoryContents = [fm contentsOfDirectoryAtPath:downloadTmpPath error:nil];
        for (NSString *path in directoryContents) {
            NSString *fullPath = [downloadTmpPath stringByAppendingPathComponent:path];
            [fm removeItemAtPath:fullPath error:nil];
        }
    }

    NSString *resumeFilePath = [self.configuration.pathModel pathForResumeFile];
    if ([fm fileExistsAtPath:resumeFilePath]) {
        [fm removeItemAtPath:resumeFilePath error:nil];
    }

    EPDownloadTextbookProxy *tmpProxy = nil;
    while (YES) {

        if ([self.dataSource respondsToSelector:@selector(nextProxyObjectForDownloadService:)]) {
            tmpProxy = [self.dataSource nextProxyObjectForDownloadService:self];
        }

        if (!tmpProxy) {
            break;
        }

        [tmpProxy rollback];
    }
}

- (void)resumeDownloadWithProxy:(EPDownloadTextbookProxy *)proxy {

    
    self.running = YES;
    self.proxy = proxy;
    [self runResume];
}

#pragma mark - Private methods

- (void)run {


    dispatch_barrier_async(self.backgroundQueue, ^{

        if (!self.running) {
            return;
        }

        if (!self.proxy) {
            self.proxy = [self proxyFromDataSource];
        }

        if (!self.proxy) {

            self.running = NO;

            
            return;
        }
        
#ifdef DEBUG_DOWNLOAD_LAG
        [NSThread sleepForTimeInterval:DEBUG_DOWNLOAD_LAG];
#endif

        EPUsageUtil *usageUtil = self.configuration.usageUtil;
        BOOL canStore = [usageUtil canStoreFileWithSize:self.proxy.storeCollection.apiSize];
#if DEBUG_LOW_STORAGE_DOWNLOAD
        canStore = NO;
#endif
        if (!canStore) {

            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"No free space avaiable"};
            NSError *error = [NSError errorWithDomain:@"EPDownloadUtilErrorDomain" code:EPErrorCodeNoFreeSpace userInfo:userInfo];
            [self.proxy rollback];
            [self.proxy raiseError:error];

            [self resetService];

            [self run];
            
            return;
        }

        NSURL *url = [EPURL URLWithHost:API_BASE andResource:self.proxy.storeCollection.storeUrl];
#ifdef DEBUG_LARGE_FILE_DOWNLOAD
        url = [NSURL URLWithString:DEBUG_LARGE_FILE_DOWNLOAD];
#endif
#if DEBUG_SERVER_FILE_404
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:@".404"]];
#endif
#if DEBUG_HTTP

#endif

        self.session = [self createBackgroundSession];
        self.downloadTask = [self.session downloadTaskWithURL:url];
        self.downloadTask.taskDescription = self.proxy.downloadID;

        self.downloading = YES;
        [self.downloadTask resume];

        while (self.downloading) {
            [NSThread sleepForTimeInterval:0.5f];
        }

        if (self.session) {
            [self.session invalidateAndCancel];
            self.session = nil;
        }

        [self run];
    });
}

- (void)runResume {


    dispatch_barrier_async(self.backgroundQueue, ^{

        if (!self.running || !self.proxy) {
            self.running = NO;
            return;
        }
        
#if DEBUG_HTTP

#endif

        NSString *path = [self.configuration.pathModel pathForResumeFile];
        NSData *resumeData = [[NSData alloc] initWithContentsOfFile:path];
        if (!resumeData) {
            self.running = NO;
            return;
        }

        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];

        self.session = [self createBackgroundSession];
        self.downloadTask = [self.session downloadTaskWithResumeData:resumeData];
        self.downloadTask.taskDescription = self.proxy.downloadID;

        self.downloading = YES;
        [self.downloadTask resume];

        while (self.downloading) {
            [NSThread sleepForTimeInterval:0.5f];
        }

        if (self.session) {
            [self.session invalidateAndCancel];
            self.session = nil;
        }

        [self run];
    });
}

- (void)resetService {
    self.downloadTask = nil;
    self.downloading = NO;
    self.proxy = nil;
    if (self.session) {
        [self.session invalidateAndCancel];
        self.session = nil;
    }
}

- (EPDownloadTextbookProxy *)proxyFromDataSource {
    
    EPDownloadTextbookProxy *proxy = nil;

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(nextProxyObjectForDownloadService:)]) {
        proxy = [self.dataSource nextProxyObjectForDownloadService:self];
    }
    
    return proxy;
}

- (NSURLSession *)createBackgroundSession {

    if (!self.backgroundConfiguration) {
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            self.backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"pl.psnc.EPAppleDownloadService.BackgroundSession"];
        }
        else {
            self.backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"pl.psnc.EPAppleDownloadService.BackgroundSession"];
        }
        
        self.backgroundConfiguration.timeoutIntervalForRequest = kTimeIntervalForDownloadServiceRequest;
        self.backgroundConfiguration.timeoutIntervalForResource = kTimeIntervalForDownloadServiceResponse;
#if DEBUG_DOWNLOAD_TIMEOUT
        self.backgroundConfiguration.timeoutIntervalForResource = 5;
#endif
    }

    BOOL allowCellular = (self.configuration.settingsModel.allowUsingCellularNetwork == EPSettingsCellularStateTypeAllowed);
    self.backgroundConfiguration.allowsCellularAccess = allowCellular;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.backgroundConfiguration delegate:self delegateQueue:nil];
    
    return session;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {


    [self.proxy updateProgress:1.0f];

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self.delegate respondsToSelector:@selector(downloadService:didDownloadFileAtPath:forProxy:)]) {
            [self.delegate downloadService:self didDownloadFileAtPath:[location path] forProxy:self.proxy];
        }
    });

    [self resetService];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    float progress = (float)((float)totalBytesWritten/(float)totalBytesExpectedToWrite);
    
#if DEBUG_PROGRESS_HIDDEN

#else

#endif

    if (progress == 1.0) {
        return;
    }

    [self.proxy updateProgress:progress];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

    if (error) {


        BOOL triggerError = YES;
        if (error.code == kCFURLErrorCancelled) {
            triggerError = NO;
        }

        if (error.code == kCFURLErrorNotConnectedToInternet) {

            NSString *path = [self.configuration.pathModel pathForResumeFile];

            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            if (resumeData && [resumeData isKindOfClass:[NSData class]]) {

                [resumeData writeToFile:path atomically:YES];

                NSDictionary *userInfo = @{
                    kEPAppleDownloadServiceProxyKey: self.proxy
                };

                error = [NSError errorWithDomain:@"EpodrecznikiApp" code:EPErrorResumePossible userInfo:userInfo];
            }
            else {

                NSFileManager *fm = [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:path]) {
                    error = nil;
                }
            }
        }

        if (triggerError) {
            
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                if ([self.delegate respondsToSelector:@selector(downloadService:didReceivedError:forProxy:)]) {
                    [self.delegate downloadService:self didReceivedError:error forProxy:self.proxy];
                }
            });
        }
    }

    [self resetService];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

@end
