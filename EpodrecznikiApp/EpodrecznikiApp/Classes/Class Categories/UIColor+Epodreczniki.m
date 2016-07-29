







#import "UIColor+Epodreczniki.h"

typedef enum { R, G, B, A } UIColorComponentIndices;

@implementation UIColor (Epodreczniki)

#pragma mark - Class methods

+ (UIColor *)epBlueColor {
    static UIColor *color = nil;
    if (!color) {
        color = [UIColor colorWithRed:(0.0f / 255.0f) green:(122.0f / 255.0f) blue:(255.0f / 255.0f) alpha:1.0f];
    }
    return color;
}

#pragma mark - Public methods

- (void)printMe {
    
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    NSString *string = [NSString stringWithFormat:@"<%@> (R: %f, G: %f, B: %f, A: %f) [R: %.1f, G: %.1f, B: %.1f] {#%02X%02X%02X}",
        self,
        components[R],
        components[G],
        components[B],
        components[A],
        components[R] * 255.0f,
        components[G] * 255.0f,
        components[B] * 255.0f,
        (unsigned int) (components[R] * 255.0f),
        (unsigned int) (components[G] * 255.0f),
        (unsigned int) (components[B] * 255.0f)
    ];
    NSLog(@"%@", string);
}

@end
