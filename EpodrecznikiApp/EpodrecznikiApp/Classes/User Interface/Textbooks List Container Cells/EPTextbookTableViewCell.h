







#import <UIKit/UIKit.h>
#import "EPTextbooksListContainer.h"
#import "EPProgressCircleSmallView.h"

@interface EPTextbookTableViewCell : UITableViewCell <EPDownloadTextbookProxyDelegate>

@property (assign, nonatomic) id <EPTextbooksListContainerCellDelegate> delegate;
@property (assign, nonatomic) EPDownloadTextbookProxy *proxy;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) EPProgressCircleSmallView *progressView;
@property (weak, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;

- (IBAction)detailsButtonAction:(id)sender;
- (void)handleProgressTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)prepareView;

@end
