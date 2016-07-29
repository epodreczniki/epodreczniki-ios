







#import <UIKit/UIKit.h>

@interface EPUserSettingsViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UISegmentedControl *textbookVariantSegmentedControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *loginModeSegmentedControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *listModeSegmentedControl;
@property (nonatomic, weak) IBOutlet UIButton *editAccountButton;
@property (nonatomic, weak) IBOutlet UIButton *changeFilterButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *cancelButton;

@property (nonatomic, weak) EPUser *editedUser;

- (IBAction)textbookVariantSegmentedControlValueChanged:(id)sender;
- (IBAction)loginModeSegmentedControlValueChanged:(id)sender;
- (IBAction)listModeSegmentedControlValueChanged:(id)sender;
- (IBAction)editAccountButtonAction:(id)sender;
- (IBAction)changeFilterButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;

@end
