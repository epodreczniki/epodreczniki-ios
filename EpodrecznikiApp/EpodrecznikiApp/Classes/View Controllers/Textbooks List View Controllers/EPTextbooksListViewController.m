







#import "EPTextbooksListViewController.h"
#import "EPTextbooksListContainer.h"
#import "EPTextbooksListContainerCarouselView.h"
#import "EPTextbooksListContainerTableView.h"
#import "EPTextbooksListContainerCollectionView.h"
#import "EPTextbookViewController.h"
#import "EPTextbookDetailsViewController.h"
#import "EPTextbookDrawerViewController.h"
#import "EPPrivacyPolicyViewController.h"
#import "EPUserSettingsViewController.h"

#import "EPActionSheetHandler.h"
#import "EPAlertViewHandler.h"
#import "EPBackButtonItem.h"
#import "EPProgressHUD.h"

@interface EPTextbooksListViewController ()

@property (strong, nonatomic) EPTextbooksListContainer *container;
@property (strong, nonatomic) NSArray *textbooks;
@property (nonatomic) int selectedCollectionIndex;
@property (nonatomic, strong) UILabel *emptyListLabel;
@property (nonatomic) BOOL canCarouselLayout;

- (void)loadContainer;
- (void)refreshDataFromModel:(BOOL)forceRedownloadData;

@end

@implementation EPTextbooksListViewController

