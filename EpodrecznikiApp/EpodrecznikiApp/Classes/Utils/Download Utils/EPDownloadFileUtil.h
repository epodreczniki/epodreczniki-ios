







#import <Foundation/Foundation.h>

@class EPDownloadFileUtil;

@protocol EPDownloadFileUtilDelegate <NSObject>
@optional
- (void)downloadFileUtil:(EPDownloadFileUtil *)downloadFileUtil didWriteBytes:(uint64_t)bytesWritten totalBytes:(uint64_t)totalBytesWritten expectedTotalBytes:(uint64_t)expectedTotalBytes;
- (void)downloadFileUtil:(EPDownloadFileUtil *)downloadFileUtil didFinishDownloadingFileToPath:(NSString *)path;
- (void)downloadFileUtil:(EPDownloadFileUtil *)downloadFileUtil didRaiseError:(NSError *)error;

@end

@interface EPDownloadFileUtil : NSObject <NSURLConnectionDataDelegate, EPDownloadFileUtilDelegate>

@property (nonatomic) NSTimeInterval requestTimeout;
@property (nonatomic, assign) id <EPDownloadFileUtilDelegate> delegate;

- (BOOL)syncDownloadFileWithURL:(NSURL *)url storeToPath:(NSString *)path;
- (void)asyncDownloadFileWithURL:(NSURL *)url storeToPath:(NSString *)path;
- (void)cancel;

@end
