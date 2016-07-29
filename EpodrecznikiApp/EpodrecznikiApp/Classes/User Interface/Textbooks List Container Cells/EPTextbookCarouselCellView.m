







#import "EPTextbookCarouselCellView.h"
#import "EPAppDelegate.h"

#define kMargin     (69.0 / 6.0)

@interface EPTextbookCarouselCellView ()

- (void)reattachDelegateNotification:(NSNotification *)notification;

@end

@implementation EPTextbookCarouselCellView

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];

    self.progressView = [EPProgressCircleSmallView viewWithNibName:@"EPProgressCircleSmallView"];
    self.progressView.frame = self.detailsButton.frame;
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.dataContentView addSubview:self.progressView];

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

    UITapGestureRecognizer *singleCoverTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverTap:)];
    [self.coverAndMarkView addGestureRecognizer:singleCoverTap];
    UITapGestureRecognizer *singleProgressTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleProgressTap:)];
    [self.progressView addGestureRecognizer:singleProgressTap];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookListCellReattachDelegateNotification object:nil];
    
    self.delegate = nil;
    if (self.proxy) {
        self.proxy.delegate = nil;
    }
    self.proxy = nil;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect viewFrame = self.frame;

    if (self.animatedLayoutChange) {
        
        if (![UIApplication sharedApplication].isPortrait) {
            CGRect dataFrame = self.dataContentView.frame;
            dataFrame.origin.y = kMargin;
            dataFrame.origin.x = self.coverAndMarkView.frame.origin.x + self.coverAndMarkView.frame.size.width + kMargin;
            self.dataContentView.frame = dataFrame;
        }
        else {
            CGRect dataFrame = self.dataContentView.frame;
            dataFrame.origin.x = kMargin;
            dataFrame.origin.y = self.coverAndMarkView.frame.origin.y + self.coverAndMarkView.frame.size.height + kMargin;
            self.dataContentView.frame = dataFrame;
        }
        
        [UIView beginAnimations:@"layout views" context:nil];
        [UIView setAnimationDuration:0.5];
    }

    if ([UIApplication sharedApplication].isPortrait) {
        
        CGFloat dataHeight = 140.0f;

        CGRect coverFrame = CGRectZero;
        coverFrame.origin.x = kMargin;
        coverFrame.origin.y = kMargin;
        coverFrame.size.width = viewFrame.size.width - 2 * kMargin;
        coverFrame.size.height = roundf(coverFrame.size.width * sqrtf(2));

        CGFloat maxHeight = viewFrame.size.height - dataHeight - 3 * kMargin;
        if (coverFrame.size.height > maxHeight) {
            
            coverFrame.size.height = maxHeight;
            coverFrame.size.width = roundf(maxHeight / sqrtf(2));
            self.coverAndMarkView.frame = coverFrame;
            self.coverAndMarkView.center = CGPointMake(self.center.x, self.coverAndMarkView.center.y);
        }
        else {
            self.coverAndMarkView.frame = coverFrame;
        }

        CGRect dataFrame = self.dataContentView.frame;
        dataFrame.origin.y = coverFrame.origin.y + coverFrame.size.height + kMargin;
        dataFrame.size.width = viewFrame.size.width - 2 * kMargin;
        dataFrame.size.height = dataHeight;
        self.dataContentView.frame = dataFrame;
        self.dataContentView.center = CGPointMake(self.center.x, self.dataContentView.center.y);


        CGSize titleLabelsize = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.frame.size.width, CGFLOAT_MAX)];
        self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.frame.size.width, titleLabelsize.height);

        CGSize authorLabelSize = [self.authorLabel sizeThatFits:CGSizeMake(self.authorLabel.frame.size.width, CGFLOAT_MAX)];
        CGRect tmpFrame = CGRectZero;
        tmpFrame.origin.x = 0;
        tmpFrame.origin.y = kMargin * 0.5f + titleLabelsize.height + self.titleLabel.frame.origin.y;
        tmpFrame.size.width = self.titleLabel.frame.size.width;
        tmpFrame.size.height = authorLabelSize.height;
        self.authorLabel.frame = tmpFrame;
    }

    else {

        CGRect coverFrame = CGRectZero;
        coverFrame.origin.x = kMargin;
        coverFrame.origin.y = kMargin;
        coverFrame.size.height = viewFrame.size.height - 2 * kMargin;
        coverFrame.size.width = roundf(coverFrame.size.height / sqrtf(2));
        self.coverAndMarkView.frame = coverFrame;

        CGRect dataContentViewRect = CGRectZero;
        dataContentViewRect.origin.x = coverFrame.origin.x + coverFrame.size.width + kMargin;
        dataContentViewRect.origin.y = kMargin;
        dataContentViewRect.size.width = viewFrame.size.width - dataContentViewRect.origin.x - kMargin;
        dataContentViewRect.size.height = coverFrame.size.height;
        self.dataContentView.frame = dataContentViewRect;

        CGSize titleLabelsize = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.frame.size.width, CGFLOAT_MAX)];
        self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.frame.size.width, titleLabelsize.height);

        CGSize authorLabelSize = [self.authorLabel sizeThatFits:CGSizeMake(self.authorLabel.frame.size.width, CGFLOAT_MAX)];
        CGRect tmpFrame = CGRectZero;
        tmpFrame.origin.x = 0;
        tmpFrame.origin.y = self.titleLabel.frame.origin.y + titleLabelsize.height + kMargin;
        tmpFrame.size.width = self.titleLabel.frame.size.width;
        tmpFrame.size.height = authorLabelSize.height;
        self.authorLabel.frame = tmpFrame;
    }

    [UIView addShadowToView:self.coverAndMarkView];

    if (self.animatedLayoutChange) {
        [UIView commitAnimations];
        self.animatedLayoutChange = NO;
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

- (void)handleCoverTap:(UIGestureRecognizer *)gestureRecognizer {
    
    EPTextbookStateType state = self.proxy.storeCollection.state;
    if (state == EPTextbookStateTypeNormal || state == EPTextbookStateTypeToUpdate) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(view:didSelectReadButtonAtIndex:)]) {
            [self.delegate view:self didSelectReadButtonAtIndex:(int)self.tag];
        }
    }
    else {
        [self detailsButtonAction:nil];
    }
}

