







#import <Foundation/Foundation.h>
#import "EPDatabaseModel.h"
#import "EPPageItem.h"

@interface EPCollectionStateModel : EPDatabaseModel


- (EPPageItem *)lastPageItemForRootID:(NSString *)rootID;
- (void)setLastPageItem:(EPPageItem *)pageItem forRootID:(NSString *)rootID;
- (void)removeAllPageItemsForRootID:(NSString *)rootID;
- (void)removeAllPageItemsForUserID:(NSNumber *)userID;

- (double)appVersionForContentID:(NSString *)contentID;
- (void)setAppVersion:(NSString *)appVersion forContentID:(NSString *)contentID;


- (NSString *)lastPageLocationForRootID:(NSString *)rootID;
- (void)setLastPageLocation:(NSString *)location forRootID:(NSString *)rootID;

@end