@synthesize textbooks = _textbooks;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = kApplicationName;
    self.navigationItem.backBarButtonItem = [EPBackButtonItem new];
    self.navigationController.navigationBar.tintColor = [UIColor epBlueColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.canCarouselLayout = YES;
    self.navigationItem.hidesBackButton = YES;

    self.emptyListLabel = [[UILabel alloc] init];
    self.emptyListLabel.text = NSLocalizedString(@"EPTextbooksListViewController_emptyListLabel", nil);
    if ([UIDevice currentDevice].isIPad) {
        self.emptyListLabel.frame = CGRectMake(0, 0, 400, 250);
    }
    else {
        self.emptyListLabel.frame = CGRectMake(0, 0, 280, 250);
    }
    self.emptyListLabel.backgroundColor = [UIColor clearColor];
    self.emptyListLabel.font = [UIFont systemFontOfSize:20.0f];
    self.emptyListLabel.hidden = YES;
    self.emptyListLabel.numberOfLines = 0;
    self.emptyListLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyListLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
                                         | UIViewAutoresizingFlexibleRightMargin
                                         | UIViewAutoresizingFlexibleTopMargin
                                         | UIViewAutoresizingFlexibleBottomMargin;

    self.optionsButton.accessibilityLabel = NSLocalizedString(@"Accessability_options", nil);

    [self loadContainer];

    EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;
    [self refreshDataFromModel:!(userUtil.hasDownloadedInitialTextbookList)];
    userUtil.hasDownloadedInitialTextbookList = YES;

    if ([EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
        [self voiceOverStatusChanged:YES];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textbookListFilterChangedNotification:) name:kTextbooksListFilterChangedNotification object:nil];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.selectedCollectionIndex = -1;

    [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookListCellReattachDelegateNotification object:nil];

    if (!self.isMovingToParentViewController) {
        [self loadContainer];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [EPConfiguration activeConfiguration].accessibilityUtil.delegate = self;
}

- (void)dealloc {
    self.container.dataSource = nil;
    self.container.delegate = nil;
    self.container = nil;
    self.textbooks = nil;
    self.selectedCollectionIndex = -1;
    self.emptyListLabel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"EPTextbookViewControllerSegue"]) {
        EPTextbookViewController *vc = (EPTextbookViewController *)[segue.destinationViewController topViewController];

        EPCollection *item = [self itemforIndex:self.selectedCollectionIndex];
        vc.textbookRootID = item.rootID;
    }

    else if ([segue.identifier isEqualToString:@"EPTextbookDrawerViewControllerSegue"]) {
        EPTextbookDrawerViewController *vc = (EPTextbookDrawerViewController *)segue.destinationViewController;

        EPCollection *item = [self itemforIndex:self.selectedCollectionIndex];
        vc.textbookRootID = item.rootID;
    }

    else if ([segue.identifier isEqualToString:@"EPTextbookDetailsViewControllerSegue"]) {
        EPTextbookDetailsViewController *vc = segue.destinationViewController;

        EPCollection *item = [self itemforIndex:self.selectedCollectionIndex];
        vc.textbookRootID = item.rootID;
    }
    else if ([segue.identifier isEqualToString:@"EPPrivacyPolicyViewControllerSegue"]) {
        EPPrivacyPolicyViewController *vc = segue.destinationViewController;
        vc.isFirstViewController = NO;
    }
    else if ([segue.identifier isEqualToString:@"EPUserSettingsViewControllerSegue"]) {
        EPUserSettingsViewController *vc = (EPUserSettingsViewController *)[segue.destinationViewController topViewController];
        vc.editedUser = [EPConfiguration activeConfiguration].userUtil.user;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Rotation

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self.view sendSubviewToBack:self.container];

    if (self.canCarouselLayout && self.container && self.container.containerType == EPSettingsTextbooksListContainerTypeCarousel) {
        [self.container didRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.view sendSubviewToBack:self.container];

    if (self.container.containerType == EPSettingsTextbooksListContainerTypeCollection) {
        
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.container didRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
        });
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    
    if (self.container) {
        [self.container willRotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    
    if (self.container) {
        [self.container didRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }
}

#pragma mark - Actions

- (IBAction)optionsButtonAction:(id)sender {


    self.optionsButton.enabled = NO;
    self.canCarouselLayout = NO;

    __block BOOL shouldEnableOptionsButton = YES;

    EPActionSheetHandler *asHandler = [EPActionSheetHandler new];
    asHandler.title = NSLocalizedString(@"EPTextbooksListViewController_actionSheetOptions", nil);

    [asHandler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_actionSheetRefreshList", nil) andActionBlock:^{

        EPConfiguration *configuration = [EPConfiguration activeConfiguration];
        if (!configuration.networkUtil.isNetworkReachableAndAllowed) {
            
            EPAlertViewHandler *handler = [EPAlertViewHandler new];
            handler.title = NSLocalizedString(@"EPTextbooksListViewController_noNetworkAlertViewTitle", nil);
            handler.message = NSLocalizedString(@"EPTextbooksListViewController_noNetworkAlertViewMessage", nil);
            [handler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_noNetworkAlertViewButtonOK", nil) andActionBlock:nil];
            [handler show];
            
            return;
        }

        shouldEnableOptionsButton = NO;

        [self refreshDataFromModel:YES];
    }];

    [asHandler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_actionSheetMyAccount", nil) andActionBlock:^{
        [self performSegueWithIdentifier:@"EPUserSettingsViewControllerSegue" sender:nil];
    }];
    
    EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;

    if ([userUtil canAdministrateApp]) {
        [asHandler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_actionSheetAdminSettings", nil) andActionBlock:^{
            
            [self goToAdminViewController];
        }];
    }

    [asHandler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_actionSheetPrivacyPolicy", nil) andActionBlock:^{
        [self performSegueWithIdentifier:@"EPPrivacyPolicyViewControllerSegue" sender:sender];
    }];
    [asHandler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_actionSheetAbout", nil) andActionBlock:^{
        [self performSegueWithIdentifier:@"EPAboutViewControllerSegue" sender:sender];
    }];

    if ([userUtil canLogoutUser]) {
        NSString *buttonText = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"EPTextbooksListViewController_actionSheetLogout", nil), [EPConfiguration activeConfiguration].userUtil.user.login];
        [asHandler addDestructiveButtonWithTitle:buttonText andActionBlock:^{

            [[EPConfiguration activeConfiguration].userUtil logOutUser];
            
            [self performSegueWithIdentifier:@"EPLoginUserViewControllerSegue" sender:nil];
        }];
    }

    [asHandler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_actionSheetClose", nil) andActionBlock:nil];

    [asHandler addDismissBlock:^{

        if (shouldEnableOptionsButton) {
            self.optionsButton.enabled = YES;
            self.canCarouselLayout = YES;
        }
    }];

    if ([UIDevice currentDevice].isIPad) {
        [asHandler showFromBarButtonItem:self.optionsButton animated:YES];
    }

    else {
        [asHandler showInView:self.view];
    }
}

