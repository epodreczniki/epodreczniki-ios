







#import <UIKit/UIKit.h>
#import "EPProgressCircleView.h"

@protocol EPTextbookCollectionViewCellReverseViewDelegate;

@interface EPTextbookCollectionViewCellReverseView : UIView <EPDownloadTextbookProxyDelegate>

@property (nonatomic, assign) id <EPTextbookCollectionViewCellReverseViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *downloadButton;
@property (nonatomic, strong) IBOutlet UIButton *updateButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *readButton;
@property (nonatomic, weak) IBOutlet UIButton *detailsButton;
@property (nonatomic, weak) EPProgressCircleView *progressCircleView;

- (void)prepareView;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)downloadButtonAction:(id)sender;
- (IBAction)updateButtonAction:(id)sender;
- (IBAction)deleteButtonAction:(id)sender;
- (IBAction)stopButtonAction:(id)sender;
- (IBAction)readButtonAction:(id)sender;
- (IBAction)detailsButtonAction:(id)sender;

@end

@protocol EPTextbookCollectionViewCellReverseViewDelegate <NSObject>

- (EPDownloadTextbookProxy *)downloadTextbookProxyForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;
- (void)didClickBackButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView animated:(BOOL)animated;
- (void)didClickDownloadButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;
- (void)didClickUpdateButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;
- (void)didClickDeleteButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;
- (void)didClickCancelButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;
- (void)didClickReadButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;
- (void)didClickDetailsButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;
- (void)didRaiseError:(NSError *)error forCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;
- (void)shouldReloadMetadataForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView;

@end
