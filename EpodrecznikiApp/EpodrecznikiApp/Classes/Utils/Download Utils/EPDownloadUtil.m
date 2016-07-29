







#import "EPDownloadUtil.h"
#import "EPURL.h"
#import "EPZipArchive.h"
#import "EPDownloadFileUtil.h"

@interface EPDownloadUtil ()

@property (nonatomic, strong) dispatch_queue_t backgroundQueueApi;
@property (nonatomic, strong) dispatch_queue_t backgroundQueueImage;
@property (nonatomic, strong) dispatch_queue_t backgroundQueueTextbook;
@property (nonatomic, copy) NSDate *lastDownloadDataFromAPI;
@property (nonatomic, strong) NSMutableDictionary *textbookProxies;
@property (nonatomic, strong) EPAppleDownloadService *downloadService;

@end

@implementation EPDownloadUtil

@synthesize backgroundQueueApi = _backgroundQueueApi;
@synthesize backgroundQueueImage = _backgroundQueueImage;
@synthesize backgroundQueueTextbook = _backgroundQueueTextbook;

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        _backgroundQueueApi = dispatch_queue_create("pl.psnc.download-api", NULL);
        _backgroundQueueImage = dispatch_queue_create("pl.psnc.download-image", NULL);
        _backgroundQueueTextbook = dispatch_queue_create("pl.psnc.download-textbook", NULL);
        self.textbookProxies = [NSMutableDictionary new];
        self.downloadService = [[EPAppleDownloadService alloc] initWithConfiguration:aConfiguration];
        self.downloadService.dataSource = self;
        self.downloadService.delegate = self;
    }
    return self;
}

- (void)dealloc {
    _backgroundQueueApi = nil;
    _backgroundQueueImage = nil;
    _backgroundQueueTextbook = nil;
    self.lastDownloadDataFromAPI = nil;
    self.downloadService = nil;
}

#pragma mark - EPAppleDownloadServiceDataSource

- (EPDownloadTextbookProxy *)nextProxyObjectForDownloadService:(EPAppleDownloadService *)downloadService {

    EPDownloadTextbookProxy *proxy = [self.configuration.downloadModel nextProxyFromDownloadQueue];
    
    return proxy;
}

- (EPDownloadTextbookProxy *)downloadService:(EPAppleDownloadService *)downloadService proxyObjectForRootID:(NSString *)rootID {

    EPDownloadTextbookProxy *proxy = [self downloadTextbookProxyForRootID:rootID];
    
    return proxy;
}

#pragma mark - EPAppleDownloadServiceDelegate

