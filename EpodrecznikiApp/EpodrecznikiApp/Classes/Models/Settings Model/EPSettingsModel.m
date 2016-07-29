







#import "EPSettingsModel.h"

NSString const *userAcceptedPolicyKey                               = @"userAcceptedPolicy";
NSString const *textbooksListContainerTypeKey                       = @"textbooksListContainerType";
NSString const *textbookModelInitializedKey                         = @"textbookModelInitialized";
NSString const *allowUsingCellularNetworkKey                        = @"allowUsingCellularNetworkKey";
NSString const *canUserCreateAccountTypeKey                         = @"canUserCreateAccountTypeKey";
NSString const *activeFilterKey                                     = @"activeFilterKey";

NSString const *downloadedZipLocationKey                            = @"downloadedZipLocationKey";
NSString const *downloadedRootIDKey                                 = @"downloadedRootIDKey";
NSString const *removedZipLocationKey                               = @"removedZipLocationKey";
NSString const *removedRootIDKey                                    = @"removedRootIDKey";


NSString const *textbookVariantTypeKey                              = @"textbookVariantTypeKey";
NSString const *videoPlayerSettingsTypeKey                          = @"videoPlayerSettingsTypeKey";
NSString const *navigationButtonsVisibilitySettingsTypeKey          = @"navigationButtonsVisibilitySettingsTypeKey";

@implementation EPSettingsModel

#pragma mark - Migration

- (void)performMigration {
    NSString *newVersion = self.appVersion;
    NSString *existingVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kPreferencesKeyVersion];
    
#if DEBUG




#endif

    [self migrateFromVersion:existingVersion toVersion:newVersion];

    [[NSUserDefaults standardUserDefaults] setObject:newVersion forKey:kPreferencesKeyVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
#if DEBUG




#endif
}

