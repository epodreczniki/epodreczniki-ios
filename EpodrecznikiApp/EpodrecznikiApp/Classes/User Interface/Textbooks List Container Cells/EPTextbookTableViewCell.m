







#import "EPTextbookTableViewCell.h"

@interface EPTextbookTableViewCell ()

- (void)reattachDelegateNotification:(NSNotification *)notification;
- (void)setBackgroundProgress:(float)progress;

@end

@implementation EPTextbookTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [self prepareForReuse];

    self.progressView = [EPProgressCircleSmallView viewWithNibName:@"EPProgressCircleSmallView"];
    self.progressView.frame = self.detailsButton.frame;
    self.progressView.autoresizingMask = self.detailsButton.autoresizingMask;
    [self.detailsButton.superview addSubview:self.progressView];

    NSArray *buttons = @[
        self.detailsButton
    ];

    for (UIButton *button in buttons) {

        UIColor *enabledColor = [UIColor epBlueColor];
        UIColor *disabledColor = [[UIColor grayColor] colorWithAlphaComponent:0.3f];

        UIImage *enabledImage = [[button imageForState:UIControlStateNormal] imageWithColor:enabledColor];
        UIImage *disabledImage = [[button imageForState:UIControlStateNormal] imageWithColor:disabledColor];

        [button setImage:enabledImage forState:UIControlStateNormal];
        [button setImage:disabledImage forState:UIControlStateDisabled];
    }
    self.progressView.tintColor = [UIColor epBlueColor];

    self.titleLabel.numberOfLines = 2;
    self.authorLabel.numberOfLines = 2;

    UITapGestureRecognizer *singleProgressTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProgressTap:)];
    [self.progressView addGestureRecognizer:singleProgressTap];

    self.detailsButton.accessibilityLabel = NSLocalizedString(@"Accessability_textbookDetails", nil);

    self.progressView.isAccessibilityElement = YES;
    self.progressView.progressLabel.isAccessibilityElement = YES;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookListCellReattachDelegateNotification object:nil];
    
    self.titleLabel = nil;
    self.authorLabel = nil;
    self.progressView = nil;
    self.delegate = nil;
    if (self.proxy) {
        self.proxy.delegate = nil;
    }
    self.proxy = nil;

}

- (void)prepareForReuse {

    self.titleLabel.text = nil;
    self.authorLabel.text = nil;
}

- (void)prepareView {

    self.proxy.delegate = self;

    EPTextbookStateType state = self.proxy.storeCollection.state;
    self.markImageView.hidden = !(state == EPTextbookStateTypeToUpdate || state == EPTextbookStateTypeUpdating);

    if (state == EPTextbookStateTypeToDownload) {
        [self setBackgroundProgress:0.0f];
        self.progressBackgroundView.hidden = NO;
        [self.progressView setNumericProgress:0.0f];
        self.progressView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (state == EPTextbookStateTypeNormal || state == EPTextbookStateTypeToUpdate) {
        [self setBackgroundProgress:1.0f];
        self.progressBackgroundView.hidden = YES;
        [self.progressView setNumericProgress:1.0f];
        self.progressView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (state == EPTextbookStateTypeDownloading || state == EPTextbookStateTypeUpdating) {
        self.progressBackgroundView.hidden = NO;
        self.progressView.hidden = NO;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    if (self.proxy.isUnpacking) {
        [self willBeginExtractingForDownloadTextbookProxy:self.proxy];
    }
}

#pragma mark - Actions

- (IBAction)detailsButtonAction:(id)sender {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didSelectDetailsButtonAtIndex:)]) {

        self.proxy.delegate = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reattachDelegateNotification:) name:kTextbookListCellReattachDelegateNotification object:nil];

        [self.delegate view:self didSelectDetailsButtonAtIndex:(int)self.tag];
    }
}

- (void)handleProgressTap:(UIGestureRecognizer *)gestureRecognizer {
    
    [self detailsButtonAction:nil];
}

