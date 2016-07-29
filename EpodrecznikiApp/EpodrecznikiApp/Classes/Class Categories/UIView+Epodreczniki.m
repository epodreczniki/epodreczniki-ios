







#import "UIView+Epodreczniki.h"

@implementation UIView (Epodreczniki)

+ (instancetype)viewWithNibName:(NSString *)name {
    NSAssert(name, @"Name cannot be nil");

    NSArray *views = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];

    if (views.count > 0) {
        return views[0];
    }
    
    return nil;
}

+ (instancetype)viewWithNibName:(NSString *)name tag:(int)tag {
    NSAssert(name, @"Name cannot be nil");

    NSArray *views = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];

    if (views.count > 0) {

        for (UIView *view in views) {

            if (view.tag == tag) {
                return view;
            }
        }
    }
    
    return nil;
}

+ (void)addShadowToView:(UIView *)view {
    if (!view) {
        return;
    }
    
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
}

- (void)makeAccessabilityTrait:(UIAccessibilityTraits)trait withLabel:(NSString *)label {
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = trait;
    self.accessibilityLabel = label;
}

#pragma mark - NSObject+Epodreczniki

- (void)printMe {

}

- (NSString *)printMeRecursive:(UIView *)view level:(int)level {
    NSMutableString *subviewsString = [NSMutableString stringWithString:@""];
    for (UIView *subview in view.subviews) {
        [subviewsString appendString:[self printMeRecursive:subview level:(level + 1)]];
    }
    return [@"" stringByAppendingFormat:@"\n%@%@%@", [@"" stringByPaddingToLength:(level * 4) withString:@" |  " startingAtIndex:0], [view debugDescription], subviewsString];
}

@end