- (void)migrateFromVersion:(NSString *)currentVersion toVersion:(NSString *)newVersion {

    if (!currentVersion) {

        
        return;
    }

    
    double dCurrentVersion = (currentVersion ? [currentVersion doubleValue] : 0.0);


    if (dCurrentVersion >= 1.0 && dCurrentVersion <= 1.02) {

        
        @try {
            FMDatabase *db = [self openDatabase];
            if (db) {

                [db beginTransaction];
                [db executeUpdate:@"alter table ep_collection_state rename to tmp_ep_collection_state"];
                [db executeUpdate:@"create table ep_collection_state(root_id varchar, content_id varchar, \"key\" varchar, value varchar)"];
                [db executeUpdate:@"insert into ep_collection_state select * from tmp_ep_collection_state"];
                [db executeUpdate:@"drop table tmp_ep_collection_state"];

                [db executeUpdate:@"alter table ep_user add column role integer"];
                [db executeUpdate:@"alter table ep_user add column state varchar"];
                [db executeUpdate:@"alter table ep_user add column avatar varchar"];
                [db executeUpdate:@"alter table ep_user add column question varchar"];
                [db executeUpdate:@"alter table ep_user add column spassword varchar"];
                [db executeUpdate:@"alter table ep_user add column hpassword varchar"];
                [db executeUpdate:@"alter table ep_user add column sanswer varchar"];
                [db executeUpdate:@"alter table ep_user add column hanswer varchar"];
                [db executeUpdate:@"alter table ep_user add column created_date datetime"];
                [db executeUpdate:@"alter table ep_user add column last_login_date datetime"];
                [db executeUpdate:@"alter table ep_user add column json varchar"];
                
                NSInteger containerType = [db intForQuery:
                    @"select value from ep_user_settings where key = ?",
                    textbooksListContainerTypeKey
                ];
                NSInteger videoType = [db intForQuery:
                    @"select value from ep_user_settings where key = ?",
                    videoPlayerSettingsTypeKey
                ];
                NSInteger variantType = [db intForQuery:
                    @"select value from ep_user_settings where key = ?",
                    textbookVariantTypeKey
                ];
                
                NSString *state = [NSString stringWithFormat:
                    @"%ld%ld%ld%ld%ld"
                    @"%ld%ld%ld%ld%ld"
                    @"%ld%ld%ld%ld%ld"
                    @"%ld%ld%ld%ld%ld",
                    (long)EPSettingsCanDownloadAndRemoveTextbooksTypeGranted,
                    (long)EPSettingsCanLoginWithoutPasswordTypeDenied,
                    (long)variantType,
                    (long)videoType,
                    (long)containerType,
                    (long)EPSettingsNavigationButtonsVisibilityTypeHidden,
                    0l, 0l, 0l, 0l,
                    0l, 0l, 0l, 0l, 0l,
                    0l, 0l, 0l, 0l, 0l
                ];
                [db executeUpdate:@"update ep_user set login = 'defaultUser', role = ?, state = ? where id = ?",
                    @(EPAccountRoleUnknown),
                    state,
                    @(kDefaultUserID)
                ];

                [db executeUpdate:@"delete from ep_user_settings where key = ? or key = ? or key = ?",
                    textbooksListContainerTypeKey,
                    textbookVariantTypeKey,
                    videoPlayerSettingsTypeKey
                ];
                [db executeUpdate:@"update ep_user_settings set user_id = ?",
                    @(kGlobalUserID)
                ];
                [db executeUpdate:@"update ep_user_settings set value = ? where key = ? and value = 0",
                 @(EPSettingsCellularStateTypeDenied),
                    allowUsingCellularNetworkKey
                ];

                [db executeUpdate:@"CREATE TABLE ep_user_notes ( localNoteId integer PRIMARY KEY AUTOINCREMENT, localUserId varchar, handbookId varchar, moduleId varchar, pageId varchar, noteId varchar, userId varchar, location varchar, subject varchar, value varchar, type varchar, accepted varchar, referenceTo varchar, referencedBy varchar, modifyTime varchar, json varchar );"];

                [db executeUpdate:@"CREATE TABLE ep_user_womi_state ( user_id integer NOT NULL, root_id varchar, womi_id varchar, womi_state varchar );"];

                [db commit];
                [self closeDatabase];

                self.canUserCreateAccountType = EPSettingsCanUserCreateAccountTypeDenied;
            }
        }
        @catch (NSException *exception) {

        }
    }

    {

        
        @try {
            FMDatabase *db = [self openDatabase];
            if (db) {
                
                NSArray *removableIDs = @[
                    @"26546_2",
                    @"26762_2",
                    @"27644_2",
                    @"18131_8",
                    @"18148_8",
                    @"19886_10",
                    @"62352_1"
                ];

                [db beginTransaction];
                for (NSString *content_id in removableIDs) {
                    
                    [db executeUpdate:@"DELETE FROM ep_collection WHERE content_id = ?", content_id];
                    [db executeUpdate:@"DELETE FROM ep_collection_author WHERE content_id = ?", content_id];
                    [db executeUpdate:@"DELETE FROM ep_collection_format WHERE content_id = ?", content_id];
                    [db executeUpdate:@"DELETE FROM ep_collection_school WHERE content_id = ?", content_id];
                    [db executeUpdate:@"DELETE FROM ep_collection_state WHERE content_id = ?", content_id];
                    [db executeUpdate:@"DELETE FROM ep_collection_subject WHERE content_id = ?", content_id];
                    [db executeUpdate:@"DELETE FROM ep_store_collection WHERE api_content_id = ? OR store_content_id = ?", content_id, content_id];
                }

                [db commit];
                [self closeDatabase];

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSArray *removablePaths = @[
                        @"/26546/26546_2",
                        @"/26762/26762_2",
                        @"/27644/27644_2",
                        @"/18131/18131_8",
                        @"/18148/18148_8",
                        @"/19886/19886_10",
                        @"/62352/62352_1"
                    ];
                    
                    NSString *basePath = self.configuration.pathModel.textbooksDirectory;
                    for (NSString *pathFragment in removablePaths) {
                        NSString *fullPath = [basePath stringByAppendingString:pathFragment];
                        
                        NSFileManager *fm = [NSFileManager defaultManager];
                        if ([fm fileExistsAtPath:fullPath]) {
                            [fm removeItemAtPath:fullPath error:nil];

                        }
                    }
                });
                
            }
        }
        @catch (NSException *exception) {

        }
    }

}

#pragma mark - Global preferences

- (BOOL)textbookModelInitialized {
    @synchronized (self) {
        return [self boolForName:@"settings_get_value", @(kGlobalUserID), textbookModelInitializedKey, @NO];
    }
}

- (void)setTextbookModelInitialized:(BOOL)textbookModelInitialized {
    @synchronized (self) {
        [self executeNonQueryWithName:@"settings_remove_value", @(kGlobalUserID), textbookModelInitializedKey];
        [self executeNonQueryWithName:@"settings_set_value", @(kGlobalUserID), textbookModelInitializedKey, @(textbookModelInitialized)];
    }
}

- (BOOL)userAcceptedPolicy {
    @synchronized (self) {
        NSString *fullKey = [userAcceptedPolicyKey stringByAppendingFormat:@"_%@", self.appVersion];
        return [self boolForName:@"settings_get_value", @(kGlobalUserID), fullKey, @NO];
    }
}

- (void)setUserAcceptedPolicy:(BOOL)userAcceptedPolicy {
    @synchronized (self) {
        NSString *fullKey = [userAcceptedPolicyKey stringByAppendingFormat:@"_%@", self.appVersion];
        [self executeNonQueryWithName:@"settings_remove_value", @(kGlobalUserID), fullKey];
        [self executeNonQueryWithName:@"settings_set_value", @(kGlobalUserID), fullKey, @(userAcceptedPolicy)];
    }
}

