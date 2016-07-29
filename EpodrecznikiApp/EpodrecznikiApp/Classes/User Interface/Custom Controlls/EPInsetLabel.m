







#import "EPInsetLabel.h"

@implementation EPInsetLabel

#pragma mark - UIVIewRendering

- (void)drawRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end
