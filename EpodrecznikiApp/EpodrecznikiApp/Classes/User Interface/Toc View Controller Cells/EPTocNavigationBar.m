







#import "EPTocNavigationBar.h"

@implementation EPTocNavigationBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    int errorMargin = 5;
    CGRect smallerFrame = CGRectMake(0 , 0 - errorMargin, self.frame.size.width, self.frame.size.height);
    BOOL isTouchAllowed =  (CGRectContainsPoint(smallerFrame, point) == 1);
    
    if (isTouchAllowed) {
        self.userInteractionEnabled = YES;
    } else {
        self.userInteractionEnabled = NO;
    }
    return [super hitTest:point withEvent:event];
}

@end