- (EPSettingsCellularStateType)allowUsingCellularNetwork {
    @synchronized (self) {
        EPSettingsCellularStateType type = [self intForName:@"settings_get_value", @(kGlobalUserID), allowUsingCellularNetworkKey, @(EPSettingsCellularStateTypeUnknown)];
#if DEBUG_CELLULAR_UNSET
        type = EPSettingsCellularStateTypeUnset;
#endif
#if DEBUG_CELLULAR_ALLOWED
        type = EPSettingsCellularStateTypeAllowed;
#endif
#if DEBUG_CELLULAR_DENIED
        type = EPSettingsCellularStateTypeDenied;
#endif
        return type;
    }
}

- (void)setAllowUsingCellularNetwork:(EPSettingsCellularStateType)allowUsingCellularNetwork {
    @synchronized (self) {
        [self executeNonQueryWithName:@"settings_remove_value", @(kGlobalUserID), allowUsingCellularNetworkKey];
        [self executeNonQueryWithName:@"settings_set_value", @(kGlobalUserID), allowUsingCellularNetworkKey, @(allowUsingCellularNetwork)];
    }
}

- (EPSettingsCanUserCreateAccountType)canUserCreateAccountType {
    @synchronized (self) {
        return [self intForName:@"settings_get_value", @(kGlobalUserID), canUserCreateAccountTypeKey, @(EPSettingsCanUserCreateAccountTypeUnknown)];
    }
}

- (void)setCanUserCreateAccountType:(EPSettingsCanUserCreateAccountType)canUserCreateAccountType {
    @synchronized (self) {
        [self executeNonQueryWithName:@"settings_remove_value", @(kGlobalUserID), canUserCreateAccountTypeKey];
        [self executeNonQueryWithName:@"settings_set_value", @(kGlobalUserID), canUserCreateAccountTypeKey, @(canUserCreateAccountType)];
    }
}

- (EPFilter *)activeFilter {
    @synchronized (self) {
        NSString *userID = self.configuration.userIDString;
        NSString *filterString = [self stringForName:@"settings_get_value", userID, activeFilterKey, [NSNull null]];
        
        if ([NSObject isNullOrEmpty:filterString]) {
            return [EPFilter new];
        }
        
        return [[EPFilter alloc] initWithString:filterString];
    }
}

- (void)setActiveFilter:(EPFilter *)activeFilter {
    @synchronized (self) {
        NSString *userID = self.configuration.userIDString;
        [self executeNonQueryWithName:@"settings_remove_value", userID, activeFilterKey];
        if (activeFilter) {
            [self executeNonQueryWithName:@"settings_set_value", userID, activeFilterKey, [activeFilter stringFromFilter]];
        }
    }
}

#pragma mark - Global preferences internal

- (NSString *)downloadedZipLocation {
    @synchronized (self) {
        return [self stringForName:@"settings_get_value2", @(kGlobalUserID), downloadedZipLocationKey];
    }
}

- (void)setDownloadedZipLocation:(NSString *)downloadedZipLocation {
    @synchronized (self) {
        [self executeNonQueryWithName:@"settings_remove_value", @(kGlobalUserID), downloadedZipLocationKey];
        if (downloadedZipLocation) {
            [self executeNonQueryWithName:@"settings_set_value", @(kGlobalUserID), downloadedZipLocationKey, downloadedZipLocation];
        }
    }
}

- (NSString *)downloadedRootID {
    @synchronized (self) {
        return [self stringForName:@"settings_get_value2", @(kGlobalUserID), downloadedRootIDKey];
    }
}

- (void)setDownloadedRootID:(NSString *)downloadedRootID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"settings_remove_value", @(kGlobalUserID), downloadedRootIDKey];
        if (downloadedRootID) {
            [self executeNonQueryWithName:@"settings_set_value", @(kGlobalUserID), downloadedRootIDKey, downloadedRootID];
        }
    }
}

- (NSString *)removedZipLocation {
    @synchronized (self) {
        return [self stringForName:@"settings_get_value2", @(kGlobalUserID), removedZipLocationKey];
    }
}

- (void)setRemovedZipLocation:(NSString *)removedZipLocation {
    @synchronized (self) {
        [self executeNonQueryWithName:@"settings_remove_value", @(kGlobalUserID), removedZipLocationKey];
        if (removedZipLocation) {
            [self executeNonQueryWithName:@"settings_set_value", @(kGlobalUserID), removedZipLocationKey, removedZipLocation];
        }
    }
}

- (NSString *)removedRootID {
    @synchronized (self) {
        return [self stringForName:@"settings_get_value2", @(kGlobalUserID), removedRootIDKey];
    }
}

- (void)setRemovedRootID:(NSString *)removedRootID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"settings_remove_value", @(kGlobalUserID), removedRootIDKey];
        if (removedRootID) {
            [self executeNonQueryWithName:@"settings_set_value", @(kGlobalUserID), removedRootIDKey, removedRootID];
        }
    }
}

- (NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

#pragma mark - Public methods

- (void)removeAllSettingsByUserID:(NSNumber *)userID {
    @synchronized (self) {
        NSString *userID = self.configuration.userIDString;
        [self executeNonQueryWithName:@"settings_remove_all_by_user_id", userID];
    }
}

@end
