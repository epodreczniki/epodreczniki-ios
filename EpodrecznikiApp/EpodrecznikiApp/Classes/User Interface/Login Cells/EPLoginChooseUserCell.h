







#import <UIKit/UIKit.h>

@class EPLoginChooseUserCell;

@protocol EPLoginChooseUserCellDelegate <NSObject>

- (NSArray *)usersArrayForCell:(EPLoginChooseUserCell *)cell;
- (void)didSelectUser:(EPUser *)user inCell:(EPLoginChooseUserCell *)cell;

@end

@interface EPLoginChooseUserCell : UITableViewCell <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) id <EPLoginChooseUserCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITextField *chooseUserTextField;
@property (nonatomic, assign) EPUser *selectedUser;

- (void)reloadData;
- (void)dismissKeyboard;

@end
