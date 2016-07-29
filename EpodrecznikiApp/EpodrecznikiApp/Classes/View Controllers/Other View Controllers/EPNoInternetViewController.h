







#import <UIKit/UIKit.h>

@interface EPNoInternetViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButtonWiFI;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButtonCellular;

- (IBAction)tryAgainButtonWiFIAction:(id)sender;
- (IBAction)tryAgainButtonCellularAction:(id)sender;

@end
