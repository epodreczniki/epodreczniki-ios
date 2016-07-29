







#import "EPDetailsButtonsView.h"

@interface EPDetailsButtonsView ()

@property (nonatomic) BOOL visible;

@end

@implementation EPDetailsButtonsView

#pragma mark - Lifecycle

- (void)awakeFromNib {

    self.progressCircleSmallView = [EPProgressCircleSmallView viewWithNibName:@"EPProgressCircleSmallView"];
    self.progressCircleSmallView.frame = CGRectMake(0, 0, 110, 110);
    [self.movableView addSubview:self.progressCircleSmallView];

    NSArray *buttons = @[
        self.downloadButton,
        self.updateButton,
        self.deleteButton,
        self.stopButton,
        self.readButton,
        self.bookmarksButton
    ];

    for (UIButton *button in buttons) {

        UIColor *enabledColor = ((button == self.deleteButton || button == self.stopButton) ? [UIColor redColor] : [UIColor epBlueColor]);
        UIColor *disabledColor = [[UIColor grayColor] colorWithAlphaComponent:0.3f];

        UIImage *enabledImage = [[button imageForState:UIControlStateNormal] imageWithColor:enabledColor];
        UIImage *disabledImage = [[button imageForState:UIControlStateNormal] imageWithColor:disabledColor];

        if (button == self.readButton || button == self.bookmarksButton) {
            [button setBackgroundImage:enabledImage forState:UIControlStateNormal];
            [button setBackgroundImage:disabledImage forState:UIControlStateDisabled];
            [button setImage:nil forState:UIControlStateNormal];
            [button setImage:nil forState:UIControlStateDisabled];
        }
        else {
            [button setImage:enabledImage forState:UIControlStateNormal];
            [button setImage:disabledImage forState:UIControlStateDisabled];
        }
    }

    self.visible = NO;

    self.downloadButton.accessibilityLabel = NSLocalizedString(@"Accessability_downloadTextbook", nil);
    self.updateButton.accessibilityLabel = NSLocalizedString(@"Accessability_updateTextbook", nil);
    self.deleteButton.accessibilityLabel = NSLocalizedString(@"Accessability_deleteTextbook", nil);
    self.readButton.accessibilityLabel = NSLocalizedString(@"Accessability_readTextbook", nil);
    self.stopButton.accessibilityLabel = NSLocalizedString(@"Accessability_stopDownloadTextbook", nil);
    self.bookmarksButton.accessibilityLabel = NSLocalizedString(@"Accessability_bookmarksAndNotes", nil);

    self.progressCircleSmallView.isAccessibilityElement = self.visible;
    self.progressCircleSmallView.progressLabel.isAccessibilityElement = self.visible;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat z = self.frame.size.height / 6.0f;
    CGFloat z4 = z * 4.0f;
    CGFloat next = 5.0f;
    
    self.progressCircleSmallView.frame = CGRectMake(z * (0.0f * next + 1.0f), z, z4, z4);
    self.downloadButton.frame          = CGRectMake(z * (1.0f * next + 1.0f), z, z4, z4);
    self.updateButton.frame            = CGRectMake(z * (1.0f * next + 1.0f), z, z4, z4);
    self.stopButton.frame              = CGRectMake(z * (1.0f * next + 1.0f), z, z4, z4);
    self.deleteButton.frame            = CGRectMake(z * (2.0f * next + 1.0f), z, z4, z4);
    self.readButton.frame              = CGRectMake(z * (3.0f * next + 1.0f), z, z4, z4);
    self.bookmarksButton.frame         = CGRectMake(z * (4.0f * next + 1.0f), z, z4, z4);
    
    EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;
    if (!userUtil.user.state.canDownloadAndRemoveTextbooks) {
        
        CGRect frame = self.movableView.frame;
        frame.origin.x = -3 * (z4 + z);
        self.movableView.frame = frame;
        
        return;
    }
    
    if (self.visible) {
        
        CGRect frame = self.movableView.frame;
        frame.origin.x = 0;
        self.movableView.frame = frame;
    }
    else {
        
        CGRect frame = self.movableView.frame;
        frame.origin.x = -1 * (z4 + z);
        self.movableView.frame = frame;
    }
}

#pragma mark - Actions

- (IBAction)deleteButtonAction:(id)sender {

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDeleteButtonForDetailsButtonsView:)]) {
        [self.delegate didClickDeleteButtonForDetailsButtonsView:self];
    }
}

- (IBAction)downloadButtonAction:(id)sender {

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDownloadButtonForDetailsButtonsView:)]) {
        [self.delegate didClickDownloadButtonForDetailsButtonsView:self];
    }
}

- (IBAction)updateButtonAction:(id)sender {

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickUpdateButtonForDetailsButtonsView:)]) {
        [self.delegate didClickUpdateButtonForDetailsButtonsView:self];
    }
}

- (IBAction)readButtonAction:(id)sender {

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickReadButtonForDetailsButtonsView:)]) {
        [self.delegate didClickReadButtonForDetailsButtonsView:self];
    }
}

- (IBAction)stopButtonAction:(id)sender {

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickStopButtonForDetailsButtonsView:)]) {
        [self.delegate didClickStopButtonForDetailsButtonsView:self];
    }
}

- (IBAction)bookmarksButtonAction:(id)sender {

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickBookmarksButtonForDetailsButtonsView:)]) {
        [self.delegate didClickBookmarksButtonForDetailsButtonsView:self];
    }
}

#pragma mark - Public methods

- (void)setProgressVisible:(BOOL)visible animated:(BOOL)animated {
    
    EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;
    if (!userUtil.user.state.canDownloadAndRemoveTextbooks) {
        return;
    }

    if (self.visible == visible) {
        return;
    }

    self.visible = visible;
    self.progressCircleSmallView.alpha = (visible ? 0.0f : 1.0f);

    self.progressCircleSmallView.isAccessibilityElement = visible;
    self.progressCircleSmallView.progressLabel.isAccessibilityElement = visible;

    void (^animationProgressAlphaChangeBlock)(void) = ^{

        self.progressCircleSmallView.alpha = (visible ? 1.0f : 0.0f);
    };
    void (^animationButtonsFrameChangeBlock)(void) = ^{

        CGFloat position = self.progressCircleSmallView.frame.origin.x + self.progressCircleSmallView.frame.size.width;

        CGRect frame = self.movableView.frame;
        frame.origin.x = (visible ? 0 : -position);
        self.movableView.frame = frame;
    };

    void (^animation1)(void) = (visible ? animationButtonsFrameChangeBlock  : animationProgressAlphaChangeBlock);
    void (^animation2)(void) = (visible ? animationProgressAlphaChangeBlock : animationButtonsFrameChangeBlock);

    NSTimeInterval duration1 = (animated ? 0.5f : 0.0f);
    NSTimeInterval duration2 = (animated ? 0.5f : 0.0f);

    [UIView animateWithDuration:duration1 animations:^{
        animation1();
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration2 animations:^{
            animation2();
        }];
    }];
}

@end
