







#import <UIKit/UIKit.h>
#import "EPTocViewControllerCell.h"

@interface EPTocViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EPTocViewControllerCellDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *homeButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *returnButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)homeButtonAction:(id)sender;
- (IBAction)returnButtonAction:(id)sender;

@end
