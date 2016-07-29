







#import "EPNoInternetViewController.h"
#import "EPProgressHUD.h"

@interface EPNoInternetViewController ()

@property (nonatomic, strong) dispatch_queue_t backgroundQueue;
@property (nonatomic) BOOL textbookModelInitialized;

- (void)handleNetworkStatus:(BOOL)useCellular;
- (BOOL)updateDatabaseWithHud:(EPProgressHUD *)hud;

@end

@implementation EPNoInternetViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleLabel.text = NSLocalizedString(@"EPNoInternetViewController_titleLabel", nil);
    self.messageLabel.text = NSLocalizedString(@"EPNoInternetViewController_messageLabel", nil);
    [self.tryAgainButtonWiFI setTitle:NSLocalizedString(@"EPNoInternetViewController_tryAgainButtonWiFi", nil) forState:UIControlStateNormal];
    [self.tryAgainButtonCellular setTitle:NSLocalizedString(@"EPNoInternetViewController_tryAgainButtonCellular", nil) forState:UIControlStateNormal];
    self.backgroundQueue = dispatch_queue_create("pl.psnc.no-internet", NULL);
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    self.tryAgainButtonWiFI.enabled = configuration.networkUtil.isWifiReachable;
    self.tryAgainButtonCellular.enabled = configuration.networkUtil.isCellularReachable;
    self.textbookModelInitialized = configuration.settingsModel.textbookModelInitialized;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.textbookModelInitialized || self.tryAgainButtonWiFI.enabled) {
        [self performSegueWithIdentifier:@"EPTextbooksListViewControllerSegue" sender:nil];
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChangedNotification:) name:kReachabilityChangedNotification object:nil];
    [[EPConfiguration activeConfiguration].networkUtil startNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EPConfiguration activeConfiguration].networkUtil stopNotifications];
}

- (void)dealloc {
    self.backgroundQueue = nil;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    CGFloat kMargin = 10.0f;
    CGSize screenSize;
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
        screenSize = [UIScreen mainScreen].portraitScreenSize;
    }
    else {
        screenSize = [UIScreen mainScreen].landscapeScreenSize;
    }

    CGPoint center = CGPointMake(screenSize.width / 2.0f, screenSize.height / 2.0f);
    [self.messageLabel setCenter:center];

    self.titleLabel.center = CGPointMake(center.x, center.y -
        self.messageLabel.frame.size.height / 2.0f - self.titleLabel.frame.size.height / 2.0f - kMargin
    );

    self.tryAgainButtonWiFI.center = CGPointMake(center.x, center.y +
        self.messageLabel.frame.size.height / 2.0f + self.tryAgainButtonWiFI.frame.size.height / 2.0f + kMargin
    );

    center = self.tryAgainButtonWiFI.center;
    self.tryAgainButtonCellular.center = CGPointMake(center.x, center.y +
        self.tryAgainButtonWiFI.frame.size.height / 2.0f + self.tryAgainButtonCellular.frame.size.height / 2.0f + kMargin
    );
}

#pragma mark - Notifications

- (void)networkStatusChangedNotification:(NSNotification *)aNotification {


    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    self.tryAgainButtonWiFI.enabled = configuration.networkUtil.isWifiReachable;
    self.tryAgainButtonCellular.enabled = configuration.networkUtil.isCellularReachable;
}

#pragma mark - Actions

- (void)tryAgainButtonWiFIAction:(id)sender {


    if (!self.tryAgainButtonWiFI.enabled) {
        return;
    }

    self.tryAgainButtonWiFI.enabled = NO;
    self.tryAgainButtonCellular.enabled = NO;
    BOOL useCellular = NO;

    [self handleNetworkStatus:useCellular];
}

- (void)tryAgainButtonCellularAction:(id)sender {


    if (!self.tryAgainButtonCellular.enabled) {
        return;
    }

    self.tryAgainButtonWiFI.enabled = NO;
    self.tryAgainButtonCellular.enabled = NO;
    BOOL useCellular = YES;

    [self handleNetworkStatus:useCellular];
}

#pragma mark - Private methods

- (void)handleNetworkStatus:(BOOL)useCellular {


    EPProgressHUD *progressHud = [EPProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.mode = MBProgressHUDModeIndeterminate;
    progressHud.labelText = NSLocalizedString(@"EPNoInternetViewController_hudPleaseWait", nil);
    progressHud.removeFromSuperViewOnHide = YES;

    dispatch_barrier_async(self.backgroundQueue, ^{

        [NSThread sleepForTimeInterval:2.0f];

        EPConfiguration *configuration = [EPConfiguration activeConfiguration];

        if (useCellular) {

            if (configuration.networkUtil.isCellularReachable) {
                if ([self updateDatabaseWithHud:progressHud]) {
                    return;
                }
            }
        }

        else {

            if (configuration.networkUtil.isWifiReachable) {
                if ([self updateDatabaseWithHud:progressHud]) {
                    return;
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            [self networkStatusChangedNotification:nil];

            [progressHud setHidden:YES];
        });
    });
}

- (BOOL)updateDatabaseWithHud:(EPProgressHUD *)hud {
    
    BOOL success = NO;

    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    [configuration.downloadUtil downloadDataFromAPIWithHud:hud force:YES];
    [configuration.downloadUtil waitForDownloadDataFromAPI];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud setHidden:YES];
    });

    if (configuration.settingsModel.textbookModelInitialized) {

        [NSThread sleepForTimeInterval:0.3f];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"EPTextbooksListViewControllerSegue" sender:nil];
        });

        success = YES;
    }
    
    return success;
}

@end
