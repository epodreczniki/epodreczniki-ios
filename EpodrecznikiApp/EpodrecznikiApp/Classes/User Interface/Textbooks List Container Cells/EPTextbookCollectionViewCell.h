







#import <UIKit/UIKit.h>
#import "EPTextbookCollectionViewCellReverseView.h"
#import "EPTextbooksListContainer.h"
#import "EPProgressView.h"

@interface EPTextbookCollectionViewCell : UICollectionViewCell <EPTextbookCollectionViewCellReverseViewDelegate, EPDownloadTextbookProxyDelegate, EPTextbooksListContainerCell>

@property (assign, nonatomic) id <EPTextbooksListContainerCellDelegate> delegate;
@property (assign, nonatomic) EPDownloadTextbookProxy *proxy;

@property (strong, nonatomic) IBOutlet EPProgressView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

- (void)setCoverImage:(UIImage *)image animated:(BOOL)animated;
- (CGSize)sizeForCellWithTextbookTitle:(NSString *)title andAuthor:(NSString *)author;
- (void)prepareView;

@end
