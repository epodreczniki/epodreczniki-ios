







#import "EPConfiguration.h"


static EPConfiguration *sActiveConfiguration = nil;

@implementation EPConfiguration

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pathModel = [[EPPathModel alloc] initWithConfiguration:self];
        self.settingsModel = [[EPSettingsModel alloc] initWithConfiguration:self];
        self.collectionStateModel = [[EPCollectionStateModel alloc] initWithConfiguration:self];
        self.textbookModel = [[EPTextbookModel alloc] initWithConfiguration:self];
        self.downloadModel = [[EPDownloadModel alloc] initWithConfiguration:self];
        self.tocModel = [[EPTocModel alloc] initWithConfiguration:self];
        self.userModel = [[EPUserModel alloc] initWithConfiguration:self];
        self.notesModel = [[EPNotesModel alloc] initWithConfiguration:self];
        self.womiModel = [[EPWomiModel alloc] initWithConfiguration:self];
        self.filterModel = [[EPFilterModel alloc] initWithConfiguration:self];
        
        self.networkUtil = [[EPNetworkUtil alloc] initWithConfiguration:self];
        self.textbookUtil = [[EPTextbookUtil alloc] initWithConfiguration:self];
        self.localNotificationUtil = [[EPLocalNotificationUtil alloc] initWithConfiguration:self];
        self.downloadUtil = [[EPDownloadUtil alloc] initWithConfiguration:self];
        self.tocUtil = [[EPTocUtil alloc] initWithConfiguration:self];
        self.usageUtil = [[EPUsageUtil alloc] initWithConfiguration:self];
        self.windowsUtil = [[EPWindowsUtil alloc] initWithConfiguration:self];
        self.accessibilityUtil = [[EPAccessibilityUtil alloc] initWithConfiguration:self];
        self.userUtil = [[EPUserUtil alloc] initWithConfiguration:self];
        self.dateUtil = [[EPDateUtil alloc] initWithConfiguration:self];
        self.cryptoUtil = [[EPCryptoUtil alloc] initWithConfiguration:self];
        self.notesUtil = [[EPNotesUtil alloc] initWithConfiguration:self];
        self.filterUtil = [[EPFilterUtil alloc] initWithConfiguration:self];
    }
    return self;
}

- (void)dealloc {
    self.settingsModel = nil;
    self.collectionStateModel = nil;
    self.textbookModel = nil;
    self.downloadModel = nil;
    self.tocModel = nil;
    self.pathModel = nil;
    self.userModel = nil;
    self.notesModel = nil;
    self.womiModel = nil;
    
    self.networkUtil = nil;
    self.downloadUtil = nil;
    self.textbookUtil = nil;
    self.localNotificationUtil = nil;
    self.usageUtil = nil;
    self.windowsUtil = nil;
    self.accessibilityUtil = nil;
    self.userUtil = nil;
    self.dateUtil = nil;
    self.cryptoUtil = nil;
    self.notesUtil = nil;
}

#pragma mark - Static methods

+ (EPConfiguration *)activeConfiguration {
    @synchronized([EPConfiguration class]) {
        if (!sActiveConfiguration) {
            sActiveConfiguration = [EPConfiguration new];

        }
    }
    return sActiveConfiguration;
}

#pragma mark - Public properties

- (NSNumber *)userID {
    return self.userUtil.userID;
}

- (EPUser *)user {
    return self.userUtil.user;
}

#pragma mark - Public methods

- (NSString *)userIDString {
    return [NSString stringWithFormat:@"%@", self.userID];
}

@end
