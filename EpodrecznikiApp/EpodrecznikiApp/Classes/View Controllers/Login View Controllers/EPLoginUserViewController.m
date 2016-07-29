







#import "EPLoginUserViewController.h"
#import "EPUserRecoverPasswordViewController.h"
#import "EPUserCreateViewController.h"
#import "EPUserRecoverPasswordViewController.h"

typedef NS_ENUM(NSInteger, EPLoginUserViewControllerSections) {
    EPLoginUserViewControllerSectionEmpty               = 0,
    EPLoginUserViewControllerSectionUser                = 1,
    EPLoginUserViewControllerSectionPassword            = 2,
    EPLoginUserViewControllerSectionError               = 3,
    EPLoginUserViewControllerSectionButtons             = 4
};

@interface EPLoginUserViewController ()

@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic) BOOL showsPasswordCell;

@end

@implementation EPLoginUserViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = NSLocalizedString(@"EPLoginUserViewController_navigationBarTitle", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.isMovingToParentViewController) {
        [self resetViewController];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    if (![configuration.userUtil appRequiresUsersToLogin]) {
        [self performSegueWithIdentifier:@"EPNoInternetViewControllerSegue" sender:nil];
        return;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EPUserRecoverPasswordViewControllerSegue"]) {
        
        EPUserRecoverPasswordViewController *viewController = (EPUserRecoverPasswordViewController *)[segue.destinationViewController topViewController];
        viewController.user = self.loginChooseUserCell.selectedUser;
    }
    else if ([segue.identifier isEqualToString:@"EPUserCreateViewControllerSegue"]) {
        
        EPUserCreateViewController *viewController = (EPUserCreateViewController *)[segue.destinationViewController topViewController];
        viewController.shouldDismissViewController = YES;
        viewController.isCreatingAnAdminAccount = NO;
    }
}

#pragma mark - Public methods

- (IBAction)unwindToLoginScreen:(UIStoryboardSegue *)segue {

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == EPLoginUserViewControllerSectionEmpty) {
        return ([UIDevice currentDevice].isIPhone ? 0 : 1);
    }
    if (section == EPLoginUserViewControllerSectionUser) {
        return 1;
    }
    if (section == EPLoginUserViewControllerSectionPassword) {
        return (self.showsPasswordCell ? 1 : 0);
    }
    if (section == EPLoginUserViewControllerSectionError) {
        return (self.errorMessage == nil ? 0 : 1);
    }
    if (section == EPLoginUserViewControllerSectionButtons) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == EPLoginUserViewControllerSectionEmpty) {
        
        EPLoginEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
        return cell;
    }
    else if (indexPath.section == EPLoginUserViewControllerSectionUser) {
        
        EPLoginChooseUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        cell.chooseUserTextField.enabled = YES;
        cell.delegate = self;
        [cell reloadData];
        
        return cell;
    }
    else if (indexPath.section == EPLoginUserViewControllerSectionPassword) {
        
        EPLoginPasswordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordCell"];
        cell.passwordTextField.enabled = YES;
        cell.passwordTextField.text = @"";
        cell.delegate = self;
        return cell;
    }
    else if (indexPath.section == EPLoginUserViewControllerSectionError) {
        
        EPLoginErrorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ErrorCell"];
        cell.errorLabel.text = self.errorMessage;
        return cell;
    }
    else if (indexPath.section == EPLoginUserViewControllerSectionButtons) {
        
        EPLoginButtonsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonsCell"];
        cell.loginButton.enabled = NO;
        cell.recoverPasswordButton.hidden = YES;
        cell.recoverPasswordButton.enabled = YES;
        
        EPSettingsCanUserCreateAccountType type = [EPConfiguration activeConfiguration].settingsModel.canUserCreateAccountType;
        cell.createAccountButton.hidden = (type != EPSettingsCanUserCreateAccountTypeGranted);
        cell.createAccountButton.enabled = YES;
        cell.delegate = self;
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == EPLoginUserViewControllerSectionEmpty) {
        if ([UIApplication sharedApplication].isPortrait) {
            return 260.0f;
        }
        else {
            return 130.0f;
        }
    }
    if (indexPath.section == EPLoginUserViewControllerSectionUser) {
        return 60.0f;
    }
    if (indexPath.section == EPLoginUserViewControllerSectionPassword) {
        return 60.0f;
    }
    if (indexPath.section == EPLoginUserViewControllerSectionError) {
        return 60.0f;
    }
    if (indexPath.section == EPLoginUserViewControllerSectionButtons) {
        return 135.0f;
    }
    
    return 0.0f;
}

#pragma mark - EPLoginButtonsCellDelegate

