







#import "EPUserSettingsViewController.h"
#import "EPUserCreateViewController.h"
#import "EPBackButtonItem.h"

typedef NS_ENUM(NSInteger, EPUserSettingsViewControllerSections) {
    EPUserSettingsViewControllerSectionsEditAccount             = 0,
    EPUserSettingsViewControllerSectionsTextbookVariant         = 1,
    EPUserSettingsViewControllerSectionsLoginMode               = 2,
    EPUserSettingsViewControllerSectionsListMode                = 3,
    EPUserSettingsViewControllerSectionsFilter                  = 4
};

@implementation EPUserSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    EPUser *user = [EPConfiguration activeConfiguration].user;
    if (user.role == EPAccountRoleUnknown) {
        self.navigationItem.title = NSLocalizedString(@"EPUserSettingsViewController_navigationBarTitle", nil);
    }
    else {
        self.navigationItem.title = [EPConfiguration activeConfiguration].user.login;
    }
    
    self.navigationItem.backBarButtonItem = [EPBackButtonItem new];
    self.cancelButton.title = NSLocalizedString(@"EPUserSettingsViewController_cancelButtonTitle", nil);
    [self.editAccountButton setTitle:NSLocalizedString(@"EPUserSettingsViewController_editAccountButtonTitle", nil) forState:UIControlStateNormal];
    [self.changeFilterButton setTitle:NSLocalizedString(@"EPUserSettingsViewController_changeFilterButtonTitle", nil) forState:UIControlStateNormal];
    [self.textbookVariantSegmentedControl setTitle:NSLocalizedString(@"EPUserSettingsViewController_textbookVariantSegmentedControlStudent", nil) forSegmentAtIndex:0];
    [self.textbookVariantSegmentedControl setTitle:NSLocalizedString(@"EPUserSettingsViewController_textbookVariantSegmentedControlTeacher", nil) forSegmentAtIndex:1];
    [self.loginModeSegmentedControl setTitle:NSLocalizedString(@"EPUserSettingsViewController_loginModeSegmentedControlWithPass", nil) forSegmentAtIndex:0];
    [self.loginModeSegmentedControl setTitle:NSLocalizedString(@"EPUserSettingsViewController_loginModeSegmentedControlNoPass", nil) forSegmentAtIndex:1];
    [self.listModeSegmentedControl setTitle:NSLocalizedString(@"EPUserSettingsViewController_listModeSegmentedControlCovers", nil) forSegmentAtIndex:0];
    [self.listModeSegmentedControl setTitle:NSLocalizedString(@"EPUserSettingsViewController_listModeSegmentedControlList", nil) forSegmentAtIndex:1];

    if (self.editedUser.state.textbookVariantType == EPSettingsTextbookVariantTypeStudent) {

        self.textbookVariantSegmentedControl.selectedSegmentIndex = 0;
    }
    else {

        self.textbookVariantSegmentedControl.selectedSegmentIndex = 1;
    }
    if (self.editedUser.state.canLoginWithoutPasswordType == EPSettingsCanLoginWithoutPasswordTypeDenied) {

        self.loginModeSegmentedControl.selectedSegmentIndex = 0;
    }
    else {

        self.loginModeSegmentedControl.selectedSegmentIndex = 1;
    }
    if ([UIDevice currentDevice].isIPhone && ![EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
        
        if (self.editedUser.state.textbooksListContainerType == EPSettingsTextbooksListContainerTypeCarousel) {

            self.listModeSegmentedControl.selectedSegmentIndex = 0;
        }
        else {

            self.listModeSegmentedControl.selectedSegmentIndex = 1;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EPUserCreateViewControllerSegue"]) {
        
        EPUserCreateViewController *viewController = segue.destinationViewController;
        viewController.shouldDismissViewController = NO;
        viewController.isCreatingAnAdminAccount = NO;
        viewController.editedUser = self.editedUser;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == EPUserSettingsViewControllerSectionsEditAccount) {
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        if (state == EPAppStateAnonymousAccount) {
            return 0;
        }
    }
    if (section == EPUserSettingsViewControllerSectionsLoginMode) {
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        if (state == EPAppStateAnonymousAccount) {
            return 0;
        }
    }
    
    if (section == EPUserSettingsViewControllerSectionsListMode) {
        if ([UIDevice currentDevice].isIPad || [EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
            return 0;
        }
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == EPUserSettingsViewControllerSectionsEditAccount) {
        
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        if (state == EPAppStateAnonymousAccount) {
            return nil;
        }
        
        return NSLocalizedString(@"EPUserSettingsViewController_sectionsEditAccount", nil);
    }
    if (section == EPUserSettingsViewControllerSectionsTextbookVariant) {
        return NSLocalizedString(@"EPUserSettingsViewController_sectionsTextbookVariant", nil);
    }
    if (section == EPUserSettingsViewControllerSectionsLoginMode) {
        
        EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
        if (state == EPAppStateAnonymousAccount) {
            return nil;
        }
        
        return NSLocalizedString(@"EPUserSettingsViewController_sectionsLoginMode", nil);
    }
    if (section == EPUserSettingsViewControllerSectionsListMode) {
        if ([UIDevice currentDevice].isIPad || [EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
            return nil;
        }
        
        return NSLocalizedString(@"EPUserSettingsViewController_sectionsListMode", nil);
    }
    if (section == EPUserSettingsViewControllerSectionsFilter) {
        return NSLocalizedString(@"EPUserSettingsViewController_sectionsFilter", nil);
    }
    
    return nil;
}

#pragma mark - Actions

- (IBAction)textbookVariantSegmentedControlValueChanged:(id)sender {

    if (self.textbookVariantSegmentedControl.selectedSegmentIndex == 0) {
        
        self.editedUser.state.textbookVariantType = EPSettingsTextbookVariantTypeStudent;
    }

    else if (self.textbookVariantSegmentedControl.selectedSegmentIndex == 1) {
        
        self.editedUser.state.textbookVariantType = EPSettingsTextbookVariantTypeTeacher;
    }

    [self.editedUser update];
}

- (IBAction)loginModeSegmentedControlValueChanged:(id)sender {

    if (self.loginModeSegmentedControl.selectedSegmentIndex == 0) {
        
        self.editedUser.state.canLoginWithoutPasswordType = EPSettingsCanLoginWithoutPasswordTypeDenied;
    }

    else if (self.loginModeSegmentedControl.selectedSegmentIndex == 1) {
        
        self.editedUser.state.canLoginWithoutPasswordType = EPSettingsCanLoginWithoutPasswordTypeGranted;
    }

    [self.editedUser update];
    [[EPConfiguration activeConfiguration].userUtil determineState];
}

- (IBAction)listModeSegmentedControlValueChanged:(id)sender {

    if (self.listModeSegmentedControl.selectedSegmentIndex == 0) {
        
        self.editedUser.state.textbooksListContainerType = EPSettingsTextbooksListContainerTypeCarousel;
        [self.editedUser update];
    }

    else if (self.listModeSegmentedControl.selectedSegmentIndex == 1) {
        
        self.editedUser.state.textbooksListContainerType = EPSettingsTextbooksListContainerTypeTable;
        [self.editedUser update];
    }
}

- (IBAction)editAccountButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"EPUserCreateViewControllerSegue" sender:nil];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeFilterButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"EPTextbookFilterViewControllerSegue" sender:nil];
}

@end
