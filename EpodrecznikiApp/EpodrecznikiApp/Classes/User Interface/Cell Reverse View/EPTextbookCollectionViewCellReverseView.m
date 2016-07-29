







#import "EPTextbookCollectionViewCellReverseView.h"

#import "EPAppDelegate.h"

@interface EPTextbookCollectionViewCellReverseView ()

@property (nonatomic, readonly) EPDownloadTextbookProxy *downloadTextbookproxy;
@property (nonatomic, strong) NSArray *accessabilityArray;

- (void)debugTransitions;

@end

@implementation EPTextbookCollectionViewCellReverseView

#pragma mark - Lifecycle

- (void)awakeFromNib {

    self.progressCircleView = [EPProgressCircleView viewWithNibName:@"EPProgressCircleView"];
    self.progressCircleView.frame = self.readButton.frame;
    [self addSubview:self.progressCircleView];

    NSArray *buttons = @[
        self.backButton,
        self.downloadButton,
        self.updateButton,
        self.deleteButton,
        self.stopButton,
        self.detailsButton,
        self.readButton
    ];

    for (UIButton *button in buttons) {

        UIColor *enabledColor = ((button == self.deleteButton || button == self.stopButton) ? [UIColor redColor] : [UIColor epBlueColor]);
        UIColor *disabledColor = [[UIColor grayColor] colorWithAlphaComponent:0.3f];

        UIImage *enabledImage = [[button imageForState:UIControlStateNormal] imageWithColor:enabledColor];
        UIImage *disabledImage = [[button imageForState:UIControlStateNormal] imageWithColor:disabledColor];

        if (button == self.readButton) {
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

    self.downloadButton.accessibilityLabel = NSLocalizedString(@"Accessability_downloadTextbook", nil);
    self.stopButton.accessibilityLabel = NSLocalizedString(@"Accessability_stopDownloadTextbook", nil);
    self.updateButton.accessibilityLabel = NSLocalizedString(@"Accessability_updateTextbook", nil);
    self.deleteButton.accessibilityLabel = NSLocalizedString(@"Accessability_deleteTextbook", nil);
    self.readButton.accessibilityLabel = NSLocalizedString(@"Accessability_readTextbook", nil);
    self.detailsButton.accessibilityLabel = NSLocalizedString(@"Accessability_textbookDetails", nil);
    
    self.accessabilityArray = @[
        self.downloadButton,
        self.updateButton,
        self.stopButton,
        self.deleteButton,
        self.readButton,
        self.progressCircleView,
        self.detailsButton
    ];

    EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;
    if (!userUtil.user.state.canDownloadAndRemoveTextbooks) {
        self.downloadButton.frame = CGRectZero;
        self.updateButton.frame = CGRectZero;
        self.deleteButton.frame = CGRectZero;
        self.stopButton.frame = CGRectZero;
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.progressCircleView = nil;
    self.accessabilityArray = nil;
    self.downloadButton = nil;
    self.updateButton = nil;
    self.stopButton = nil;

}

#pragma mark - UIViewRendering

- (void)drawRect:(CGRect)rect {
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.8, 0.7, 0.7, 0.7, 0.8 };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, CGPointMake(0, 0), CGPointMake(rect.size.width, rect.size.height), 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

#pragma mark - Public methods

- (void)prepareView {

    EPDownloadTextbookProxy *proxy = self.downloadTextbookproxy;
    proxy.delegate = self;

    EPTextbookStateType state = proxy.storeCollection.state;
    
#if DEBUG_STATE_TRANSITIONS
    state = EPTextbookStateTypeToDownload;
#endif






    self.downloadButton.hidden = NO;
    self.updateButton.hidden = NO;
    self.deleteButton.hidden = NO;
    self.stopButton.hidden = NO;
    self.readButton.hidden = NO;
    self.progressCircleView.hidden = NO;
    self.progressCircleView.alpha = 1.0f;
    
    self.downloadButton.enabled = YES;
    self.updateButton.enabled = YES;
    self.deleteButton.enabled = YES;
    self.stopButton.enabled = YES;
    self.readButton.enabled = YES;

    if (state == EPTextbookStateTypeToDownload) {
        
        self.downloadButton.hidden = NO;
        self.updateButton.hidden = YES;
        self.deleteButton.enabled = NO;
        self.stopButton.enabled = NO;
        self.stopButton.hidden = YES;
        self.readButton.enabled = NO;
        self.progressCircleView.hidden = YES;
    }

    else if (state == EPTextbookStateTypeDownloading) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.hidden = YES;
        self.deleteButton.enabled = NO;
        self.stopButton.enabled = YES;
        self.readButton.hidden = YES;
        self.progressCircleView.hidden = NO;
    }

    else if (state == EPTextbookStateTypeNormal) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.enabled = NO;
        self.deleteButton.enabled = YES;
        self.stopButton.hidden = YES;
        self.readButton.enabled = YES;
        self.progressCircleView.hidden = YES;
    }

    else if (state == EPTextbookStateTypeToUpdate) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.progressCircleView.hidden = YES;
    }

    else if (state == EPTextbookStateTypeUpdating) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.hidden = YES;
        self.deleteButton.enabled = NO;
        self.stopButton.hidden = NO;

        self.readButton.hidden = YES;
        self.progressCircleView.hidden = NO;
    }

    if ([EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
        if (self.downloadButton.hidden) {
            [self.downloadButton removeFromSuperview];
        }
        if (self.updateButton.hidden) {
            [self.updateButton removeFromSuperview];
        }
        if (self.stopButton.hidden) {
            [self.stopButton removeFromSuperview];
        }
    }

    if (proxy.isUnpacking) {
        [self willBeginExtractingForDownloadTextbookProxy:proxy];
    }

    if (state == EPTextbookStateTypeDownloading || state == EPTextbookStateTypeUpdating) {
        [NSThread sleepForTimeInterval:0.1f];
    }
}

