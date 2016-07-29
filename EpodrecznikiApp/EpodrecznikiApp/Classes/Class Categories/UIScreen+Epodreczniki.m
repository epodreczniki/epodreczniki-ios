







#import "UIScreen+Epodreczniki.h"

@implementation UIScreen (Epodreczniki)

- (CGSize)portraitScreenSize {
    
    CGSize newSize = CGSizeZero;
    newSize.width = MIN(self.bounds.size.height, self.bounds.size.width);
    newSize.height = MAX(self.bounds.size.height, self.bounds.size.width);
    
    return newSize;
}

- (CGSize)landscapeScreenSize {
    
    CGSize newSize = CGSizeZero;
    newSize.width = MAX(self.bounds.size.height, self.bounds.size.width);
    newSize.height = MIN(self.bounds.size.height, self.bounds.size.width);
    
    return newSize;
}

@end
