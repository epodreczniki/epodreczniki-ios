







#import "EPProgressCircleSmallView.h"
#import "EPIndicatorIndeterminate.h"
#import "RMDownloadIndicator.h"

#define kOffsetRatio        0.065f
#define kLineWidthRatio     0.030f

@interface EPProgressCircleSmallView ()

@property (nonatomic, weak) EPIndicatorIndeterminate *indicatorView;
@property (nonatomic, weak) RMDownloadIndicator *fillIndicatorView;

- (void)setIndicatorVisible:(BOOL)visible;
- (void)setFillProgressVisible:(BOOL)visible;
- (void)setNumericProgressVisible:(BOOL)visible;

@end

@implementation EPProgressCircleSmallView

#pragma mark - Lifecycle

- (void)awakeFromNib {
    self.backgroundImageView.image = [self.backgroundImageView.image imageWithColor:[UIColor epBlueColor]];
    self.progressLabel.textColor = [UIColor epBlueColor];
    [self setNumericProgress:0.0f];
}

- (void)dealloc {
    [self.indicatorView removeFromSuperview];
    self.indicatorView = nil;
    [self.fillIndicatorView removeFromSuperview];
    self.fillIndicatorView = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat height = self.frame.size.height;
    CGFloat fontSize = height / 3.0f;
    if (fabs(fontSize - self.progressLabel.font.pointSize) > 1.0f) {
        
        self.progressLabel.font = [UIFont systemFontOfSize:fontSize];
    }

    if (self.indicatorView) {
        CGFloat offset = height * kOffsetRatio;
        if (offset < 1) {
            offset = 1;
        }
        CGFloat lineWidth = height * kLineWidthRatio;
        
        CGRect frame = self.bounds;
        self.indicatorView.frame = CGRectMake(frame.origin.x + offset, frame.origin.y + offset, frame.size.width - 2 * offset, frame.size.height - 2 * offset);
        self.indicatorView.indicatorLineWidth = lineWidth;
    }

    if (self.fillIndicatorView) {
        
    }
}

#pragma mark - Public properties

- (void)setNumericProgress:(float)numericProgress {
    [self setIndicatorVisible:NO];
    [self setFillProgressVisible:NO];
    [self setNumericProgressVisible:YES];
    
    int progress_int = (int)roundf(numericProgress * 100);
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", progress_int];
    self.progressLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Accessability_stateDownloadingProgress", nil), progress_int];
    self.progressLabel.isAccessibilityElement = YES;
    self.isAccessibilityElement = NO;
}

- (void)setFillProgress:(float)numericProgress {
    [self setNumericProgressVisible:NO];
    
    if (numericProgress < 0.0f) {
        [self setFillProgressVisible:NO];
        [self setIndicatorVisible:YES];
    }
    else {
        [self setIndicatorVisible:NO];
        [self setFillProgressVisible:YES];
        
        [self.fillIndicatorView updateWithTotalBytes:1.0f downloadedBytes:numericProgress];
        int progress_int = (int)roundf(numericProgress * 100);
        [self makeAccessabilityTrait:UIAccessibilityTraitStaticText withLabel:[NSString stringWithFormat:NSLocalizedString(@"Accessability_stateUnpackingProgress", nil), progress_int]];
    }
}

#pragma mark - Private methods

- (void)setIndicatorVisible:(BOOL)visible {
    if (visible) {
        if (!self.indicatorView) {
            
            CGFloat height = self.frame.size.height;
            CGFloat offset = height * kOffsetRatio;
            if (offset < 1) {
                offset = 1;
            }
            CGFloat lineWidth = height * kLineWidthRatio;
            CGRect frame = self.bounds;
            
            EPIndicatorIndeterminate *indicator = [[EPIndicatorIndeterminate alloc] initWithFrame:CGRectZero];
            indicator.frame = CGRectMake(frame.origin.x + offset, frame.origin.y + offset, frame.size.width - 2 * offset, frame.size.height - 2 * offset);
            indicator.indicatorLineWidth = lineWidth;
            indicator.indicatorUpdateInterval = 0.1;
            indicator.indicatorColor = [UIColor epBlueColor];
            [indicator start];
            self.indicatorView = indicator;
            [self addSubview:indicator];
        }
    }
    else {
        if (self.indicatorView) {
            [self.indicatorView stop];
            [self.indicatorView removeFromSuperview];
            self.indicatorView = nil;
        }
    }
}

- (void)setFillProgressVisible:(BOOL)visible {
    if (visible) {
        if (!self.fillIndicatorView) {
            
            RMDownloadIndicator *fillIndicatorView = [[RMDownloadIndicator alloc] initWithFrame:self.bounds type:kRMFilledIndicator];
            fillIndicatorView.backgroundColor = [UIColor clearColor];
            [fillIndicatorView setFillColor:[UIColor epBlueColor]];
            [fillIndicatorView setStrokeColor:[UIColor epBlueColor]];
            fillIndicatorView.radiusPercent = 0.45;
            [fillIndicatorView loadIndicator];
            self.fillIndicatorView = fillIndicatorView;
            [self addSubview:fillIndicatorView];
        }
    }
    else {
        if (self.fillIndicatorView) {
            [self.fillIndicatorView removeFromSuperview];
            self.fillIndicatorView = nil;
        }
    }
}

- (void)setNumericProgressVisible:(BOOL)visible {
    self.progressLabel.hidden = !visible;
}

@end
