







#import <UIKit/UIKit.h>
#import "EPProgressCircleSmallView.h"

@protocol EPDetailsButtonsViewDelegate;

@interface EPDetailsButtonsView : UIView

@property (nonatomic, weak) IBOutlet UIView *movableView;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *downloadButton;
@property (nonatomic, weak) IBOutlet UIButton *updateButton;
@property (nonatomic, weak) IBOutlet UIButton *readButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *bookmarksButton;
@property (nonatomic, weak) EPProgressCircleSmallView *progressCircleSmallView;
@property (nonatomic, assign) id <EPDetailsButtonsViewDelegate> delegate;

- (IBAction)deleteButtonAction:(id)sender;
- (IBAction)downloadButtonAction:(id)sender;
- (IBAction)updateButtonAction:(id)sender;
- (IBAction)readButtonAction:(id)sender;
- (IBAction)stopButtonAction:(id)sender;
- (IBAction)bookmarksButtonAction:(id)sender;
- (void)setProgressVisible:(BOOL)visible animated:(BOOL)animated;

@end

@protocol EPDetailsButtonsViewDelegate <NSObject>

- (void)didClickDeleteButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView;
- (void)didClickDownloadButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView;
- (void)didClickUpdateButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView;
- (void)didClickReadButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView;
- (void)didClickBookmarksButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView;
- (void)didClickStopButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView;

@end
