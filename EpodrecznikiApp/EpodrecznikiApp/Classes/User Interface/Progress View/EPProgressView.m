







#import "EPProgressView.h"

@interface EPProgressView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *layerView;

- (void)updateProgress:(float)progress;

@end

@implementation EPProgressView

@synthesize progress = _progress;

#pragma mark - Lifecycle

- (void)awakeFromNib {
    self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.imageView];
    self.layerView = [[UIView alloc] initWithFrame:self.frame];
    self.layerView.backgroundColor = [UIColor whiteColor];
    self.layerView.alpha = 0.60f;
    self.layerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.layerView];
    [self sendSubviewToBack:self.layerView];
    [self sendSubviewToBack:self.imageView];
}

- (void)dealloc {
    self.imageView.image = nil;
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self.layerView removeFromSuperview];
    self.layerView = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateProgress:self.progress];
}

#pragma mark - Public properties

- (float)progress {
    return _progress;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self updateProgress:progress];
}

- (UIImage *)progressImage {
    return self.imageView.image;
}

- (void)setProgressImage:(UIImage *)progressImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = progressImage;
    });
}

#pragma mark - Private methods

- (void)updateProgress:(float)progress {

    float progressDiff = 1.0f - self.progress;
    
    CGRect frame = self.layerView.frame;
    frame.size.height = progressDiff * self.frame.size.height;
    self.layerView.frame = frame;
}

@end
