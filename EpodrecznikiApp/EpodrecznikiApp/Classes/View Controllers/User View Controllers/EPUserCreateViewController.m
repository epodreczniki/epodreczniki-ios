







#import "EPUserCreateViewController.h"
#import "EPCryptoUtil.h"
#import "EPUserModel.h"
#import "EPAlertViewHandler.h"

typedef NS_ENUM(NSInteger, EPSectionNumber) {
    EPSectionNumber_Warning                 = 0,
    EPSectionNumber_Login                   = 1,
    EPSectionNumber_Reminder                = 2,
    EPSectionNumber_Buttons                 = 3
};

@implementation EPUserCreateViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationItem.title = NSLocalizedString(@"EPUserCreateViewController_navigationBarTitle", nil);
    self.cancelButton.title = NSLocalizedString(@"EPUserCreateViewController_cancelButtonTitle", nil);
    [self.createAccountButton setTitle:NSLocalizedString(@"EPUserCreateViewController_createAccountButtonTitle", nil) forState:UIControlStateNormal];
    self.warningLabel.text = NSLocalizedString(@"EPUserCreateViewController_warningLabel", nil);
    self.loginNameTextField.placeholder = NSLocalizedString(@"EPUserCreateViewController_loginNameTextFieldPlaceholder", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"EPUserCreateViewController_passwordTextFieldPlaceholder", nil);
    self.confirmPasswordTextField.placeholder = NSLocalizedString(@"EPUserCreateViewController_confirmPasswordTextFieldPlaceholder", nil);
    self.recoveryQuestionTextField.placeholder = NSLocalizedString(@"EPUserCreateViewController_recoveryQuestionTextFieldPlaceholder", nil);
    self.recoveryAnswerTextField.placeholder = NSLocalizedString(@"EPUserCreateViewController_recoveryAnswerTextFieldPlaceholder", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.isEditingAccount) {
        self.navigationItem.title = NSLocalizedString(@"EPUserCreateViewController_navigationBarTitleEdit", nil);
        [self.createAccountButton setTitle:NSLocalizedString(@"EPUserCreateViewController_createAccountButtonTitleEdit", nil) forState:UIControlStateNormal];
    }
    if (!self.shouldDismissViewController) {
        self.navigationItem.leftBarButtonItem = nil;
    }

    if (self.isEditingAccount) {
        self.loginNameTextField.text = self.editedUser.login;
        self.recoveryQuestionTextField.text = self.editedUser.question;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Public properties

- (void)setIsCreatingAnAdminAccount:(BOOL)isCreatingAnAdminAccount {
    if (isCreatingAnAdminAccount) {

    }
    else {

    }
    _isCreatingAnAdminAccount = isCreatingAnAdminAccount;
}

- (BOOL)isEditingAdminAccount {
    return self.isEditingAccount && (self.editedUser.role == EPAccountRoleAdmin);
}

- (BOOL)isEditingAccount {
    return self.editedUser ? YES : NO;
}

#pragma mark - Actions

- (IBAction)cancelButtonAction:(id)sender {

    [self.loginNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.recoveryQuestionTextField resignFirstResponder];
    [self.recoveryAnswerTextField resignFirstResponder];
    
    if (self.shouldDismissViewController) {

        if ([UIDevice currentDevice].isIPad) {
            [self.presentingViewController viewWillAppear:NO];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];

        if ([UIDevice currentDevice].isIPad) {
            [self.presentingViewController viewDidAppear:NO];
        }
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)createAccountButtonAction:(id)sender {

    [self.loginNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.recoveryQuestionTextField resignFirstResponder];
    [self.recoveryAnswerTextField resignFirstResponder];
    
    @try {

        if ([self areInputsValid]) {
            
            EPConfiguration *configuration = [EPConfiguration activeConfiguration];

            if (self.isEditingAccount) {
                
                EPUser *user  = [configuration.userModel readUserByID:self.editedUser.userID];
                user.login = self.loginNameTextField.text;
                user.spassword = [configuration.cryptoUtil createSalt];
                user.hpassword = [configuration.cryptoUtil createHashWithString:self.passwordTextField.text andSalt:user.spassword];
                
                if (self.isEditingAdminAccount) {
                    user.question = self.recoveryQuestionTextField.text;
                    user.sanswer = [configuration.cryptoUtil createSalt];
                    user.hanswer = [configuration.cryptoUtil createHashWithString:self.recoveryAnswerTextField.text andSalt:user.sanswer];
                }
                
                [configuration.userModel updateUser:user];
            }

            else if (self.isCreatingAnAdminAccount) {
                
                EPUser *user = [configuration.userModel readAdminUser];
                user.login = self.loginNameTextField.text;
                user.spassword = [configuration.cryptoUtil createSalt];
                user.hpassword = [configuration.cryptoUtil createHashWithString:self.passwordTextField.text andSalt:user.spassword];
                user.question = self.recoveryQuestionTextField.text;
                user.sanswer = [configuration.cryptoUtil createSalt];
                user.hanswer = [configuration.cryptoUtil createHashWithString:self.recoveryAnswerTextField.text andSalt:user.sanswer];
                user.role = EPAccountRoleAdmin;
                user.createdDate = [NSDate new];
                
                [configuration.userModel updateUser:user];
                [configuration.userUtil logInUser:user];
                [configuration.userUtil determineState];
            }

            else {
                
                EPUser *user = [EPUser new];
                user.login = self.loginNameTextField.text;
                user.spassword = [configuration.cryptoUtil createSalt];
                user.hpassword = [configuration.cryptoUtil createHashWithString:self.passwordTextField.text andSalt:user.spassword];
                user.role = EPAccountRoleUser;
                user.createdDate = [NSDate new];
                
                [configuration.userModel createUser:user];
                [configuration.userUtil determineState];
            }

            NSString *message = nil;
            if (self.isEditingAccount) {
                message = NSLocalizedString(@"EPUserCreateViewController_createAccountButtonActionEditSuccess", nil);
            }
            else {
                message = NSLocalizedString(@"EPUserCreateViewController_createAccountButtonActionCreateSuccess", nil);
            }
            [configuration.windowsUtil showInfoMessage:message withAction:^{

                [self cancelButtonAction:self.cancelButton];
            }];
        }
    }
    @catch (NSException *exception) {

    }
}

#pragma mark - Private methods

- (BOOL)areInputsValid {
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];

    if (self.loginNameTextField.text.length == 0) {
        
        [configuration.windowsUtil showErrorMessage:NSLocalizedString(@"EPUserCreateViewController_areInputsValidEmptyLogin", nil) withAction:nil];
        
        return NO;
    }


    if (self.isEditingAccount) {
        
        NSString *userLogin = self.editedUser.login.lowercaseString;
        NSString *newLogin = self.loginNameTextField.text.lowercaseString;
        
        if (![userLogin isEqualToString:newLogin] && ![configuration.userModel isUsernameAvailable:newLogin]) {
            
            [configuration.windowsUtil showErrorMessage:NSLocalizedString(@"EPUserCreateViewController_areInputsValidOccupiedLogin", nil) withAction:nil];
            
            return NO;
        }
    }

    else if (self.isCreatingAnAdminAccount) {
        
    }

    else {
        if (![configuration.userModel isUsernameAvailable:self.loginNameTextField.text]) {
            
            [configuration.windowsUtil showErrorMessage:NSLocalizedString(@"EPUserCreateViewController_areInputsValidOccupiedLogin", nil) withAction:nil];
            
            return NO;
        }
    }

    if (self.passwordTextField.text.length == 0) {
        
        [configuration.windowsUtil showErrorMessage:NSLocalizedString(@"EPUserCreateViewController_areInputsValidEmptyPassword", nil) withAction:nil];
        
        return NO;
    }

    if (![configuration.userUtil isPasswordStrongEnough:self.passwordTextField.text]) {
        
        [configuration.windowsUtil showErrorMessage:NSLocalizedString(@"EPUserCreateViewController_areInputsValidWeakPassword", nil) withAction:nil];
        
        return NO;
    }

    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
        
        [configuration.windowsUtil showErrorMessage:NSLocalizedString(@"EPUserCreateViewController_areInputsValidDifferentPasswords", nil) withAction:nil];
        
        return NO;
    }

    if (self.isCreatingAnAdminAccount || self.isEditingAdminAccount) {

        if (self.recoveryQuestionTextField.text.length == 0 || self.recoveryAnswerTextField.text.length == 0) {
            
            [configuration.windowsUtil showErrorMessage:NSLocalizedString(@"EPUserCreateViewController_areInputsValidEmptyRecovery", nil) withAction:nil];
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        if (self.shouldDismissViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == EPSectionNumber_Warning) {
        return (self.isCreatingAnAdminAccount ? 1 : 0);
    }
    else if (section == EPSectionNumber_Login) {
        return 3;
    }
    else if (section == EPSectionNumber_Reminder) {
        if (self.isCreatingAnAdminAccount || self.isEditingAdminAccount) {
            return 2;
        }
        else {
            return 0;
        }
    }
    else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == EPSectionNumber_Warning) {
        if (self.isCreatingAnAdminAccount) {
            return NSLocalizedString(@"EPUserCreateViewController_sectionWarning", nil);
        }
        else {
            return nil;
        }
    }
    else if (section == EPSectionNumber_Login) {
        return NSLocalizedString(@"EPUserCreateViewController_sectionLogin", nil);
    }
    else if (section == EPSectionNumber_Reminder) {
        if (self.isCreatingAnAdminAccount || self.isEditingAdminAccount) {
            return NSLocalizedString(@"EPUserCreateViewController_sectionRecovery", nil);
        }
        else {
            return nil;
        }
    }
    else if (section == EPSectionNumber_Buttons) {
        return nil;
    }
    
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == self.loginNameTextField) {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if (textField == self.passwordTextField) {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if (textField == self.confirmPasswordTextField) {

        if (self.isCreatingAnAdminAccount || self.isEditingAdminAccount) {
            textField.returnKeyType = UIReturnKeyNext;
        }
        else {
            textField.returnKeyType = UIReturnKeyDone;
        }
    }
    else if (textField == self.recoveryQuestionTextField) {
        textField.returnKeyType = UIReturnKeyNext;
    }
    else if (textField == self.recoveryAnswerTextField) {
        textField.returnKeyType = UIReturnKeyDone;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

    NSString *trimmedLogin = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    textField.text = trimmedLogin;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.loginNameTextField) {
        
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        
        [textField resignFirstResponder];
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.confirmPasswordTextField) {
        
        [textField resignFirstResponder];

        if (self.isCreatingAnAdminAccount || self.isEditingAdminAccount) {
            [self.recoveryQuestionTextField becomeFirstResponder];
        }
    }
    else if (textField == self.recoveryQuestionTextField) {
        
        [textField resignFirstResponder];
        [self.recoveryAnswerTextField becomeFirstResponder];
    }
    else if (textField == self.recoveryAnswerTextField) {
        
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
