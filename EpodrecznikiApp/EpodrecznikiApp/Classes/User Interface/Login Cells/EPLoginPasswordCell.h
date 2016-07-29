







#import <UIKit/UIKit.h>

@class EPLoginPasswordCell;

@protocol EPLoginPasswordCellDelegate <NSObject>

- (void)didChangePassword:(NSString *)password inCell:(EPLoginPasswordCell *)cell;

@end

@interface EPLoginPasswordCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, assign) id <EPLoginPasswordCellDelegate> delegate;

- (void)dismissKeyboard;

@end
