







#import <UIKit/UIKit.h>

@class EPAdminStaticSettingsViewController;

@protocol EPAdminStaticSettingsViewControllerDelegate <NSObject>

- (void)didSelectCreateAdminAccountInViewController:(EPAdminStaticSettingsViewController *)viewController;
- (void)didSelectCreateUserAccountInViewController:(EPAdminStaticSettingsViewController *)viewController;

@end

@interface EPAdminStaticSettingsViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIButton *createAdminButton;
@property (nonatomic, weak) IBOutlet UIButton *createUserButton;
@property (nonatomic, weak) IBOutlet UISegmentedControl *cellularNetworkSegmentedControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *createNewAccountSegmentedControl;

@property (nonatomic, weak) id <EPAdminStaticSettingsViewControllerDelegate> delegate;

- (IBAction)createAdminButtonAction:(id)sender;
- (IBAction)createUserButtonAction:(id)sender;
- (IBAction)allowCellularSegmentedControlValueChanged:(id)sender;
- (IBAction)allowCreateNewAccountAtLoginScreenSegmentedControlValueChanged:(id)sender;

@end
