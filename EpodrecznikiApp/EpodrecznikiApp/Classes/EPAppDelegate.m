







#import "EPAppDelegate.h"

#import "EPAlertViewHandler.h"

#import "EPDownloadFileUtil.h"
#import <AVFoundation/AVFoundation.h>

@implementation EPAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];

    [self cleanApp];

    self.window.tintColor = [UIColor epBlueColor];
    self.window.backgroundColor = [UIColor whiteColor];

    application.idleTimerDisabled = YES;

    [self enableAudioOnWebView];

    [self askUserForNotifications];

    [self initDataModel];

    [self recoverAfterKill];

    [self swapViewControllers];

    [[EPConfiguration activeConfiguration].downloadUtil clearCorruptedData];

    [self debugForceListType];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{


}

- (void)applicationDidEnterBackground:(UIApplication *)application
{


}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if (application.applicationState == UIApplicationStateActive) {
        
        EPAlertViewHandler *handler = [EPAlertViewHandler new];
        handler.title = NSLocalizedString(@"EPAppDelegate_alertRemindAboutTextbookListUpdateTitle", nil);
        handler.message = notification.alertBody;
        [handler addCancelButtonWithTitle:NSLocalizedString(@"EPAppDelegate_alertRemindAboutTextbookListUpdateButtonOK", nil) andActionBlock:nil];
        [handler show];
    }
}

#pragma mark - Private methods

- (UIViewController *)viewControllerWithStoryboardID:(NSString *)storyboardID {
    return [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:storyboardID];
}

- (void)enableAudioOnWebView {
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *error = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!ok) {

    }
}

- (void)initDataModel {
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];

    EPPathModel *pathModel = configuration.pathModel;
    NSString *databasePath = [pathModel pathForDatabaseFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:databasePath]) {

    }
    else {
        NSError *error = nil;

        NSString *source = [[NSBundle mainBundle] pathForResource:@"epodreczniki" ofType:@"db"];
        if ([fileManager copyItemAtPath:source toPath:databasePath error:&error]) {
            [fileManager addSkipBackupAttributeToItemAtPath:databasePath];

        }
        else {

        }

        NSArray *dirs = @[
            pathModel.coversDirectory,
            pathModel.textbooksDirectory,
            pathModel.otherDirectory
        ];
        for (NSString *dir in dirs) {
            if ([fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error]) {
                [fileManager addSkipBackupAttributeToItemAtPath:pathModel.coversDirectory];

            }
            else {

            }
        }

        EPSettingsModel *settingsModel = configuration.settingsModel;
        settingsModel.userAcceptedPolicy = NO;
        settingsModel.textbookModelInitialized = NO;
        settingsModel.allowUsingCellularNetwork = EPSettingsCellularStateTypeDenied;
        settingsModel.canUserCreateAccountType = EPSettingsCanUserCreateAccountTypeDenied;

        EPUser *defaultUser = [EPUser new];
        defaultUser.state.canDownloadAndRemoveTextbooksType = EPSettingsCanDownloadAndRemoveTextbooksTypeGranted;
        defaultUser.createdDate = nil;
        [configuration.userModel createUser:defaultUser];

    }

    [configuration.settingsModel performMigration];

    [self debugAdminAccount];

    [configuration.userUtil logInDefaultUser];

    [configuration.userUtil determineState];

    if ([configuration.userUtil appRequiresUsersToLogin]) {
        [configuration.userUtil logOutUser];
    }
}

- (void)swapViewControllers {
    
#if MODE_DEVELOPER
    self.window.rootViewController = [self viewControllerWithStoryboardID:@"DownloaderViewController"];
    return;
#endif
    
}