#pragma mark - EPTextbooksListContainerDataSource

- (int)numberOfItemsForCotainer:(EPTextbooksListContainer *)container {
    
    int count = 0;

    @synchronized (self) {
        count = (int)self.textbooks.count;
    }

    
    return count;
}

- (EPCollection *)itemforIndex:(int)index {

    EPCollection *item = nil;
    
    @synchronized (self) {
        if (index >= 0 && index < self.textbooks.count) {
            item = self.textbooks[index];
        }
    }
    
    return item;
}

- (void)reloadItemAtIndex:(int)index withContentID:(NSString *)contentID {
    @synchronized (self) {
        if (index >= 0 && index < self.textbooks.count) {
            
            EPTextbookModel *textbookModel = [EPConfiguration activeConfiguration].textbookModel;
            EPCollection *textbook = [textbookModel textbookForContentID:contentID];

            if (!textbook) {
                return;
            }

            NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.textbooks];
            tmpArray[index] = textbook;
            self.textbooks = [NSArray arrayWithArray:tmpArray];
        }
    }
}

#pragma mark - EPTextbooksListContainerDelegate

- (void)container:(EPTextbooksListContainer *)container didSelectDownloadButtonAtIndex:(int)index {

    
    [self container:container didSelectDownloadOrUpdateButtonAtIndex:index download:YES];
}

- (void)container:(EPTextbooksListContainer *)container didSelectUpdateButtonAtIndex:(int)index {

    
    [self container:container didSelectDownloadOrUpdateButtonAtIndex:index download:NO];
}

- (void)container:(EPTextbooksListContainer *)container didSelectDownloadOrUpdateButtonAtIndex:(int)index download:(BOOL)download {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        EPNetworkUtil *networkUtil = [EPConfiguration activeConfiguration].networkUtil;

        if (networkUtil.isNetworkUnreachable) {

            [self downloadOrUpdateItemAtIndex:index download:download];
        }

        else if (networkUtil.isNetworkReachableAndAllowed) {
            [self downloadOrUpdateItemAtIndex:index download:download];
        }

        else {
            EPSettingsModel *settingsModel = [EPConfiguration activeConfiguration].settingsModel;
            EPAlertViewHandler *handler = [EPAlertViewHandler new];
            handler.title = NSLocalizedString(@"EPTextbooksListViewController_confirmDownloadAlertViewTitle", nil);
            handler.message = NSLocalizedString(@"EPTextbooksListViewController_confirmDownloadAlertViewMessage", nil);
            [handler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmDownloadAlertViewButtonYes", nil) andActionBlock:^{

                settingsModel.allowUsingCellularNetwork = EPSettingsCellularStateTypeAllowed;
                [self downloadOrUpdateItemAtIndex:index download:download];
            }];
            [handler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmDownloadAlertViewButtonNo", nil) andActionBlock:^{

                settingsModel.allowUsingCellularNetwork = EPSettingsCellularStateTypeDenied;
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [handler show];
            });
        }
    });
}

- (void)downloadOrUpdateItemAtIndex:(int)index download:(BOOL)download {

    NSString *rootID = [self itemforIndex:index].rootID;

    EPDownloadTextbookProxy *proxy = [[EPConfiguration activeConfiguration].downloadUtil downloadTextbookProxyForRootID:rootID];

    [proxy checkAppVersion:^(BOOL success) {

        if (success) {

            if (download) {
                [proxy download];
            }

            else {
                [[EPConfiguration activeConfiguration].windowsUtil showUpdateWindowWithProxy:proxy];
            }
        }

        else {
            [[EPConfiguration activeConfiguration].windowsUtil showAppUpdateRequiredWindow];
        }
    }];
}

