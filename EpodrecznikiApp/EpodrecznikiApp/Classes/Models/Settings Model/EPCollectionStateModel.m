







#import "EPCollectionStateModel.h"

NSString const *anyRootIDKey                = @"anyRootIDKey";
NSString const *anyContentIDKey             = @"anyContentIDKey";

NSString const *lastPageRootIDKey           = @"lastPageRootIDKey";
NSString const *lastPageItemRootIDKey       = @"lastPageItemRootIDKey";
NSString const *appVersionKey               = @"appVersionKey";

@implementation EPCollectionStateModel

- (EPPageItem *)lastPageItemForRootID:(NSString *)rootID {
    @synchronized (self) {
        NSString *userID = [self.configuration userIDString];
        NSString *result = [self stringForName:@"collection_state_get_value2", rootID, userID, lastPageItemRootIDKey];
        
        if (!result) {
            return nil;
        }
        
        EPPageItem *pageItem = [EPPageItem pageItemFromString:result];
        return pageItem;
    }
}

- (void)setLastPageItem:(EPPageItem *)pageItem forRootID:(NSString *)rootID {
    @synchronized (self) {
        NSString *userID = [self.configuration userIDString];
        
        [self executeNonQueryWithName:@"collection_state_remove_value", rootID, userID, lastPageItemRootIDKey];
        if (pageItem) {
            [self executeNonQueryWithName:@"collection_state_set_value", rootID, userID, lastPageItemRootIDKey, [pageItem stringFromPageItem]];
        }
    }
}

- (void)removeAllPageItemsForRootID:(NSString *)rootID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"collection_state_remove_all_by_root_id", rootID, lastPageItemRootIDKey];
    }
}

- (void)removeAllPageItemsForUserID:(NSNumber *)userID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"collection_state_remove_all_by_user_id", userID, lastPageItemRootIDKey];
    }
}

- (NSString *)lastPageLocationForRootID:(NSString *)rootID {
    @synchronized (self) {
        return [self stringForName:@"collection_state_get_value2", rootID, anyContentIDKey, lastPageRootIDKey];
    }
}

- (void)setLastPageLocation:(NSString *)location forRootID:(NSString *)rootID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"collection_state_remove_value", rootID, anyContentIDKey, lastPageRootIDKey];
        if (location) {
            [self executeNonQueryWithName:@"collection_state_set_value", rootID, anyContentIDKey, lastPageRootIDKey, location];
        }
    }
}

- (double)appVersionForContentID:(NSString *)contentID {
    @synchronized (self) {
        NSString *value = [self stringForName:@"collection_state_get_value2", anyRootIDKey, contentID, appVersionKey];
        
        if (value && [value isKindOfClass:[NSString class]]) {
            return [value doubleValue];
        }
        
        return 0.0;
    }
}

- (void)setAppVersion:(NSString *)appVersion forContentID:(NSString *)contentID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"collection_state_remove_value", anyRootIDKey, contentID, appVersionKey];
        if (appVersion) {
            [self executeNonQueryWithName:@"collection_state_set_value", anyRootIDKey, contentID, appVersionKey, appVersion];
        }
    }
}

@end
