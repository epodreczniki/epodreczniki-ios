







#import <UIKit/UIKit.h>
#import "EPTextbooksListContainer.h"

@interface EPTextbooksListContainerTableView : EPTextbooksListContainer <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
