







#import "EPUserRecoverPasswordViewController.h"
#import "EPAlertViewHandler.h"

typedef NS_ENUM(NSInteger, EPUserRecoverPasswordViewControllerSections) {
    EPUserRecoverPasswordViewControllerSectionsQuestion             = 0,
    EPUserRecoverPasswordViewControllerSectionsQuestionError        = 1,
    EPUserRecoverPasswordViewControllerSectionsPasswords            = 2,
    EPUserRecoverPasswordViewControllerSectionsPasswordsError       = 3,
    EPUserRecoverPasswordViewControllerSectionsButtons              = 4
};

@interface EPUserRecoverPasswordViewController ()

@property (nonatomic, copy) NSString *questionError;
@property (nonatomic, copy) NSString *passwordsError;

@end

@implementation EPUserRecoverPasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"EPUserRecoverPasswordViewController_navigationBarTitle", nil);
    self.tableView.separatorColor = [UIColor clearColor];
    [self.cancelButton setTitle:NSLocalizedString(@"EPUserRecoverPasswordViewController_cancelButtonTitle", nil)];
    [self.changePasswordButton setTitle:NSLocalizedString(@"EPUserRecoverPasswordViewController_changePasswordButtonTitle", nil) forState:UIControlStateNormal];
    self.answerTextField.placeholder = NSLocalizedString(@"EPUserRecoverPasswordViewController_answerTextFieldPlaceholder", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"EPUserRecoverPasswordViewController_passwordTextFieldPlaceholder", nil);
    self.repeatPasswordTextField.placeholder = NSLocalizedString(@"EPUserRecoverPasswordViewController_repeatPasswordTextFieldPlaceholder", nil);

    self.questionLabel.text = self.user.question;
}

- (void)dealloc {
    self.questionError = nil;
    self.passwordTextField = nil;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Actions

- (IBAction)cancelButtonAction:(id)sender {

    if ([UIDevice currentDevice].isIPad) {
        [self.presentingViewController viewWillAppear:NO];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];

    if ([UIDevice currentDevice].isIPad) {
        [self.presentingViewController viewDidAppear:NO];
    }
}

- (IBAction)changePasswordButtonAction:(id)sender {

    self.questionError = nil;
    self.passwordsError = nil;
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    [indexSet addIndex:EPUserRecoverPasswordViewControllerSectionsQuestionError];
    [indexSet addIndex:EPUserRecoverPasswordViewControllerSectionsPasswordsError];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];

    [self.answerTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.repeatPasswordTextField resignFirstResponder];

    EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;
    if (![userUtil verifyRecoveryAnswer:self.answerTextField.text withUser:self.user]) {
        
        self.questionError = NSLocalizedString(@"EPUserRecoverPasswordViewController_errorAnswerInvalid", nil);
    }

    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (password.length == 0) {
        
        self.passwordsError = NSLocalizedString(@"EPUserRecoverPasswordViewController_errorPasswordEmpty", nil);
    }
    else if (![password isEqualToString:self.repeatPasswordTextField.text]) {
        
        self.passwordsError = NSLocalizedString(@"EPUserRecoverPasswordViewController_errorPasswordsAreDifferent", nil);
    }
    else if (![userUtil isPasswordStrongEnough:password]) {
        
        self.passwordsError = NSLocalizedString(@"EPUserRecoverPasswordViewController_errorPasswordTooShort", nil);
    }

    if (!self.questionError && !self.passwordsError) {
        
        EPCryptoUtil *cryptoUtil = [EPConfiguration activeConfiguration].cryptoUtil;
        NSString *salt = [cryptoUtil createSalt];
        NSString *hash = [cryptoUtil createHashWithString:password andSalt:salt];
        
        self.user.spassword = salt;
        self.user.hpassword = hash;
        [self.user update];

        EPAlertViewHandler *handler = [EPAlertViewHandler new];
        handler.title = NSLocalizedString(@"EPUserRecoverPasswordViewController_alertSuccessTitle", nil);
        handler.message = NSLocalizedString(@"EPUserRecoverPasswordViewController_alertSuccessMessage", nil);
        [handler addCancelButtonWithTitle:NSLocalizedString(@"EPUserRecoverPasswordViewController_alertSuccessOk", nil) andActionBlock:^{
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [handler show];
        
        return;
    }
    else {

        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

    NSString *trimmedLogin = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    textField.text = trimmedLogin;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.answerTextField) {
        
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        
        [textField resignFirstResponder];
        [self.repeatPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.repeatPasswordTextField) {
        
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == EPUserRecoverPasswordViewControllerSectionsQuestion) {
        return 2;
    }
    if (section == EPUserRecoverPasswordViewControllerSectionsQuestionError) {
        return (self.questionError ? 1 : 0);
    }
    if (section == EPUserRecoverPasswordViewControllerSectionsPasswords) {
        return 1;
    }
    if (section == EPUserRecoverPasswordViewControllerSectionsPasswordsError) {
        return (self.passwordsError ? 1 : 0);
    }
    if (section == EPUserRecoverPasswordViewControllerSectionsButtons) {
        return 1;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == EPUserRecoverPasswordViewControllerSectionsQuestion) {
        return NSLocalizedString(@"EPUserRecoverPasswordViewController_sectionsQuestion", nil);
    }
    else if (section == EPUserRecoverPasswordViewControllerSectionsPasswords) {
        return NSLocalizedString(@"EPUserRecoverPasswordViewController_sectionsPasswords", nil);
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == EPUserRecoverPasswordViewControllerSectionsQuestionError) {
        
        self.invalidAnswerLabel.text = self.questionError;
    }
    else if (indexPath.section == EPUserRecoverPasswordViewControllerSectionsPasswordsError) {
        
        self.invalidPasswordsLabel.text = self.passwordsError;
    }
}

@end
