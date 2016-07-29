







#import <UIKit/UIKit.h>

@interface EPUserCreateViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL isCreatingAnAdminAccount;
@property (nonatomic) BOOL shouldDismissViewController;
@property (nonatomic, readonly) BOOL isEditingAdminAccount;
@property (nonatomic, readonly) BOOL isEditingAccount;
@property (nonatomic, weak) EPUser *editedUser;

@property (weak, nonatomic) IBOutlet UILabel *warningLabel;

@property (weak, nonatomic) IBOutlet UITextField *loginNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (weak, nonatomic) IBOutlet UITextField *recoveryQuestionTextField;
@property (weak, nonatomic) IBOutlet UITextField *recoveryAnswerTextField;

@property (nonatomic, weak) IBOutlet UIButton *createAccountButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)createAccountButtonAction:(id)sender;

@end
