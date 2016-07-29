







#import "EPTextbookCollectionViewCell.h"
#import "EPTextbooksListContainer.h"

@interface EPTextbookCollectionViewCell () {
    CGSize authorSizeOriginal;
    CGSize titleSizeOriginal;
    CGFloat verticalGap;
}

@property (nonatomic, strong) EPTextbookCollectionViewCellReverseView *cellReverseView;

- (void)coverImageViewGestureForTapRecognizer:(UITapGestureRecognizer *)tapRecognizer;
- (void)reattachDelegateNotification:(NSNotification *)notification;

@end

@implementation EPTextbookCollectionViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [self prepareForReuse];

    titleSizeOriginal = CGSizeMake(300, 90);
    authorSizeOriginal = CGSizeMake(300, 55);
    verticalGap = 5.0f;
    self.titleLabel.numberOfLines = 3;
    self.authorLabel.numberOfLines = 2;

    [self.markImageView removeFromSuperview];
    [self.coverImageView addSubview:self.markImageView];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverImageViewGestureForTapRecognizer:)];
    [self.coverImageView addGestureRecognizer:singleTap];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookListCellReattachDelegateNotification object:nil];
    
    NSArray *array = self.coverImageView.gestureRecognizers;
    for (UIGestureRecognizer *recognizer in array) {
        [self.coverImageView removeGestureRecognizer:recognizer];
    }
    self.coverImageView = nil;
    self.markImageView = nil;
    self.titleLabel = nil;
    self.authorLabel = nil;
    self.cellReverseView.delegate = nil;
    self.cellReverseView = nil;
    self.delegate = nil;
    if (self.proxy) {
        self.proxy.delegate = nil;
    }
    self.proxy = nil;
}

- (void)prepareForReuse {

    self.coverImageView.progressImage = nil;
    self.markImageView.hidden = YES;
    self.titleLabel.text = nil;
    self.authorLabel.text = nil;

    if (self.cellReverseView && ![EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
        self.cellReverseView.delegate = nil;

        [UIView transitionFromView:self.cellReverseView toView:self.coverImageView duration:0.0f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            [self.cellReverseView removeFromSuperview];
            self.cellReverseView = nil;
        }];
        
        self.cellReverseView.delegate = nil;
        self.cellReverseView = nil;


    }

    if (self.proxy) {
        self.proxy.delegate = nil;
    }
    self.proxy = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect titleFrame = CGRectZero;
    CGRect authorFrame = CGRectZero;

    if (![NSObject isNullOrEmpty:self.titleLabel.text]) {
        CGSize titleSize = [self.titleLabel sizeThatFits:titleSizeOriginal];
        titleFrame.origin.x = 0;
        titleFrame.origin.y = self.coverImageView.frame.size.height + 4 * verticalGap;
        titleFrame.size.width = titleSizeOriginal.width;
        titleFrame.size.height = MIN(titleSize.height, titleSizeOriginal.height);
        self.titleLabel.frame = titleFrame;
    }

    if (![NSObject isNullOrEmpty:self.authorLabel.text]) {
        CGSize authorSize = [self.authorLabel sizeThatFits:authorSizeOriginal];
        authorFrame.origin.x = 0;
        authorFrame.origin.y = titleFrame.origin.y + titleFrame.size.height + verticalGap;
        authorFrame.size.width = titleSizeOriginal.width;
        authorFrame.size.height = MIN(authorSize.height, authorSizeOriginal.height);
        self.authorLabel.frame = authorFrame;
    }
}

#pragma mark - Public methods

- (void)setCoverImage:(UIImage *)image animated:(BOOL)animated {

    if (!image) {
        return;
    }
    
    self.coverImageView.progressImage = image;
    self.coverImageView.alpha = 1.0f;
    [UIView addShadowToView:self.coverImageView];
}

- (CGSize)sizeForCellWithTextbookTitle:(NSString *)title andAuthor:(NSString *)author {
    CGSize resultSize = CGSizeZero;
    resultSize.width = self.frame.size.width;
    resultSize.height = self.coverImageView.frame.size.height;
    resultSize.height += 4 * verticalGap;
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;

    if (![NSObject isNullOrEmpty:title]) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:self.titleLabel.font forKey:NSFontAttributeName];
        CGSize titleSize = [title boundingRectWithSize:titleSizeOriginal options:options attributes:attributes context:nil].size;
        resultSize.height += MIN(titleSize.height, titleSizeOriginal.height);
        resultSize.height += verticalGap;
    }

    if (![NSObject isNullOrEmpty:author]) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:self.authorLabel.font forKey:NSFontAttributeName];
        CGSize authorSize = [author boundingRectWithSize:authorSizeOriginal options:options attributes:attributes context:nil].size;
        resultSize.height += MIN(authorSize.height, authorSizeOriginal.height);
    }
    
    return resultSize;
}

