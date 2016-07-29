







#import <Foundation/Foundation.h>
#import "EPDatabaseModel.h"
#import "EPJsonAPI.h"
#import "EPStoreCollection.h"
#import "EPDownloadTextbookProxy.h"
#import "EPProgressHUD.h"

@interface EPDownloadModel : EPDatabaseModel

@property (nonatomic, readonly) EPJsonAPI *collectionsMetadataAPI;

@end

@interface EPDownloadModel (DownloadData)

- (BOOL)downloadAndUpdateCollections;
- (BOOL)downloadAndUpdateCollectionsWithHud:(EPProgressHUD *)hud;
- (void)removeCollectionWithContentID:(NSString *)contentID;

@end

@interface EPDownloadModel (DownloadTextbook)

- (EPStoreCollection *)storeCollectionWithRootID:(NSString *)rootID;
- (void)setTextbookAsToDownloadWithRootID:(NSString *)rootID;
- (void)setTextbookAsDownloadingWithRootID:(NSString *)rootID andStoreTmpID:(NSString *)storeTmpID andStoreURL:(NSString *)storeURL;
- (void)setTextbookAsNormalWithRootID:(NSString *)rootID andStoreContentID:(NSString *)storeContentID andStorePath:(NSString *)storePath;
- (void)setTextbookAsUpdatingWithRootID:(NSString *)rootID andStoreTmpID:(NSString *)storeTmpID andStoreURL:(NSString *)storeURL;
- (EPDownloadTextbookProxy *)nextProxyFromDownloadQueue;

@end
