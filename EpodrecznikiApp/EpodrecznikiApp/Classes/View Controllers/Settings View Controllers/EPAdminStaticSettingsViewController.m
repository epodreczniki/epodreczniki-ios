







#import "EPAdminStaticSettingsViewController.h"
#import "EPUserCreateViewController.h"

typedef NS_ENUM(NSInteger, EPAdminStaticSettingsViewControllerSections) {
    EPAdminStaticSettingsViewControllerSectionsAllowCellular                            = 0,
    EPAdminStaticSettingsViewControllerSectionsAllowCreateAccountAtLoginScreen          = 1,
    EPAdminStaticSettingsViewControllerSectionsButtonCreateAdmin                        = 2,
    EPAdminStaticSettingsViewControllerSectionsButtonCreateUser                         = 3
};

@implementation EPAdminStaticSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.createAdminButton setTitle:NSLocalizedString(@"EPAdminStaticSettingsViewController_createAdminButtonTitle", nil) forState:UIControlStateNormal];
    [self.createUserButton setTitle:NSLocalizedString(@"EPAdminStaticSettingsViewController_createUserButtonTitle", nil) forState:UIControlStateNormal];
    [self.createNewAccountSegmentedControl setTitle:NSLocalizedString(@"EPAdminStaticSettingsViewController_createNewAccountSegmentedControlAllow", nil) forSegmentAtIndex:0];
    [self.createNewAccountSegmentedControl setTitle:NSLocalizedString(@"EPAdminStaticSettingsViewController_createNewAccountSegmentedControlDeny", nil) forSegmentAtIndex:1];
    [self.cellularNetworkSegmentedControl setTitle:NSLocalizedString(@"EPAdminStaticSettingsViewController_cellularNetworkSegmentedControlAllow", nil) forSegmentAtIndex:0];
    [self.cellularNetworkSegmentedControl setTitle:NSLocalizedString(@"EPAdminStaticSettingsViewController_cellularNetworkSegmentedControlDeny", nil) forSegmentAtIndex:1];

    EPSettingsModel *settings = [EPConfiguration activeConfiguration].settingsModel;
    if (settings.allowUsingCellularNetwork == EPSettingsCellularStateTypeAllowed) {
        self.cellularNetworkSegmentedControl.selectedSegmentIndex = 0;
    }
    else {
        self.cellularNetworkSegmentedControl.selectedSegmentIndex = 1;
    }
    if (settings.canUserCreateAccountType == EPSettingsCanUserCreateAccountTypeGranted) {
        self.createNewAccountSegmentedControl.selectedSegmentIndex = 0;
    }
    else {
        self.createNewAccountSegmentedControl.selectedSegmentIndex = 1;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EPCreateAdminSegue"]) {
        EPUserCreateViewController *vc = segue.destinationViewController;
        vc.isCreatingAnAdminAccount = YES;
        vc.shouldDismissViewController = NO;
    }
    else if ([segue.identifier isEqualToString:@"EPCreateStandarAccountSegue"]) {
        EPUserCreateViewController *vc = segue.destinationViewController;
        vc.isCreatingAnAdminAccount = NO;
        vc.shouldDismissViewController = NO;
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == EPAdminStaticSettingsViewControllerSectionsAllowCellular) {
        return NSLocalizedString(@"EPAdminStaticSettingsViewController_sectionCellular", nil);
    }
    if (section == EPAdminStaticSettingsViewControllerSectionsAllowCreateAccountAtLoginScreen) {
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        if (state == EPAppStateAnonymousAccount) {
            return nil;
        }
        return NSLocalizedString(@"EPAdminStaticSettingsViewController_sectionCreateAccountAtLoginScreen", nil);
    }
    if (section == EPAdminStaticSettingsViewControllerSectionsButtonCreateAdmin) {
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        if (state == EPAppStateAnonymousAccount) {
            return NSLocalizedString(@"EPAdminStaticSettingsViewController_sectionCreateAdmin", nil);
        }
    }
    if (section == EPAdminStaticSettingsViewControllerSectionsButtonCreateUser) {
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        if (state != EPAppStateAnonymousAccount) {
            return NSLocalizedString(@"EPAdminStaticSettingsViewController_sectionCreateUser", nil);
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == EPAdminStaticSettingsViewControllerSectionsAllowCreateAccountAtLoginScreen) {
        
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        return (state == EPAppStateAnonymousAccount ? 0 : 1);
    }
    if (section == EPAdminStaticSettingsViewControllerSectionsButtonCreateAdmin) {
        
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        return (state == EPAppStateAnonymousAccount ? 1 : 0);
    }
    if (section == EPAdminStaticSettingsViewControllerSectionsButtonCreateUser) {
        
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        return (state == EPAppStateAnonymousAccount ? 0 : 1);
    }
    
    return 1;
}

#pragma mark - Actions

- (IBAction)createAdminButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCreateAdminAccountInViewController:)]) {
        [self.delegate didSelectCreateAdminAccountInViewController:self];
    }
}

- (IBAction)createUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCreateUserAccountInViewController:)]) {
        [self.delegate didSelectCreateUserAccountInViewController:self];
    }
}

- (IBAction)allowCellularSegmentedControlValueChanged:(id)sender {
    
    if (self.cellularNetworkSegmentedControl.selectedSegmentIndex == 0) {
        
        EPSettingsModel *settings = [EPConfiguration activeConfiguration].settingsModel;
        settings.allowUsingCellularNetwork = EPSettingsCellularStateTypeAllowed;
    }
    else if (self.cellularNetworkSegmentedControl.selectedSegmentIndex == 1) {
        
        EPSettingsModel *settings = [EPConfiguration activeConfiguration].settingsModel;
        settings.allowUsingCellularNetwork = EPSettingsCellularStateTypeDenied;
    }
}

- (IBAction)allowCreateNewAccountAtLoginScreenSegmentedControlValueChanged:(id)sender {
    
    if (self.createNewAccountSegmentedControl.selectedSegmentIndex == 0) {
        
        EPSettingsModel *settings = [EPConfiguration activeConfiguration].settingsModel;
        settings.canUserCreateAccountType = EPSettingsCanUserCreateAccountTypeGranted;
    }
    else if (self.createNewAccountSegmentedControl.selectedSegmentIndex == 1) {
        
        EPSettingsModel *settings = [EPConfiguration activeConfiguration].settingsModel;
        settings.canUserCreateAccountType = EPSettingsCanUserCreateAccountTypeDenied;
    }
}

@end