- (void)didTapLoginButtonInCell:(EPLoginButtonsCell *)cell {
    
    EPLoginChooseUserCell *loginChooseUserCell = self.loginChooseUserCell;
    EPLoginPasswordCell *loginPasswordCell = self.loginPasswordCell;
    EPLoginButtonsCell *loginButtonsCell = self.loginButtonsCell;

    [loginChooseUserCell dismissKeyboard];
    [loginPasswordCell dismissKeyboard];

    loginChooseUserCell.chooseUserTextField.enabled = NO;
    loginPasswordCell.passwordTextField.enabled = NO;
    loginButtonsCell.loginButton.enabled = NO;
    BOOL recoverPasswordButtonState = loginButtonsCell.recoverPasswordButton.enabled;
    loginButtonsCell.recoverPasswordButton.enabled = NO;
    BOOL createNewAccountButtonState = loginButtonsCell.createAccountButton.enabled;
    loginButtonsCell.createAccountButton.enabled = NO;

    EPUser *user = loginChooseUserCell.selectedUser;
    NSString *password = loginPasswordCell.passwordTextField.text;
    EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;

    if (user.state.canLoginWithoutPassword) {

        [userUtil logInUser:user];
        
        [self performSegueWithIdentifier:@"EPNoInternetViewControllerSegue" sender:nil];
        return;
    }

    if ([userUtil verifyPassword:password withUser:user]) {

        [userUtil logInUser:user];
        
        [self performSegueWithIdentifier:@"EPNoInternetViewControllerSegue" sender:nil];
    }

    else {
        self.errorMessage = NSLocalizedString(@"EPLoginUserViewController_errorMessagePasswordInvalid", nil);
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:EPLoginUserViewControllerSectionError] withRowAnimation:UITableViewRowAnimationNone];

        loginChooseUserCell.chooseUserTextField.enabled = YES;
        loginPasswordCell.passwordTextField.enabled = YES;
        loginButtonsCell.loginButton.enabled = YES;
        loginButtonsCell.recoverPasswordButton.enabled = recoverPasswordButtonState;
        loginButtonsCell.createAccountButton.enabled = createNewAccountButtonState;
    }
}

- (void)didTapRecoverPasswordButtonInCell:(EPLoginButtonsCell *)cell {

    [self.loginChooseUserCell dismissKeyboard];
    [self.loginPasswordCell dismissKeyboard];
    
    [self performSegueWithIdentifier:@"EPUserRecoverPasswordViewControllerSegue" sender:nil];
}

- (void)didTapCreateAccountButtonInCell:(EPLoginButtonsCell *)cell {

    [self.loginChooseUserCell dismissKeyboard];
    [self.loginPasswordCell dismissKeyboard];
    
    [self performSegueWithIdentifier:@"EPUserCreateViewControllerSegue" sender:nil];
}

#pragma mark - EPLoginChooseUserCellDelegate

- (NSArray *)usersArrayForCell:(EPLoginChooseUserCell *)cell {
    return [[EPConfiguration activeConfiguration].userModel allUsersByType];
}

- (void)didSelectUser:(EPUser *)user inCell:(EPLoginChooseUserCell *)cell {
    if ([NSObject isNullOrEmpty:user]) {
        return;
    }
    
#if DEBUG_ADMIN_NO_PASS
    if (user.role == EPAccountRoleAdmin) {
        user.state.canLoginWithoutPasswordType = EPSettingsCanDownloadAndRemoveTextbooksTypeGranted;
    }
#endif

    EPLoginButtonsCell *buttonsCell = self.loginButtonsCell;
    buttonsCell.recoverPasswordButton.hidden = (user.role != EPAccountRoleAdmin);

    self.showsPasswordCell = !user.state.canLoginWithoutPassword;
    buttonsCell.loginButton.enabled = user.state.canLoginWithoutPassword;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:EPLoginUserViewControllerSectionPassword] withRowAnimation:UITableViewRowAnimationNone];

    if (self.errorMessage) {
        self.errorMessage = nil;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:EPLoginUserViewControllerSectionError] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - EPLoginPasswordCellDelegate

- (void)didChangePassword:(NSString *)password inCell:(EPLoginPasswordCell *)cell {
    self.loginButtonsCell.loginButton.enabled = (password.length > 0);

    if (self.errorMessage) {
        self.errorMessage = nil;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:EPLoginUserViewControllerSectionError] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Private methods

- (BOOL)isSelectedUserAnAdmin {
    EPUser *user = self.loginChooseUserCell.selectedUser;
    return user && (user.role == EPAccountRoleAdmin);
}

- (void)resetViewController {

    [self.loginChooseUserCell reloadData];
    self.errorMessage = nil;
    self.showsPasswordCell = NO;

    [self.tableView reloadData];
}

#pragma mark - Cells

- (EPLoginChooseUserCell *)loginChooseUserCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:EPLoginUserViewControllerSectionUser];
    return (EPLoginChooseUserCell *)[self.tableView cellForRowAtIndexPath:indexPath];
}

- (EPLoginPasswordCell *)loginPasswordCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:EPLoginUserViewControllerSectionPassword];
    return (EPLoginPasswordCell *)[self.tableView cellForRowAtIndexPath:indexPath];
}

- (EPLoginErrorCell *)loginErrorCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:EPLoginUserViewControllerSectionError];
    return (EPLoginErrorCell *)[self.tableView cellForRowAtIndexPath:indexPath];
}

- (EPLoginButtonsCell *)loginButtonsCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:EPLoginUserViewControllerSectionButtons];
    return (EPLoginButtonsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
}

@end
