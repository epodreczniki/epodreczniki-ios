







#import "EPIndicatorIndeterminate.h"
#import <QuartzCore/QuartzCore.h>

@interface EPIndicatorIndeterminate ()

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) int indicatorPosition;

@end

@implementation EPIndicatorIndeterminate

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.indicatorLineWidth = 1.0;
        self.backgroundColor = [UIColor clearColor];
        self.indicatorColor = [UIColor whiteColor];
        self.indicatorUpdateInterval = 0.1;
        self.indicatorPosition = 0;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.indicatorLineWidth = 1.0;
        self.backgroundColor = [UIColor clearColor];
        self.indicatorColor = [UIColor whiteColor];
        self.indicatorUpdateInterval = 0.1;
        self.indicatorPosition = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.indicatorLineWidth = 1.0;
        self.backgroundColor = [UIColor clearColor];
        self.indicatorColor = [UIColor whiteColor];
        self.indicatorUpdateInterval = 0.1;
        self.indicatorPosition = 0;
    }
    return self;
}

- (void)dealloc {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    self.indicatorColor = nil;
}

#pragma mark - Public methods

- (void)start {
    if (!self.updateTimer.isValid) {
        self.updateTimer = [NSTimer timerWithTimeInterval:self.indicatorUpdateInterval target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    if (self.updateTimer.isValid) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
    [self removeFromSuperview];
}

#pragma mark - UIViewRendering

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.indicatorLineWidth);
    
    double r1 = rect.size.height * 0.5;
    double r2 = rect.size.height * 0.25;
    double ex = rect.size.width * 0.5;
    double ey = rect.size.height * 0.5;
    
    for (int i = 1; i < 12; i++) {
        CGColorRef color = [[self.indicatorColor colorWithAlphaComponent:(i / 11.0)] CGColor];
        CGContextSetStrokeColorWithColor(context, color);
        double line = i + self.indicatorPosition;
        CGContextMoveToPoint(context,    ex + r1 * cos(M_PI / 10.0 * line), ey + r1 * sin(M_PI / 10.0 * line));
        CGContextAddLineToPoint(context, ex + r2 * cos(M_PI / 10.0 * line), ey + r2 * sin(M_PI / 10.0 * line));
        CGContextStrokePath(context);
    }
    
    self.indicatorPosition += 1;
    self.indicatorPosition = self.indicatorPosition % 20;
}

@end
