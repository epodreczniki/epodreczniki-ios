







#import "EPDownloadFileUtil.h"

@interface EPDownloadFileUtil ()

@property (nonatomic) BOOL downloading;
@property (nonatomic) BOOL success;
@property (nonatomic) BOOL dirty;
@property (nonatomic) BOOL error;
@property (nonatomic) NSInteger statusCode;
@property (nonatomic) uint64_t totalBytes;
@property (nonatomic) uint64_t expectedTotalBytes;
@property (nonatomic, copy) NSString *destinationPath;
@property (nonatomic) NSURLConnection *connection;

@end

@implementation EPDownloadFileUtil

#pragma mark - Lifecycle

- (void)dealloc {
    self.destinationPath = nil;
    self.connection = nil;
    [self.connection setDelegateQueue:nil];
    self.delegate = nil;
}

#pragma mark - Public methods

- (BOOL)syncDownloadFileWithURL:(NSURL *)url storeToPath:(NSString *)path {
    if (self.connection) {
        return NO;
    }


    dispatch_sync(dispatch_queue_create("pl.psnc.download-file-util", NULL), ^{
        
        [self asyncDownloadFileWithURL:url storeToPath:path];

        
        while (self.downloading) {
            [NSThread sleepForTimeInterval:0.5f];
        }

    });
    
    return self.success;
}

- (void)asyncDownloadFileWithURL:(NSURL *)url storeToPath:(NSString *)path {
    if (self.connection) {
        return;
    }


    self.destinationPath = path;
    self.downloading = YES;
    self.success = NO;
    self.dirty = NO;
    self.error = NO;
    self.statusCode = -1;
    self.totalBytes = 0L;
    self.expectedTotalBytes = 0L;
    self.delegate = self;

    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setName:@"pl.psnc.download-file-util.operationQueue"];

    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.requestTimeout];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:operationQueue];
    [self.connection start];
}

- (void)cancel {
    if (self.connection) {
        [self.connection cancel];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    self.statusCode = httpResponse.statusCode;

    if (httpResponse.statusCode >= 400) {
        self.error = YES;
    }

    else {
        self.expectedTotalBytes = response.expectedContentLength;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFileUtil:didRaiseError:)]) {
        [self.delegate downloadFileUtil:self didRaiseError:error];
    }
    
    self.success = NO;
    self.destinationPath = nil;
    self.connection = nil;
    [self.connection setDelegateQueue:nil];

    if (self.dirty) {
        [[NSFileManager defaultManager] removeItemAtPath:self.destinationPath error:nil];
    }
    self.downloading = NO;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (self.error) {
        return;
    }

    if (!self.dirty) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.destinationPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.destinationPath error:nil];
        }
        self.dirty = YES;
    }

    NSFileHandle *hFile = [NSFileHandle fileHandleForWritingAtPath:self.destinationPath];
    if (!hFile) {
        [[NSFileManager defaultManager] createFileAtPath:self.destinationPath contents:nil attributes:nil];
        hFile = [NSFileHandle fileHandleForWritingAtPath:self.destinationPath];
    }
    if (!hFile) {

        [connection cancel];
        
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Could not write to file: %@", self.destinationPath]
        };
        NSError *error = [NSError errorWithDomain:@"EPDownloadFileUtil" code:-1 userInfo:userInfo];

        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFileUtil:didFinishDownloadingFileToPath:)]) {
            [self.delegate downloadFileUtil:self didRaiseError:error];
        }
        
        return;
    }
    @try {
        [hFile seekToEndOfFile];
        [hFile writeData:data];
        self.dirty = YES;
        self.totalBytes += data.length;
    }
    @catch (NSException *e) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@: %@", e.name, e.reason]
        };
        NSError *error = [NSError errorWithDomain:@"EPDownloadFileUtil" code:-1 userInfo:userInfo];

        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFileUtil:didFinishDownloadingFileToPath:)]) {
            [self.delegate downloadFileUtil:self didRaiseError:error];
        }

        [connection cancel];
    }
    @finally {
        [hFile closeFile];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFileUtil:didWriteBytes:totalBytes:expectedTotalBytes:)]) {
        [self.delegate downloadFileUtil:self didWriteBytes:data.length totalBytes:self.totalBytes expectedTotalBytes:self.expectedTotalBytes];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    if (self.error) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"StatusCode: %d", (int)self.statusCode]
        };
        NSError *error = [NSError errorWithDomain:@"EPDownloadFileUtil" code:-1 userInfo:userInfo];
        [self connection:connection didFailWithError:error];
        return;
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadFileUtil:didFinishDownloadingFileToPath:)]) {
            [self.delegate downloadFileUtil:self didFinishDownloadingFileToPath:self.destinationPath];
        }
    }
    
    self.success = YES;
    self.destinationPath = nil;
    [self.connection setDelegateQueue:nil];
    self.connection = nil;
    self.downloading = NO;
}

#pragma mark - EPDownloadFileUtilDelegate

- (void)downloadFileUtil:(EPDownloadFileUtil *)downloadFileUtil didWriteBytes:(uint64_t)bytesWritten totalBytes:(uint64_t)totalBytesWritten expectedTotalBytes:(uint64_t)expectedTotalBytes {
#if DEBUG_DOWNLOAD_FILE_CLASS

#endif
}

- (void)downloadFileUtil:(EPDownloadFileUtil *)downloadFileUtil didFinishDownloadingFileToPath:(NSString *)path {
#if DEBUG_DOWNLOAD_FILE_CLASS

#endif
}

- (void)downloadFileUtil:(EPDownloadFileUtil *)downloadFileUtil didRaiseError:(NSError *)error {
#if DEBUG_DOWNLOAD_FILE_CLASS

#endif
}

@end