#pragma mark - EPDownloadTextbookProxyDelegate

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didChangeTextbookStateTo:(EPTextbookStateType)toState fromState:(EPTextbookStateType)fromState {

    if ([EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
        if (!self.downloadButton.superview) {
            [self addSubview:self.downloadButton];
        }
        if (!self.updateButton.superview) {
            [self addSubview:self.updateButton];
        }
        if (!self.stopButton.superview) {
            [self addSubview:self.stopButton];
        }
    }

    if (fromState == EPTextbookStateTypeToDownload && toState == EPTextbookStateTypeDownloading) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.hidden = YES;
        self.deleteButton.enabled = NO;
        self.stopButton.enabled = YES;
        self.stopButton.hidden = NO;
        self.readButton.hidden = YES;
        self.progressCircleView.hidden = NO;
        [self.progressCircleView setNumericProgress:0.0f];
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeToDownload) {
        
        self.downloadButton.hidden = NO;
        self.updateButton.hidden = YES;
        self.deleteButton.enabled = NO;
        self.stopButton.enabled = NO;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = NO;
        self.progressCircleView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeNormal) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.enabled = NO;
        self.updateButton.hidden = NO;
        self.deleteButton.enabled = YES;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = YES;
        self.progressCircleView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeToUpdate) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.hidden = NO;
        self.updateButton.enabled = YES;
        self.deleteButton.enabled = YES;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = YES;
        self.progressCircleView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeNormal && toState == EPTextbookStateTypeToUpdate) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.enabled = YES;
        self.updateButton.hidden = NO;
        self.deleteButton.enabled = YES;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = YES;
        self.progressCircleView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeNormal) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.enabled = NO;
        self.updateButton.hidden = NO;
        self.deleteButton.enabled = YES;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = YES;
        self.progressCircleView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeUpdating) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.hidden = YES;
        self.deleteButton.enabled = NO;
        self.stopButton.hidden = NO;
        self.readButton.hidden = NO;
        self.readButton.enabled = YES;


        self.readButton.hidden = YES;
        self.progressCircleView.hidden = NO;
        [self.progressCircleView setNumericProgress:0.0f];
    }

    else if (fromState == EPTextbookStateTypeUpdating && toState == EPTextbookStateTypeToUpdate) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.enabled = YES;
        self.updateButton.hidden = NO;
        self.deleteButton.enabled = YES;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = YES;


        self.progressCircleView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeUpdating && toState == EPTextbookStateTypeNormal) {
        
        self.downloadButton.hidden = YES;
        self.updateButton.enabled = NO;
        self.updateButton.hidden = NO;
        self.deleteButton.enabled = YES;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = YES;


        self.progressCircleView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeNormal && toState == EPTextbookStateTypeToDownload) {
        
        self.downloadButton.hidden = NO;
        self.updateButton.hidden = YES;
        self.deleteButton.enabled = NO;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = NO;
        self.progressCircleView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeToDownload) {
        
        self.downloadButton.hidden = NO;
        self.updateButton.hidden = YES;
        self.deleteButton.enabled = NO;
        self.stopButton.hidden = YES;
        self.readButton.hidden = NO;
        self.readButton.enabled = NO;
        self.progressCircleView.hidden = YES;

        [self downloadTextbookProxy:self.downloadTextbookproxy reloadMetadataToContentID:nil];
    }

    if ([EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
        if (self.downloadButton.hidden) {
            [self.downloadButton removeFromSuperview];
        }
        if (self.updateButton.hidden) {
            [self.updateButton removeFromSuperview];
        }
        if (self.stopButton.hidden) {
            [self.stopButton removeFromSuperview];
        }
    }
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateProgressToValue:(float)progress {

    [self.progressCircleView setNumericProgress:progress];
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didRaiseError:(NSError *)error {


    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDeleteButtonForCellReverseView:)]) {
        [self.delegate didRaiseError:error forCellReverseView:self];
    }
}