- (void)downloadService:(EPAppleDownloadService *)downloadService didDownloadFileAtPath:(NSString *)path forProxy:(EPDownloadTextbookProxy *)proxy {
    
    NSString *destinationAbsolutePath = [self.configuration.pathModel absolutePathForExtractingNewTextbookWithProxy:proxy];
    NSError *error = nil;
    NSDictionary *userInfo = nil;


    EPUsageUtil *usageUtil = self.configuration.usageUtil;
    BOOL canStore = [usageUtil canStoreFileWithSize:proxy.storeCollection.apiSize];
#if DEBUG_LOW_STORAGE_UNPACK
    canStore = NO;
#endif
    if (!canStore) {

        userInfo = @{NSLocalizedDescriptionKey: @"No free space avaiable"};
        error = [NSError errorWithDomain:@"EPDownloadUtilErrorDomain" code:EPErrorCodeNoFreeSpace userInfo:userInfo];
        [proxy rollback];
        [proxy raiseError:error];
        
        return;
    }

    self.configuration.settingsModel.downloadedZipLocation = [[EPConfiguration activeConfiguration].pathModel relativePathFromLibrary:path];
    self.configuration.settingsModel.downloadedRootID = [NSString stringWithFormat:@"%@", proxy.rootID];
    
#if DEBUG_UNARCHIVE_KILL

    exit(1);
#endif
    
#if DEBUG_CREATE_DIR_ERROR
    destination = @"invalid directory path";
#endif

    NSFileManager *fm = [NSFileManager defaultManager];
    if (![[NSFileManager defaultManager] createDirectoryAtPath:destinationAbsolutePath withIntermediateDirectories:YES attributes:NULL error:&error]) {

        
        [proxy rollback];
        [proxy raiseError:error];
        
        return;
    }
    
    @try {

        [proxy beginUnpacking];
        
#if DEBUG_UNARCHIVE_ERROR
        @throw [NSException exceptionWithName:@"ArchiveException" reason:@"debug" userInfo:nil];
#endif
#ifdef DEBUG_UNARCHIVE_LAG_TIME

        [NSThread sleepForTimeInterval:DEBUG_UNARCHIVE_LAG_TIME];

#endif

        BOOL result = [EPZipArchive unzipFileAtPath:path toDestination:destinationAbsolutePath progressBlock:^(long fileIndex, long filesCount) {
            float progress = (float) ((double)(fileIndex + 1) / (double)filesCount);
            [proxy updateUnpackingProgress:progress];
        }];


        if (result) {

            [self.configuration.textbookUtil postTextbookDownloadWithProxy:proxy andDestination:destinationAbsolutePath];

            proxy.storeCollection.storePath = [self.configuration.pathModel relativePathForExtractingNewTextbookWithProxy:proxy];
            [proxy commit];
        }
        else {

            [fm removeItemAtPath:destinationAbsolutePath error:nil];

            userInfo = @{NSLocalizedDescriptionKey: @"Failed to unzip the archive"};
            error = [NSError errorWithDomain:@"EPDownloadUtilErrorDomain" code:EPErrorCodeUnzipError userInfo:nil];
            [proxy rollback];
            [proxy raiseError:error];
        }
    }
    @catch (NSException *exception) {


        [fm removeItemAtPath:destinationAbsolutePath error:nil];

        userInfo = @{NSLocalizedDescriptionKey: @"Unknown error occurred"};
        error = [NSError errorWithDomain:@"EPDownloadUtilErrorDomain" code:EPErrorCodeUnknown userInfo:nil];
        [proxy rollback];
        [proxy raiseError:error];
    }
    @finally {

        [proxy endUnpacking];

        self.configuration.settingsModel.downloadedZipLocation = nil;
        self.configuration.settingsModel.downloadedRootID = nil;
    }
}

- (void)downloadService:(EPAppleDownloadService *)downloadService didReceivedError:(NSError *)error forProxy:(EPDownloadTextbookProxy *)proxy {

    if (!error || error.code != EPErrorResumePossible) {
        [proxy rollback];
    }
    [proxy raiseError:error];
}

@end

@implementation EPDownloadUtil (DownloadFromAPI)

#pragma mark - Public methods

- (void)downloadDataFromAPI {
    [self downloadDataFromAPIWithHud:nil force:NO];
}

- (void)downloadDataFromAPIWithHud:(EPProgressHUD *)hud force:(BOOL)force {
#if DEBUG_NO_UPDATES


    if (self.configuration.settingsModel.textbookModelInitialized) {
        return;
    }
#endif
    
    dispatch_barrier_async(self.backgroundQueueApi, ^{

        [NSThread sleepForTimeInterval:1.0f];
        
#if DEBUG_NO_NETWORK

        return;
#endif
#ifdef DEBUG_BAD_NETWORK_LAG

        [NSThread sleepForTimeInterval:DEBUG_BAD_NETWORK_LAG];

#endif

        if (![self canUpdateWithLastDate:self.lastDownloadDataFromAPI andTimeInterval:kTimeIntervalBetweenUpdatesFromAPI]) {


            [NSThread sleepForTimeInterval:1.0f];
            
#if DEBUG_DOS_PROTECTION_OFF

#else

            if (!force) {
                return;
            }
#endif
        }

        self.lastDownloadDataFromAPI = [NSDate new];

        EPDownloadModel *downloadModel = self.configuration.downloadModel;

        @try {


            self.configuration.networkUtil.showActivityIndicator = YES;

            BOOL success = YES;

            if (success) {
                success = [downloadModel downloadAndUpdateCollectionsWithHud:hud];
            }

            if (success) {
                self.configuration.settingsModel.textbookModelInitialized = YES;
            }
        }
        @catch (NSException *exception) {

            
#if DEBUG
            NSAssert(YES, @"Problem with API");
#endif
        }
        @finally {

            self.configuration.networkUtil.showActivityIndicator = NO;

        }
    });
}