- (void)container:(EPTextbooksListContainer *)container didSelectDeleteButtonAtIndex:(int)index {


    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPTextbooksListViewController_confirmDeleteAlertViewTitle", nil);
    handler.message = NSLocalizedString(@"EPTextbooksListViewController_confirmDeleteAlertViewMessage", nil);
    [handler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmDeleteAlertViewButtonYes", nil) andActionBlock:^{

        NSString *rootID = [self itemforIndex:index].rootID;

        EPDownloadTextbookProxy *proxy = [[EPConfiguration activeConfiguration].downloadUtil downloadTextbookProxyForRootID:rootID];

        BOOL canDelete = (proxy.storeCollection.state == EPTextbookStateTypeNormal || proxy.storeCollection.state == EPTextbookStateTypeToUpdate);
        if (!canDelete) {
            return;
        }

        UIView *hudParent = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        EPProgressHUD *progressHud = [EPProgressHUD showHUDAddedTo:hudParent animated:YES];
        progressHud.mode = MBProgressHUDModeIndeterminate;
        progressHud.labelText = NSLocalizedString(@"EPTextbooksListViewController_hudRemoveTextbookPending", nil);
        progressHud.removeFromSuperViewOnHide = YES;

        [proxy removeWithCompletion:^(BOOL success) {

            if (success) {
                progressHud.labelText = NSLocalizedString(@"EPTextbooksListViewController_hudRemoveTextbookSuccess", nil);
                [progressHud showOkIcon];
            }
            else {
                progressHud.labelText = NSLocalizedString(@"EPTextbooksListViewController_hudRemoveTextbookError", nil);
                [progressHud showErrorIcon];
            }
            [progressHud addCloseHandler];
            [progressHud hide:YES afterDelay:3.0f];
        }];
    }];
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmDeleteAlertViewButtonNo", nil) andActionBlock:nil];
    [handler show];
}

- (void)container:(EPTextbooksListContainer *)container didSelectCancelButtonAtIndex:(int)index {


    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPTextbooksListViewController_confirmCancelAlertViewTitle", nil);
    handler.message = NSLocalizedString(@"EPTextbooksListViewController_confirmCancelAlertViewMessage", nil);
    [handler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmCancelAlertViewButtonYes", nil) andActionBlock:^{

        NSString *rootID = [self itemforIndex:index].rootID;

        EPDownloadTextbookProxy *proxy = [[EPConfiguration activeConfiguration].downloadUtil downloadTextbookProxyForRootID:rootID];

        if (proxy.storeCollection.state == EPTextbookStateTypeDownloading || proxy.storeCollection.state == EPTextbookStateTypeUpdating) {
            [proxy cancel];
        }
    }];
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmCancelAlertViewButtonNo", nil) andActionBlock:nil];
    [handler show];
}

- (void)container:(EPTextbooksListContainer *)container didSelectReadButtonAtIndex:(int)index {


    if (self.navigationController.visibleViewController == self) {

        self.selectedCollectionIndex = index;
        
        EPCollection *collection = [self itemforIndex:index];
        EPDownloadTextbookProxy *proxy = [[EPConfiguration activeConfiguration].downloadUtil downloadTextbookProxyForRootID:collection.rootID];

        if ([[EPConfiguration activeConfiguration].textbookUtil textbookRequiresAdvancedReaderWithProxy:proxy]) {
            
            [self performSegueWithIdentifier:@"EPTextbookDrawerViewControllerSegue" sender:self];
        }

        else {
            
            [self performSegueWithIdentifier:@"EPTextbookViewControllerSegue" sender:self];
        }
    }
}

- (void)container:(EPTextbooksListContainer *)container didSelectDetailsButtonAtIndex:(int)index {


    if (self.navigationController.visibleViewController == self) {

        self.selectedCollectionIndex = index;
        
        [self performSegueWithIdentifier:@"EPTextbookDetailsViewControllerSegue" sender:nil];
    }
}

- (void)container:(EPTextbooksListContainer *)container didRaiseError:(NSError *)error atIndex:(int)index {

    
    [[EPConfiguration activeConfiguration].windowsUtil showTextbookDownloadError:error];
}

#pragma mark - Private methods

