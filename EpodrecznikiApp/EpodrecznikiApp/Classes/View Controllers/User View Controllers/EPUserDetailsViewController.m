







#import "EPUserDetailsViewController.h"
#import "EPUserModel.h"
#import "EPAlertViewHandler.h"

typedef NS_ENUM(NSInteger, EPUserDetailsViewControllerSections) {
    EPUserDetailsViewControllerSectionsPassword                 = 0,
    EPUserDetailsViewControllerSectionsAllowDownload            = 1,
    EPUserDetailsViewControllerSectionsDeleteUser               = 2
};

@implementation EPUserDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.title = self.editedUser.login;
    [self.savePasswordButton setTitle:NSLocalizedString(@"EPUserDetailsViewController_savePasswordButtonTitle", nil) forState:UIControlStateNormal];
    [self.deleteAccountButton setTitle:NSLocalizedString(@"EPUserDetailsViewController_deleteAccountButtonTitle", nil) forState:UIControlStateNormal];
    [self.allowDownloadAndUpdateSegmentedControl setTitle:NSLocalizedString(@"EPUserDetailsViewController_allowDownloadAndUpdateSegmentedControlAllow", nil) forSegmentAtIndex:0];
    [self.allowDownloadAndUpdateSegmentedControl setTitle:NSLocalizedString(@"EPUserDetailsViewController_allowDownloadAndUpdateSegmentedControlDeny", nil) forSegmentAtIndex:1];
    self.passwordTextField.placeholder = NSLocalizedString(@"EPUserDetailsViewController_passwordTextFieldPlaceholder", nil);
    self.savePasswordButton.enabled = NO;

    if (self.editedUser.state.canDownloadAndRemoveTextbooksType == EPSettingsCanDownloadAndRemoveTextbooksTypeGranted) {
        self.allowDownloadAndUpdateSegmentedControl.selectedSegmentIndex = 0;
    }
    else {
        self.allowDownloadAndUpdateSegmentedControl.selectedSegmentIndex = 1;
    }
}

#pragma mark - Actions

- (IBAction)savePasswordButtonAction:(id)sender {

    [self.passwordTextField resignFirstResponder];

    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    if (![configuration.userUtil isPasswordStrongEnough:self.passwordTextField.text]) {

        EPAlertViewHandler *handler = [EPAlertViewHandler new];
        handler.title = NSLocalizedString(@"EPUserDetailsViewController_alertPasswordWeakTitle", nil);
        handler.message = NSLocalizedString(@"EPUserDetailsViewController_alertPasswordWeakMessage", nil);
        [handler addCancelButtonWithTitle:NSLocalizedString(@"EPUserDetailsViewController_alertPasswordWeakOk", nil) andActionBlock:nil];
        [handler show];
        
        return;
    }

    self.editedUser.spassword = [configuration.cryptoUtil createSalt];
    self.editedUser.hpassword = [configuration.cryptoUtil createHashWithString:self.passwordTextField.text andSalt:self.editedUser.spassword];
    [self.editedUser update];

    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPUserDetailsViewController_alertPasswordChangedTitle", nil);
    handler.message = NSLocalizedString(@"EPUserDetailsViewController_alertPasswordChangedMessage", nil);
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPUserDetailsViewController_alertPasswordChangedOk", nil) andActionBlock:nil];
    [handler show];

    self.savePasswordButton.enabled = NO;
}

- (IBAction)allowDownloadAndUpdateSegmentedControlValueChanged:(id)sender {
    
    NSString *message = nil;
    
    if (self.allowDownloadAndUpdateSegmentedControl.selectedSegmentIndex == 0) {
        
        self.editedUser.state.canDownloadAndRemoveTextbooksType = EPSettingsCanDownloadAndRemoveTextbooksTypeGranted;
        message = NSLocalizedString(@"EPUserDetailsViewController_alertAllowDownloadMessageAllow", nil);
    }
    else {
        
        self.editedUser.state.canDownloadAndRemoveTextbooksType = EPSettingsCanDownloadAndRemoveTextbooksTypeDenied;
        message = NSLocalizedString(@"EPUserDetailsViewController_alertAllowDownloadMessageDeny", nil);
    }

    [self.editedUser update];

    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPUserDetailsViewController_alertAllowDownloadTitle", nil);
    handler.message = message;
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPUserDetailsViewController_alertAllowDownloadOk", nil) andActionBlock:nil];
    [handler show];
}

- (IBAction)deleteAccountButtonAction:(id)sender {
    
    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPUserDetailsViewController_alertDeleteAccountTitle", nil);
    handler.message = NSLocalizedString(@"EPUserDetailsViewController_alertDeleteAccountMessage", nil);
    [handler addButtonWithTitle:NSLocalizedString(@"EPUserDetailsViewController_alertDeleteAccountYes", nil) andActionBlock:^{
        
        EPConfiguration *configuration = [EPConfiguration activeConfiguration];
        [configuration.userModel deleteUser:self.editedUser.userID];
        [configuration.userUtil determineState];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPUserDetailsViewController_alertDeleteAccountNo", nil) andActionBlock:nil];
    [handler show];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == EPUserDetailsViewControllerSectionsPassword) {
        return NSLocalizedString(@"EPUserDetailsViewController_sectionPassword", nil);
    }
    if (section == EPUserDetailsViewControllerSectionsAllowDownload) {
        return NSLocalizedString(@"EPUserDetailsViewController_sectionAllowDownload", nil);
    }
    if (section == EPUserDetailsViewControllerSectionsDeleteUser) {
        return NSLocalizedString(@"EPUserDetailsViewController_sectionDeleteUser", nil);
    }
    
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.text = @"";
    self.savePasswordButton.enabled = NO;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.savePasswordButton.enabled = (password.length > 0);
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

    NSString *trimmedLogin = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    textField.text = trimmedLogin;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
