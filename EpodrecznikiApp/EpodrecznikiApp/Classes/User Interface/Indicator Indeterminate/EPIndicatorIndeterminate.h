







#import <UIKit/UIKit.h>

@interface EPIndicatorIndeterminate : UIView

@property (nonatomic) float indicatorLineWidth;
@property (nonatomic) float indicatorUpdateInterval;
@property (nonatomic, copy) UIColor *indicatorColor;

- (void)start;
- (void)stop;

@end
