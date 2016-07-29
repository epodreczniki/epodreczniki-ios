







#import <Foundation/Foundation.h>
#import "EPDatabaseModel.h"

@interface EPSettingsModel : EPDatabaseModel


@property (nonatomic) BOOL textbookModelInitialized;
@property (nonatomic) BOOL userAcceptedPolicy;
@property (nonatomic) EPSettingsCellularStateType allowUsingCellularNetwork;
@property (nonatomic) EPSettingsCanUserCreateAccountType canUserCreateAccountType;
@property (nonatomic, assign) EPFilter *activeFilter;


@property (nonatomic, copy) NSString *downloadedZipLocation;
@property (nonatomic, copy) NSString *downloadedRootID;
@property (nonatomic, copy) NSString *removedZipLocation;
@property (nonatomic, copy) NSString *removedRootID;
@property (nonatomic, readonly) NSString *appVersion;

- (void)performMigration;
- (void)removeAllSettingsByUserID:(NSNumber *)userID;

@end