- (void)waitForDownloadDataFromAPI {

    
    dispatch_barrier_sync(self.backgroundQueueApi, ^{

    });

}

#pragma mark - Private methods

- (BOOL)canUpdateWithLastDate:(NSDate *)lastDate andTimeInterval:(NSTimeInterval)timeInterval {
    if (!lastDate) {
        return YES;
    }
    if ([[NSDate new] timeIntervalSinceDate:lastDate] > timeInterval) {
        return YES;
    }
    return NO;
}

@end

@implementation EPDownloadUtil (DownloadImageAsync)

- (void)loadCoverForContentID:(NSString *)contentID completion:(imageFromCache_t)completion {
    
    if (!completion) {
        return;
    }
    
    dispatch_barrier_async(self.backgroundQueueImage, ^{

        NSString *imagePath = [self.configuration.pathModel pathForCover:[NSString stringWithFormat:@"%@", contentID]];

        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {

            BOOL canLoad = [self.configuration.usageUtil canLoadImageToMemoryFromPath:imagePath];
            if (canLoad) {
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                if (image) {
                    completion(image, YES);
                    return;
                }
            }
        }

        completion(nil, YES);
    });
}

@end

@implementation EPDownloadUtil (DownloadTextbook)

- (void)clearCorruptedData {


    [self.downloadService clearCorruptedData];
}

- (EPDownloadTextbookProxy *)downloadTextbookProxyForRootID:(NSString *)rootID {
    @synchronized (self) {

        if (!self.textbookProxies[rootID]) {

            EPDownloadTextbookProxy *proxy = [[EPDownloadTextbookProxy alloc] initWithRootID:rootID];
            [proxy updateState];

            self.textbookProxies[rootID] = proxy;
        }

        EPDownloadTextbookProxy *proxy = self.textbookProxies[rootID];
        
        return proxy;
    }
}

- (void)updateProxies {


    dispatch_async(self.backgroundQueueTextbook, ^{
        
        @synchronized (self) {
            NSArray *proxies = [self.textbookProxies allValues];
            for (EPDownloadTextbookProxy *proxy in proxies) {

                if (![proxy updateState]) {

                    
                    [self.textbookProxies removeObjectForKey:proxy.rootID];
                }
            }
        }
    });
}

- (void)downloadTextbookWithProxy:(EPDownloadTextbookProxy *)proxy {

    NSAssert(proxy.storeCollection.state == EPTextbookStateTypeToDownload, @"Invalid state of proxy");

    dispatch_async(self.backgroundQueueTextbook, ^{

        NSString *storeTmpID = proxy.storeCollection.apiContentID;
        NSString *storeURL = proxy.storeCollection.storeUrl;

        [self.configuration.downloadModel setTextbookAsDownloadingWithRootID:proxy.rootID andStoreTmpID:storeTmpID andStoreURL:storeURL];

        [proxy updateState];
        
        [self.downloadService startDownloadWithProxy:proxy];
    });
}

- (void)updateTextbookWithProxy:(EPDownloadTextbookProxy *)proxy {

    NSAssert(proxy.storeCollection.state == EPTextbookStateTypeToUpdate, @"Invalid state of proxy");

    dispatch_async(self.backgroundQueueTextbook, ^{

        NSString *storeTmpID = proxy.storeCollection.apiContentID;
        NSString *storeURL = proxy.storeCollection.storeUrl;

        [self.configuration.downloadModel setTextbookAsUpdatingWithRootID:proxy.rootID andStoreTmpID:storeTmpID andStoreURL:storeURL];

        [proxy updateState];
        
        [self.downloadService startDownloadWithProxy:proxy];
    });
}

