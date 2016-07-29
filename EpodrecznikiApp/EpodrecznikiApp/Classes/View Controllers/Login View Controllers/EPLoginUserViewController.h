







#import <UIKit/UIKit.h>

#import "EPLoginButtonscell.h"
#import "EPLoginChooseUserCell.h"
#import "EPLoginEmptyCell.h"
#import "EPLoginErrorCell.h"
#import "EPLoginPasswordCell.h"

@interface EPLoginUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EPLoginChooseUserCellDelegate, EPLoginButtonsCellDelegate, EPLoginPasswordCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;


@property (nonatomic, readonly) EPLoginChooseUserCell *loginChooseUserCell;
@property (nonatomic, readonly) EPLoginPasswordCell *loginPasswordCell;
@property (nonatomic, readonly) EPLoginErrorCell *loginErrorCell;
@property (nonatomic, readonly) EPLoginButtonsCell *loginButtonsCell;

@end
