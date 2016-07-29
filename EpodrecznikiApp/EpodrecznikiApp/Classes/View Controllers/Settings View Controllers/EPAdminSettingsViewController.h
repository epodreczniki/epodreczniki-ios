







#import <UIKit/UIKit.h>
#import "EPAdminStaticSettingsViewController.h"

@interface EPAdminSettingsViewController : UITableViewController <EPAdminStaticSettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)cancelButtonAction:(id)sender;

@end
