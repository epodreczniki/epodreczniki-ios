







#import "UIPageViewController+Epodreczniki.h"

@implementation UIPageViewController (Epodreczniki)

- (BOOL)isScrollingEnabled {
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            return scrollView.scrollEnabled;
        }
    }
    
    return NO;
}

- (void)setScrollingEnabled:(BOOL)scrollingEnabled {
    
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            scrollView.scrollEnabled = scrollingEnabled;
            
            break;
        }
    }
}

@end
