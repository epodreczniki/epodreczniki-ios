







#import <UIKit/UIKit.h>
#import "EPProgressView.h"
#import "EPDetailsButtonsView.h"

@protocol EPTextbookDetailsViewControllerDelegate;

@interface EPTextbookDetailsViewController : UIViewController <EPDetailsButtonsViewDelegate, EPDownloadTextbookProxyDelegate>

@property (nonatomic, copy) NSString *textbookRootID;
@property (nonatomic, assign) id <EPTextbookDetailsViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *coverAndMarkView;
@property (weak, nonatomic) IBOutlet EPProgressView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;
@property (weak, nonatomic) EPDetailsButtonsView *buttonsView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@protocol EPTextbookDetailsViewControllerDelegate <NSObject>

- (void)textbookDetailsViewController:(EPTextbookDetailsViewController *)textbookDetailsViewController didRemoveTextbookWithProxy:(EPDownloadTextbookProxy *)proxy;
- (NSString *)stringWithStorageSize:(unsigned long long)size;


@end
