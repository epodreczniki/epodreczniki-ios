







#import "EPProgressCircleView.h"
#import "EPIndicatorIndeterminate.h"
#import "RMDownloadIndicator.h"

@interface EPProgressCircleView ()

@property (nonatomic, weak) EPIndicatorIndeterminate *indicatorView;
@property (nonatomic, weak) RMDownloadIndicator *fillIndicatorView;

- (void)setIndicatorVisible:(BOOL)visible;
- (void)setFillProgressVisible:(BOOL)visible;
- (void)setNumericProgressVisible:(BOOL)visible;

@end

@implementation EPProgressCircleView

#pragma mark - Lifecycle

- (void)awakeFromNib {
    self.backgroundImageView.image = [self.backgroundImageView.image imageWithColor:[UIColor epBlueColor]];
    self.progressLabel.textColor = [UIColor epBlueColor];
    self.percentageLabel.textColor = [UIColor epBlueColor];
    [self setNumericProgressVisible:0.0f];
}

- (void)dealloc {
    [self.indicatorView removeFromSuperview];
    self.indicatorView = nil;
    [self.fillIndicatorView removeFromSuperview];
    self.fillIndicatorView = nil;
}

#pragma mark - Public properties

- (void)setNumericProgress:(float)numericProgress {
    [self setIndicatorVisible:NO];
    [self setFillProgressVisible:NO];
    [self setNumericProgressVisible:YES];
    
    int progress_int = (int)ceil(numericProgress * 100);
    if (progress_int < 10) {
        self.progressLabel.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 23);
        self.progressLabel.text = [NSString stringWithFormat:@"%d\n", progress_int];
    }
    else {
        self.progressLabel.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.progressLabel.text = [NSString stringWithFormat:@"%d", progress_int];
    }
    
    [self makeAccessabilityTrait:UIAccessibilityTraitStaticText withLabel:[NSString stringWithFormat:NSLocalizedString(@"Accessability_stateDownloadingProgress", nil), progress_int]];
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
            CGRect frame = self.bounds;
            EPIndicatorIndeterminate *indicator = [[EPIndicatorIndeterminate alloc] initWithFrame:CGRectZero];
            indicator.frame = CGRectMake(frame.origin.x + 10, frame.origin.y + 10, frame.size.width - 20, frame.size.height - 20);
            indicator.indicatorLineWidth = 5.0;
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
    self.percentageLabel.hidden = !visible;
}

@end
