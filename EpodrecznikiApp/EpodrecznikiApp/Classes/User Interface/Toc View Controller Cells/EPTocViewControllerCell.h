







#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EPTocViewControllerCellType) {
    EPTocViewControllerCellLeft,
    EPTocViewControllerCellRight,
    EPTocViewControllerCellNone
};

@class EPTocViewControllerCell;

@protocol EPTocViewControllerCellDelegate <NSObject>

- (void)tocViewControllerCell:(EPTocViewControllerCell *)cell didSelectLeftButtonForIndex:(NSInteger)index;
- (void)tocViewControllerCell:(EPTocViewControllerCell *)cell didSelectRightButtonForIndex:(NSInteger)index;

@end

@interface EPTocViewControllerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;
@property (nonatomic, weak) IBOutlet UILabel *tocTitleLabel;
@property (nonatomic, weak) IBOutlet UIView *separatorView;
@property (nonatomic, weak) UIView *topSeparatorView;
@property (nonatomic) EPTocViewControllerCellType cellType;
@property (nonatomic, weak) id <EPTocViewControllerCellDelegate> delegate;

- (IBAction)leftButtonAction;
- (IBAction)rightButtonAction;

@end