#pragma mark - EPDownloadTextbookProxyDelegate

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didChangeTextbookStateTo:(EPTextbookStateType)toState fromState:(EPTextbookStateType)fromState {

    if (fromState == EPTextbookStateTypeToDownload && toState == EPTextbookStateTypeDownloading) {
        
        [self setBackgroundProgress:0.0f];
        self.progressBackgroundView.hidden = NO;
        [self.progressView setNumericProgress:0.0f];
        self.progressView.hidden = NO;
        self.markImageView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeToDownload) {
        
        [self setBackgroundProgress:0.0f];
        self.progressBackgroundView.hidden = NO;
        [self.progressView setNumericProgress:0.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeNormal) {
        
        [self setBackgroundProgress:1.0f];
        self.progressBackgroundView.hidden = YES;
        [self.progressView setNumericProgress:1.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;
        
        [[EPConfiguration activeConfiguration].accessibilityUtil playAnnouncement:NSLocalizedString(@"Accessability_announcementDownloaded", nil) after:3.0f];
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeToUpdate) {
        
        [self setBackgroundProgress:1.0f];
        self.progressBackgroundView.hidden = YES;
        [self.progressView setNumericProgress:1.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = NO;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (fromState == EPTextbookStateTypeNormal && toState == EPTextbookStateTypeToUpdate) {
        
        [self setBackgroundProgress:1.0f];
        self.progressBackgroundView.hidden = YES;
        [self.progressView setNumericProgress:1.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = NO;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeNormal) {
        
        [self setBackgroundProgress:1.0f];
        self.progressBackgroundView.hidden = YES;
        [self.progressView setNumericProgress:1.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeUpdating) {
        
        [self setBackgroundProgress:0.0f];
        self.progressBackgroundView.hidden = NO;
        [self.progressView setNumericProgress:0.0f];
        self.progressView.hidden = NO;
        self.markImageView.hidden = NO;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (fromState == EPTextbookStateTypeUpdating && toState == EPTextbookStateTypeToUpdate) {
        
        [self setBackgroundProgress:1.0f];
        self.progressBackgroundView.hidden = YES;
        [self.progressView setNumericProgress:1.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = NO;
        self.detailsButton.hidden = !self.progressView.hidden;
        
        [[EPConfiguration activeConfiguration].accessibilityUtil playAnnouncement:NSLocalizedString(@"Accessability_announcementUpdated", nil) after:3.0f];
    }

    else if (fromState == EPTextbookStateTypeUpdating && toState == EPTextbookStateTypeNormal) {
        
        [self setBackgroundProgress:1.0f];
        self.progressBackgroundView.hidden = YES;
        [self.progressView setNumericProgress:1.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;
        
        [[EPConfiguration activeConfiguration].accessibilityUtil playAnnouncement:NSLocalizedString(@"Accessability_announcementUpdated", nil) after:3.0f];
    }

    else if (fromState == EPTextbookStateTypeNormal && toState == EPTextbookStateTypeToDownload) {
        
        [self setBackgroundProgress:0.0f];
        self.progressBackgroundView.hidden = NO;
        [self.progressView setNumericProgress:0.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeToDownload) {
        
        [self setBackgroundProgress:0.0f];
        self.progressBackgroundView.hidden = NO;
        [self.progressView setNumericProgress:0.0f];
        self.progressView.hidden = YES;
        self.markImageView.hidden = YES;
        self.detailsButton.hidden = !self.progressView.hidden;

        [self downloadTextbookProxy:self.proxy reloadMetadataToContentID:nil];
    }
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateProgressToValue:(float)progress {

    [self.progressView setNumericProgress:progress];
    [self setBackgroundProgress:progress];
}

- (void)willBeginExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {
    
    [self.progressView setFillProgress:-1.0f];
    self.progressView.hidden = NO;
    self.progressBackgroundView.hidden = YES;
}

- (void)didFinishExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {
    
    [self.progressView setFillProgress:1.0f];
    self.progressView.hidden = YES;
    self.progressBackgroundView.hidden = YES;
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateUnpackingProgressToValue:(float)progress {
    [self.progressView setFillProgress:progress];
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didRaiseError:(NSError *)error {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didRaiseError:atIndex:)]) {
        [self.delegate view:self didRaiseError:error atIndex:(int)self.tag];
    }
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy reloadMetadataToContentID:(NSString *)contentID {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:shouldReloadCellAtIndex:)]) {
        [self.delegate view:self shouldReloadCellAtIndex:(int)self.tag];
    }
}

#pragma mark - Notifications

- (void)reattachDelegateNotification:(NSNotification *)notification {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookListCellReattachDelegateNotification object:nil];

    [self prepareView];

    [self downloadTextbookProxy:self.proxy reloadMetadataToContentID:nil];
}

#pragma mark - Private methods

- (void)setBackgroundProgress:(float)progress {

    if (progress == 0.0f) {
        self.progressBackgroundView.frame = self.contentView.frame;
        self.progressBackgroundView.hidden = NO;
    }

    else if (progress == 1.0f) {
        self.progressBackgroundView.frame = self.contentView.frame;
        self.progressBackgroundView.hidden = YES;
    }

    else {
        CGRect frame = self.contentView.frame;
        frame.origin.x = frame.size.width * progress;
        self.progressBackgroundView.frame = frame;
    }
}

@end
