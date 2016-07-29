







#import <UIKit/UIKit.h>
#import "EPTextbooksListContainer.h"
#import "EPProgressView.h"
#import "EPProgressCircleSmallView.h"

@interface EPTextbookCarouselCellView : UIView <EPDownloadTextbookProxyDelegate>

@property (assign, nonatomic) id <EPTextbooksListContainerCellDelegate> delegate;
@property (assign, nonatomic) EPDownloadTextbookProxy *proxy;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UIView *coverAndMarkView;
@property (weak, nonatomic) IBOutlet EPProgressView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (weak, nonatomic) EPProgressCircleSmallView *progressView;
@property (weak, nonatomic) IBOutlet UIView *dataContentView;
@property (nonatomic) BOOL animatedLayoutChange;

- (IBAction)detailsButtonAction:(id)sender;
- (void)handleCoverTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)handleProgressTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)setCoverImage:(UIImage *)image animated:(BOOL)animated;
- (void)prepareView;

@end