- (void)prepareView {

    if (!self.cellReverseView) {
        self.proxy.delegate = self;
    }

    EPTextbookStateType state = self.proxy.storeCollection.state;
    self.markImageView.hidden = !(state == EPTextbookStateTypeToUpdate || state == EPTextbookStateTypeUpdating);

    if (state == EPTextbookStateTypeToDownload) {
        self.coverImageView.progress = 0.0f;
    }

    else if (state == EPTextbookStateTypeNormal || state == EPTextbookStateTypeToUpdate) {
        self.coverImageView.progress = 1.0f;
    }

    if (self.proxy.isUnpacking) {
        self.coverImageView.progress = 1.0f;
    }

    if ([EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
        
        [self coverImageViewGestureForTapRecognizer:nil];
    }
}

#pragma mark - Private methods

- (void)coverImageViewGestureForTapRecognizer:(UITapGestureRecognizer *)tapRecognizer {

    if (self.cellReverseView) {
        return;
    }

    self.cellReverseView = [EPTextbookCollectionViewCellReverseView viewWithNibName:@"EPTextbookCollectionViewCellReverseView"];
    self.cellReverseView.delegate = self;
    [self.cellReverseView prepareView];

    [UIView transitionFromView:self.coverImageView toView:self.cellReverseView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
}

#pragma mark - EPTextbookCollectionViewCellReverseViewDelegate

- (EPDownloadTextbookProxy *)downloadTextbookProxyForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {
    return self.proxy;
}

- (void)didClickBackButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView animated:(BOOL)animated {

    self.cellReverseView.delegate = nil;
    self.proxy.delegate = self;
    [self prepareView];
    
    NSTimeInterval duration = (animated ? 0.5f : 0.0f);

    [UIView transitionFromView:self.cellReverseView toView:self.coverImageView duration:duration options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        [self.cellReverseView removeFromSuperview];
        self.cellReverseView = nil;
    }];
}

- (void)didClickDownloadButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didSelectDownloadButtonAtIndex:)]) {
        [self.delegate view:self didSelectDownloadButtonAtIndex:(int)self.tag];
    }
}

- (void)didClickUpdateButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didSelectUpdateButtonAtIndex:)]) {
        [self.delegate view:self didSelectUpdateButtonAtIndex:(int)self.tag];
    }
}

- (void)didClickDeleteButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didSelectDeleteButtonAtIndex:)]) {
        [self.delegate view:self didSelectDeleteButtonAtIndex:(int)self.tag];
    }
}

- (void)didClickCancelButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didSelectCancelButtonAtIndex:)]) {
        [self.delegate view:self didSelectCancelButtonAtIndex:(int)self.tag];
    }
}

- (void)didClickReadButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didSelectReadButtonAtIndex:)]) {
        [self.delegate view:self didSelectReadButtonAtIndex:(int)self.tag];
    }
}

- (void)didClickDetailsButtonForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didSelectDetailsButtonAtIndex:)]) {

        self.proxy.delegate = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reattachDelegateNotification:) name:kTextbookListCellReattachDelegateNotification object:nil];

        [self.delegate view:self didSelectDetailsButtonAtIndex:(int)self.tag];
    }
}

- (void)didRaiseError:(NSError *)error forCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {

    [self downloadTextbookProxy:self.proxy didRaiseError:error];
}

- (void)shouldReloadMetadataForCellReverseView:(EPTextbookCollectionViewCellReverseView *)cellReverseView {

    [self downloadTextbookProxy:self.proxy reloadMetadataToContentID:nil];
}

#pragma mark - EPDownloadTextbookProxyDelegate

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didChangeTextbookStateTo:(EPTextbookStateType)toState fromState:(EPTextbookStateType)fromState {
    [self prepareView];
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateProgressToValue:(float)progress {

    if (ABS(progress - self.coverImageView.progress) > 0.005f || progress == 0.0f || progress == 1.0f) {
        self.coverImageView.progress = progress;
    }
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didRaiseError:(NSError *)error {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:didRaiseError:atIndex:)]) {
        [self.delegate view:self didRaiseError:error atIndex:(int)self.tag];
    }
}

- (void)willBeginExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {

    self.coverImageView.progress = 1.0f;
}

- (void)didFinishExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {

    self.coverImageView.progress = 1.0f;
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateUnpackingProgressToValue:(float)progress {

}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy reloadMetadataToContentID:(NSString *)contentID {

    if (self.delegate && [self.delegate respondsToSelector:@selector(view:shouldReloadCellAtIndex:)]) {
        [self.delegate view:self shouldReloadCellAtIndex:(int)self.tag];
    }
}

#pragma mark - Notifications

- (void)reattachDelegateNotification:(NSNotification *)notification {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookListCellReattachDelegateNotification object:nil];

    if (self.cellReverseView) {
        self.proxy.delegate = nil;
        [self.cellReverseView prepareView];
    }
    else {
        self.proxy.delegate = self;
    }

    [self downloadTextbookProxy:self.proxy reloadMetadataToContentID:nil];
}

@end
