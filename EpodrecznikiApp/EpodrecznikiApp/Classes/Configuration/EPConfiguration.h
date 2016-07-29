







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"


#import "EPCollectionStateModel.h"
#import "EPDownloadModel.h"
#import "EPFilterModel.h"
#import "EPNotesModel.h"
#import "EPPathModel.h"
#import "EPSettingsModel.h"
#import "EPTextbookModel.h"
#import "EPTocModel.h"
#import "EPUserModel.h"
#import "EPUserModel.h"
#import "EPWomiModel.h"


#import "EPAccessibilityUtil.h"
#import "EPCryptoUtil.h"
#import "EPDateUtil.h"
#import "EPDownloadUtil.h"
#import "EPFilterUtil.h"
#import "EPLocalNotificationUtil.h"
#import "EPNetworkUtil.h"
#import "EPNotesUtil.h"
#import "EPTextbookUtil.h"
#import "EPTocUtil.h"
#import "EPUsageUtil.h"
#import "EPUserUtil.h"
#import "EPWindowsUtil.h"

@interface EPConfiguration : NSObject

@property (nonatomic, readonly) NSNumber *userID;
@property (nonatomic, readonly) EPUser *user;

@property (nonatomic, strong) EPCollectionStateModel *collectionStateModel;
@property (nonatomic, strong) EPDownloadModel *downloadModel;
@property (nonatomic, strong) EPFilterModel *filterModel;
@property (nonatomic, strong) EPNotesModel *notesModel;
@property (nonatomic, strong) EPPathModel *pathModel;
@property (nonatomic, strong) EPSettingsModel *settingsModel;
@property (nonatomic, strong) EPTextbookModel *textbookModel;
@property (nonatomic, strong) EPTocModel *tocModel;
@property (nonatomic, strong) EPUserModel *userModel;
@property (nonatomic, strong) EPWomiModel *womiModel;

@property (nonatomic, strong) EPAccessibilityUtil *accessibilityUtil;
@property (nonatomic, strong) EPCryptoUtil *cryptoUtil;
@property (nonatomic, strong) EPDateUtil *dateUtil;
@property (nonatomic, strong) EPDownloadUtil *downloadUtil;
@property (nonatomic, strong) EPFilterUtil *filterUtil;
@property (nonatomic, strong) EPLocalNotificationUtil *localNotificationUtil;
@property (nonatomic, strong) EPNetworkUtil *networkUtil;
@property (nonatomic, strong) EPNotesUtil *notesUtil;
@property (nonatomic, strong) EPTextbookUtil *textbookUtil;
@property (nonatomic, strong) EPTocUtil *tocUtil;
@property (nonatomic, strong) EPUsageUtil *usageUtil;
@property (nonatomic, strong) EPUserUtil *userUtil;
@property (nonatomic, strong) EPWindowsUtil *windowsUtil;


+ (EPConfiguration *)activeConfiguration;


- (NSString *)userIDString;

@end