- (void)debugAdminAccount {
#if DEBUG_ADMIN_ACCOUNT
    
    EPCryptoUtil *cryptoUtil = [EPConfiguration activeConfiguration].cryptoUtil;
    NSString *salt = [cryptoUtil createSalt];
    NSString *pass = [cryptoUtil createHashWithString:@"pass" andSalt:salt];

    EPUserModel *userModel = [EPConfiguration activeConfiguration].userModel;
    EPUser *adminUser = [userModel readAdminUser];

    adminUser.login = @"admin";

    if (!adminUser.spassword) {
        adminUser.spassword = salt;
        adminUser.hpassword = pass;
        adminUser.question = @"Pytanie odzyskiwania";
        adminUser.sanswer = salt;
        adminUser.hanswer = pass;

        adminUser.role = EPAccountRoleAdmin;




        [adminUser update];
    }
    
    EPUser *tmpUser = [userModel readUserByID:@(2)];
    if (!tmpUser) {
        tmpUser = [EPUser new];
        tmpUser.login = @"Stefan";
        tmpUser.spassword = salt;
        tmpUser.hpassword = pass;
        tmpUser.role = EPAccountRoleUser;
        [[EPConfiguration activeConfiguration].userModel createUser:tmpUser];
    }
    
    tmpUser = [userModel readUserByID:@(3)];
    if (!tmpUser) {
        tmpUser = [EPUser new];
        tmpUser.login = @"Kamil bez hasła";
        tmpUser.spassword = salt;
        tmpUser.hpassword = pass;
        tmpUser.role = EPAccountRoleUser;
        tmpUser.state.canLoginWithoutPasswordType = EPSettingsCanUserCreateAccountTypeGranted;
        [[EPConfiguration activeConfiguration].userModel createUser:tmpUser];
    }
    
    tmpUser = [userModel readUserByID:@(4)];
    if (!tmpUser) {
        tmpUser = [EPUser new];
        tmpUser.login = @"Barbar";
        tmpUser.spassword = salt;
        tmpUser.hpassword = pass;
        tmpUser.role = EPAccountRoleUser;
        [[EPConfiguration activeConfiguration].userModel createUser:tmpUser];
    }
    
    tmpUser = [userModel readUserByID:@(5)];
    if (!tmpUser) {
        tmpUser = [EPUser new];
        tmpUser.login = @"Zenon";
        tmpUser.spassword = salt;
        tmpUser.hpassword = pass;
        tmpUser.role = EPAccountRoleUser;
        [[EPConfiguration activeConfiguration].userModel createUser:tmpUser];
    }
    
#endif
}

- (void)cleanApp {
#if DEBUG_CLEAN_INSTALLATION

    
    NSString *documents = [UIApplication sharedApplication].documentsDirectory;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documents error:nil];
    for (NSString *path in directoryContents) {
        NSString *fullPath = [documents stringByAppendingPathComponent:path];
        [fileMgr removeItemAtPath:fullPath error:nil];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPreferencesKeyVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
}

- (void)recoverAfterKill {
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    
    NSString *downloadLocation = configuration.settingsModel.downloadedZipLocation;
    if (downloadLocation) {
        downloadLocation = [configuration.pathModel pathInsideLibrary:downloadLocation];
    }
    NSString *downloadRootID = configuration.settingsModel.downloadedRootID;
    
    NSString *removeLocation = configuration.settingsModel.removedZipLocation;
    if (removeLocation) {
        removeLocation = [configuration.pathModel pathInsideDocuments:removeLocation];
    }
    NSString *removeRootID = configuration.settingsModel.removedRootID;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        if (downloadLocation) {
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:downloadLocation]) {
                NSError *error = nil;
                if ([fm removeItemAtPath:downloadLocation error:&error]) {

                }
                else {

                }
            }
            else {

            }
            configuration.settingsModel.downloadedZipLocation = nil;
        }
        else {

        }
    });

    if (downloadRootID) {
        EPDownloadTextbookProxy *proxy = [configuration.downloadUtil downloadTextbookProxyForRootID:downloadRootID];
        if (proxy) {
            [proxy rollback];

        }
        else {

        }
        configuration.settingsModel.downloadedRootID = nil;
    }
    else {

    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        if (removeLocation) {
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:removeLocation]) {
                NSError *error = nil;
                if ([fm removeItemAtPath:removeLocation error:&error]) {

                }
                else {

                }
            }
            else {

            }
            configuration.settingsModel.removedZipLocation = nil;
        }
        else {

        }
    });

    if (removeRootID) {
        EPDownloadTextbookProxy *proxy = [configuration.downloadUtil downloadTextbookProxyForRootID:removeRootID];
        if (proxy) {

            NSString *contentID = proxy.storeCollection.actualContentID;

            [[EPConfiguration activeConfiguration].downloadModel setTextbookAsToDownloadWithRootID:proxy.rootID];

            [proxy updateState];

            [[EPConfiguration activeConfiguration].textbookUtil postTextbookRemoveWithRootID:proxy.rootID andContentID:contentID];

        }
        else {

        }
        configuration.settingsModel.removedRootID = nil;
    }
    else {

    }
}

- (void)debugForceListType {
#if DEBUG

    EPUser *user = [EPConfiguration activeConfiguration].user;
    if ([UIDevice currentDevice].isIPad) {
        user.state.textbooksListContainerType = EPSettingsTextbooksListContainerTypeCollection;
        [user update];
    }
    else if (user.state.textbooksListContainerType == EPSettingsTextbooksListContainerTypeCollection) {
        user.state.textbooksListContainerType = EPSettingsTextbooksListContainerTypeCarousel;
        [user update];
    }
#endif
}

- (void)askUserForNotifications {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    }
#endif
}

@end