- (void)cancelTextbookWithProxy:(EPDownloadTextbookProxy *)proxy {

    NSAssert(proxy.storeCollection.state == EPTextbookStateTypeDownloading || proxy.storeCollection.state == EPTextbookStateTypeUpdating, @"Invalid state of proxy");

    if (proxy.isUnpacking) {
        return;
    }
    
    [self.downloadService cancelDownloadWithProxy:proxy];
    
    [proxy rollback];
}

- (void)removeTextbookWithProxy:(EPDownloadTextbookProxy *)proxy completion:(void (^)(BOOL success))completion {

    NSAssert(proxy.storeCollection.state == EPTextbookStateTypeNormal || proxy.storeCollection.state == EPTextbookStateTypeToUpdate, @"Invalid state of proxy");

    dispatch_async(self.backgroundQueueTextbook, ^{

        NSString *path = [self.configuration.pathModel pathForInstalledTextbookWithProxy:proxy];

        self.configuration.settingsModel.removedZipLocation = proxy.storeCollection.storePath;
        self.configuration.settingsModel.removedRootID = [NSString stringWithFormat:@"%@", proxy.rootID];
        
#if DEBUG_REMOVE_KILL

        exit(1);
#endif

        NSError *error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {

        }

        NSString *contentID = proxy.storeCollection.actualContentID;

        [self.configuration.downloadModel setTextbookAsToDownloadWithRootID:proxy.rootID];

        [proxy updateState];

        [self.configuration.textbookUtil postTextbookRemoveWithRootID:proxy.rootID andContentID:contentID];

        self.configuration.settingsModel.removedZipLocation = nil;
        self.configuration.settingsModel.removedRootID = nil;
        
#ifdef DEBUG_FILE_DELETE_LAG
        [NSThread sleepForTimeInterval:DEBUG_FILE_DELETE_LAG];
#endif

        if (completion) {

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(!error);
            });
        }
    });
}

- (void)resumeTextbookWithProxy:(EPDownloadTextbookProxy *)proxy {

    NSAssert(proxy.storeCollection.state == EPTextbookStateTypeToDownload || proxy.storeCollection.state == EPTextbookStateTypeToUpdate, @"Invalid state of proxy");

    dispatch_async(self.backgroundQueueTextbook, ^{

        if (proxy.storeCollection.state == EPTextbookStateTypeToDownload) {

            NSString *storeTmpID = proxy.storeCollection.apiContentID;
            NSString *storeURL = proxy.storeCollection.storeUrl;

            [self.configuration.downloadModel setTextbookAsDownloadingWithRootID:proxy.rootID andStoreTmpID:storeTmpID andStoreURL:storeURL];

            [proxy updateState];

            [self.downloadService resumeDownloadWithProxy:proxy];
        }

        else if (proxy.storeCollection.state == EPTextbookStateTypeToUpdate) {

            NSString *storeTmpID = proxy.storeCollection.apiContentID;
            NSString *storeURL = proxy.storeCollection.storeUrl;

            [self.configuration.downloadModel setTextbookAsUpdatingWithRootID:proxy.rootID andStoreTmpID:storeTmpID andStoreURL:storeURL];

            [proxy updateState];

            [self.downloadService resumeDownloadWithProxy:proxy];
        }
    });
}

- (void)checkVersionForProxy:(EPDownloadTextbookProxy *)proxy completion:(void (^)(BOOL))completion {
    if (!completion) {
        return;
    }

    EPMetadata *metadata = [self.configuration.textbookModel metadataWithRootID:proxy.rootID];
    if ([NSObject isNullOrEmpty:metadata] || [NSObject isNullOrEmpty:metadata.apiContentID]) {
        return;
    }

    double textbookAppVersion = [self.configuration.collectionStateModel appVersionForContentID:metadata.apiContentID];

    if (textbookAppVersion == 0) {
        completion(YES);
    }
    else {

        double appVersion = [self.configuration.settingsModel.appVersion doubleValue];

        completion(appVersion >= textbookAppVersion);
    }
}

@end