- (void)loadContainer {
    EPUser *user = [EPConfiguration activeConfiguration].user;
    EPSettingsTextbooksListContainerType containerType = user.state.textbooksListContainerType;

    if (self.container.containerType == containerType) {

        return;
    }

    self.navigationController.navigationBar.translucent = NO;

    if (self.container) {

        
        self.container.dataSource = nil;
        self.container.delegate = nil;
        [self.container removeFromSuperview];
        [self.emptyListLabel removeFromSuperview];
    }

    if (containerType == EPSettingsTextbooksListContainerTypeCarousel) {

        
        self.container = [EPTextbooksListContainerCarouselView viewWithNibName:@"EPTextbooksListContainerCarouselView"];
    }
    else if (containerType == EPSettingsTextbooksListContainerTypeTable) {

        
        self.container = [EPTextbooksListContainerTableView viewWithNibName:@"EPTextbooksListContainerTableView"];
    }
    else if (containerType == EPSettingsTextbooksListContainerTypeCollection) {

        
        self.container = [EPTextbooksListContainerCollectionView viewWithNibName:@"EPTextbooksListContainerCollectionView"];
    }
    else {
        NSAssert(YES, @"Unknown container type");
    }

    self.container.frame = self.view.bounds;
    self.container.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.container];
    [self.view addSubview:self.emptyListLabel];

    self.navigationController.navigationBar.translucent = YES;
    self.emptyListLabel.center = self.view.center;

    self.container.dataSource = self;
    self.container.delegate = self;


    if (self.textbooks.count > 0) {
        [self.container reloadData];
    }
}

- (void)refreshDataFromModel:(BOOL)forceRedownloadData {

    self.optionsButton.enabled = NO;
    self.canCarouselLayout = NO;

    EPProgressHUD *progressHud = [EPProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    progressHud.mode = MBProgressHUDModeIndeterminate;
    progressHud.labelText = NSLocalizedString(@"EPTextbooksListViewController_hudPleaseWait", nil);
    progressHud.removeFromSuperViewOnHide = YES;

    if (forceRedownloadData) {
        
        BOOL force = (self.textbooks && self.textbooks.count == 0);
        [[EPConfiguration activeConfiguration].downloadUtil downloadDataFromAPIWithHud:progressHud force:force];
    }

    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    [configuration.textbookUtil fetchArrayWithTextbookDataAndCompletion:^(NSArray *arrayOfData) {

        [progressHud hide:YES];

        self.optionsButton.enabled = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.canCarouselLayout = YES;
        });

        if (arrayOfData.count > 0) {

        }
        else {

        }

        @synchronized (self) {
            self.textbooks = arrayOfData;
        }

        self.emptyListLabel.hidden = (arrayOfData.count > 0);

        [self.container reloadData];

        [configuration.downloadUtil updateProxies];

        [configuration.localNotificationUtil cancelAllLocalNotifications];
        NSString *message = NSLocalizedString(@"EPAppDelegate_alertRemindAboutTextbookListUpdateMessage", nil);
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:kTimeIntervalForReminderAboutTextbookListRefresh];
        [configuration.localNotificationUtil postLocalNotificationWithMessage:message andFireDate:fireDate];
    }];
}

- (void)goToAdminViewController {
    EPWindowsUtil *windowUtil = [EPConfiguration activeConfiguration].windowsUtil;
    [windowUtil askForPasswordToAccessAdminSettings:^{
        
        [self performSegueWithIdentifier:@"EPAdminSettingsViewControllerSegue" sender:nil];
    }];
}

#pragma mark - EPAccessibilityUtilDelegate

- (void)voiceOverStatusChanged:(BOOL)enabled {
    if (enabled) {

        EPUser *user = [EPConfiguration activeConfiguration].user;
        if (user.state.textbooksListContainerType == EPSettingsTextbooksListContainerTypeCarousel) {
            user.state.textbooksListContainerType = EPSettingsTextbooksListContainerTypeTable;
            [user update];
            [self loadContainer];
        }
        else if (user.state.textbooksListContainerType == EPSettingsTextbooksListContainerTypeCollection) {
            [self.container reloadData];
        }
    }
}

#pragma mark - Notifications

- (void)textbookListFilterChangedNotification:(NSNotification *)notification {
    [self refreshDataFromModel:NO];
}

@end
