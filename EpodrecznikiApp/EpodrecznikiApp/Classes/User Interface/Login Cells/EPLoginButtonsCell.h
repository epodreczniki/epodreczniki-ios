







#import <UIKit/UIKit.h>

@class EPLoginButtonsCell;

@protocol EPLoginButtonsCellDelegate <NSObject>

- (void)didTapLoginButtonInCell:(EPLoginButtonsCell *)cell;
- (void)didTapRecoverPasswordButtonInCell:(EPLoginButtonsCell *)cell;
- (void)didTapCreateAccountButtonInCell:(EPLoginButtonsCell *)cell;

@end

@interface EPLoginButtonsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *recoverPasswordButton;
@property (nonatomic, weak) IBOutlet UIButton *createAccountButton;
@property (nonatomic, assign) id <EPLoginButtonsCellDelegate> delegate;

- (IBAction)loginButtonAction:(id)sender;
- (IBAction)recoverPasswordButtonAction:(id)sender;
- (IBAction)createAccountButtonAction:(id)sender;

@end