- (void)handleProgressTap:(UIGestureRecognizer *)gestureRecognizer {
    
    [self detailsButtonAction:nil];
}

#pragma mark - Public methods

- (void)setCoverImage:(UIImage *)image animated:(BOOL)animated {

    if (!image) {
        return;
    }
    
    self.coverImageView.progressImage = image;
    [UIView addShadowToView:self.coverAndMarkView];
    self.coverImageView.alpha = 1.0f;
}

- (void)prepareView {

    self.proxy.delegate = self;

    EPTextbookStateType state = self.proxy.storeCollection.state;
    self.markImageView.hidden = !(state == EPTextbookStateTypeToUpdate || state == EPTextbookStateTypeUpdating);

    if (state == EPTextbookStateTypeToDownload) {
        self.coverImageView.progress = 0.0f;
        [self.progressView setNumericProgress:0.0f];
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
    }

    else if (state == EPTextbookStateTypeNormal || state == EPTextbookStateTypeToUpdate) {
        self.coverImageView.progress = 1.0f;
        [self.progressView setNumericProgress:1.0f];
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
    }

    else if (state == EPTextbookStateTypeDownloading || state == EPTextbookStateTypeUpdating) {
        self.progressView.hidden = NO;
        self.detailsButton.hidden = YES;
    }

    if (self.proxy.isUnpacking) {
        [self willBeginExtractingForDownloadTextbookProxy:self.proxy];
    }
}

#pragma mark - EPDownloadTextbookProxyDelegate

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didChangeTextbookStateTo:(EPTextbookStateType)toState fromState:(EPTextbookStateType)fromState {

    if (fromState == EPTextbookStateTypeToDownload && toState == EPTextbookStateTypeDownloading) {
        
        [self.progressView setNumericProgress:0.0f];
        self.coverImageView.progress = 0.0f;
        self.progressView.hidden = NO;
        self.detailsButton.hidden = YES;
        self.markImageView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeToDownload) {
        
        [self.progressView setNumericProgress:0.0f];
        self.coverImageView.progress = 0.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeNormal) {
        
        [self.progressView setNumericProgress:1.0f];
        self.coverImageView.progress = 1.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeToUpdate) {
        
        [self.progressView setNumericProgress:1.0f];
        self.coverImageView.progress = 1.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = NO;
    }

    else if (fromState == EPTextbookStateTypeNormal && toState == EPTextbookStateTypeToUpdate) {
        
        [self.progressView setNumericProgress:1.0f];
        self.coverImageView.progress = 1.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = NO;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeNormal) {
        
        [self.progressView setNumericProgress:1.0f];
        self.coverImageView.progress = 1.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeUpdating) {
        
        [self.progressView setNumericProgress:0.0f];
        self.coverImageView.progress = 0.0f;
        self.progressView.hidden = NO;
        self.detailsButton.hidden = YES;
        self.markImageView.hidden = NO;
    }

    else if (fromState == EPTextbookStateTypeUpdating && toState == EPTextbookStateTypeToUpdate) {
        
        [self.progressView setNumericProgress:1.0f];
        self.coverImageView.progress = 1.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = NO;
    }

    else if (fromState == EPTextbookStateTypeUpdating && toState == EPTextbookStateTypeNormal) {
        
        [self.progressView setNumericProgress:1.0f];
        self.coverImageView.progress = 1.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeNormal && toState == EPTextbookStateTypeToDownload) {
        
        [self.progressView setNumericProgress:0.0f];
        self.coverImageView.progress = 0.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = YES;
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeToDownload) {
        
        [self.progressView setNumericProgress:0.0f];
        self.coverImageView.progress = 0.0f;
        self.progressView.hidden = YES;
        self.detailsButton.hidden = NO;
        self.markImageView.hidden = YES;

        [self downloadTextbookProxy:self.proxy reloadMetadataToContentID:nil];
    }
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateProgressToValue:(float)progress {

    if (ABS(progress - self.coverImageView.progress) > 0.005f || progress == 0.0f || progress == 1.0f) {
        self.coverImageView.progress = progress;
        [self.progressView setNumericProgress:progress];
    }
}

- (void)willBeginExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {
    
    self.coverImageView.progress = 1.0;
    [self.progressView setFillProgress:-1.0f];
    self.progressView.hidden = NO;
}

- (void)didFinishExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {
    
    self.coverImageView.progress = 1.0;
    [self.progressView setFillProgress:1.0f];
    self.progressView.hidden = YES;
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

@end
