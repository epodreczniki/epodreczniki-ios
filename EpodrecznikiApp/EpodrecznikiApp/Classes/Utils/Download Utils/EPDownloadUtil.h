







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"
#import "EPDownloadTextbookProxy.h"
#import "EPAppleDownloadService.h"
#import "EPProgressHUD.h"


typedef void (^imageFromCache_t)(UIImage *image, BOOL fromCache);

@interface EPDownloadUtil : EPConfigurableObject <EPAppleDownloadServiceDataSource, EPAppleDownloadServiceDelegate>

@end

@interface EPDownloadUtil (DownloadFromAPI)

- (void)downloadDataFromAPI DEPRECATED_ATTRIBUTE;
- (void)downloadDataFromAPIWithHud:(EPProgressHUD *)hud force:(BOOL)force;
- (void)waitForDownloadDataFromAPI;

@end

@interface EPDownloadUtil (DownloadImageAsync)

- (void)loadCoverForContentID:(NSString *)contentID completion:(imageFromCache_t)completion;

@end

@interface EPDownloadUtil (DownloadTextbook)


- (void)clearCorruptedData;


- (EPDownloadTextbookProxy *)downloadTextbookProxyForRootID:(NSString *)rootID;
- (void)updateProxies;


- (void)downloadTextbookWithProxy:(EPDownloadTextbookProxy *)proxy;
- (void)updateTextbookWithProxy:(EPDownloadTextbookProxy *)proxy;
- (void)cancelTextbookWithProxy:(EPDownloadTextbookProxy *)proxy;
- (void)removeTextbookWithProxy:(EPDownloadTextbookProxy *)proxy completion:(void (^)(BOOL success))completion;
- (void)resumeTextbookWithProxy:(EPDownloadTextbookProxy *)proxy;


- (void)checkVersionForProxy:(EPDownloadTextbookProxy *)proxy completion:(void (^)(BOOL success))completion;

@end
