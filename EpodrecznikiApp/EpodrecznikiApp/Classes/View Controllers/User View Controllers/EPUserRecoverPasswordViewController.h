







#import <UIKit/UIKit.h>

@interface EPUserRecoverPasswordViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *changePasswordButton;

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UILabel *invalidAnswerLabel;
@property (nonatomic, weak) IBOutlet UILabel *invalidPasswordsLabel;

@property (nonatomic, weak) IBOutlet UITextField *answerTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *repeatPasswordTextField;

@property (nonatomic, assign) EPUser *user;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)changePasswordButtonAction:(id)sender;

@end
