







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"
#import "EPDownloadTextbookProxy.h"

@protocol EPAppleDownloadServiceDelegate;
@protocol EPAppleDownloadServiceDataSource;

@interface EPAppleDownloadService : EPConfigurableObject <NSURLSessionDownloadDelegate>

@property (nonatomic, assign) id <EPAppleDownloadServiceDataSource> dataSource;
@property (nonatomic, assign) id <EPAppleDownloadServiceDelegate> delegate;

- (void)startDownloadWithProxy:(EPDownloadTextbookProxy *)proxy;
- (void)cancelDownloadWithProxy:(EPDownloadTextbookProxy *)proxy;
- (void)clearCorruptedData;
- (void)resumeDownloadWithProxy:(EPDownloadTextbookProxy *)proxy;

@end

@protocol EPAppleDownloadServiceDelegate <NSObject>

- (void)downloadService:(EPAppleDownloadService *)downloadService didDownloadFileAtPath:(NSString *)path forProxy:(EPDownloadTextbookProxy *)proxy;
- (void)downloadService:(EPAppleDownloadService *)downloadService didReceivedError:(NSError *)error forProxy:(EPDownloadTextbookProxy *)proxy;

@end

@protocol EPAppleDownloadServiceDataSource <NSObject>

- (EPDownloadTextbookProxy *)nextProxyObjectForDownloadService:(EPAppleDownloadService *)downloadService;
- (EPDownloadTextbookProxy *)downloadService:(EPAppleDownloadService *)downloadService proxyObjectForRootID:(NSString *)rootID;

@end
