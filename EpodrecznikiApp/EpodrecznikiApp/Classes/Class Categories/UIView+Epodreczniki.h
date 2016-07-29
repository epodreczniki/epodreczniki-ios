







#import <UIKit/UIKit.h>

@interface UIView (Epodreczniki)

+ (instancetype)viewWithNibName:(NSString *)name;
+ (instancetype)viewWithNibName:(NSString *)name tag:(int)tag;
+ (void)addShadowToView:(UIView *)view;
- (void)makeAccessabilityTrait:(UIAccessibilityTraits)trait withLabel:(NSString *)label;

@end
