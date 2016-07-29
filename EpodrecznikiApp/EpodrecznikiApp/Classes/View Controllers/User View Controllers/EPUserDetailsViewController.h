







#import <UIKit/UIKit.h>

@interface EPUserDetailsViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *savePasswordButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *allowDownloadAndUpdateSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *deleteAccountButton;

@property (nonatomic, weak) EPUser *editedUser;

- (IBAction)savePasswordButtonAction:(id)sender;
- (IBAction)allowDownloadAndUpdateSegmentedControlValueChanged:(id)sender;
- (IBAction)deleteAccountButtonAction:(id)sender;

@end