- (void)willBeginExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {
    
    self.stopButton.enabled = NO;
    [self.progressCircleView setFillProgress:-1.0f];
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateUnpackingProgressToValue:(float)progress {
    [self.progressCircleView setFillProgress:progress];
}

- (void)didFinishExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {
    [self.progressCircleView setFillProgress:1.0f];
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy reloadMetadataToContentID:(NSString *)contentID {

    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldReloadMetadataForCellReverseView:)]) {
        [self.delegate shouldReloadMetadataForCellReverseView:self];
    }
}

#pragma mark - Private properties

- (EPDownloadTextbookProxy *)downloadTextbookproxy {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTextbookProxyForCellReverseView:)]) {
        return [self.delegate downloadTextbookProxyForCellReverseView:self];
    }
    
    return nil;
}

- (void)debugTransitions {
    static int index = 0;
    
    const int max = 18;
    if (index > max - 1) {
        index = 0;
    }
    
    int from[max] = {
        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeNormal,

        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeNormal,

        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeUpdating,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeUpdating,
        EPTextbookStateTypeNormal,

        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeToUpdate
    };
    int to[max] = {
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToDownload,

        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToUpdate,

        EPTextbookStateTypeUpdating,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeUpdating,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToDownload,

        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeToDownload
    };

    [[NSString stringWithFormat:@"index: %d, from: %@, to: %@", index,
        NSStringFromEPTextbookStateType(from[index]),
        NSStringFromEPTextbookStateType(to[index])] printMe];

    [self downloadTextbookProxy:nil didChangeTextbookStateTo:to[index] fromState:from[index]];

    index++;
}

#pragma mark - Actions

- (IBAction)backButtonAction:(id)sender {
#if DEBUG_STATE_TRANSITIONS

    [self debugTransitions]; return;
#else


    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickBackButtonForCellReverseView:animated:)]) {
        [self.delegate didClickBackButtonForCellReverseView:self animated:YES];
    }
#endif
}

- (IBAction)downloadButtonAction:(id)sender {


    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDownloadButtonForCellReverseView:)]) {
        [self.delegate didClickDownloadButtonForCellReverseView:self];
    }
}

- (IBAction)updateButtonAction:(id)sender {


    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickUpdateButtonForCellReverseView:)]) {
        [self.delegate didClickUpdateButtonForCellReverseView:self];
    }
}

- (IBAction)deleteButtonAction:(id)sender {


    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDeleteButtonForCellReverseView:)]) {
        [self.delegate didClickDeleteButtonForCellReverseView:self];
    }
}

- (IBAction)stopButtonAction:(id)sender {


    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCancelButtonForCellReverseView:)]) {
        [self.delegate didClickCancelButtonForCellReverseView:self];
    }
}

- (IBAction)readButtonAction:(id)sender {


    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickReadButtonForCellReverseView:)]) {
        [self.delegate didClickReadButtonForCellReverseView:self];
    }
}

- (IBAction)detailsButtonAction:(id)sender {


    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickDetailsButtonForCellReverseView:)]) {
        [self.delegate didClickDetailsButtonForCellReverseView:self];
    }
}

#pragma mark - Accessability

- (BOOL)isAccessibilityElement{
    return NO;
}

- (NSInteger)accessibilityElementCount{
    return self.accessabilityArray.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index{
    return [self.accessabilityArray objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element{
    return [self.accessabilityArray indexOfObject:element];
}

@end
