







#import "EPBackButtonItem.h"

@implementation EPBackButtonItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"EPBackButtonItem_title", nil);
        self.tintColor = [UIColor epBlueColor];
    }
    return self;
}

@end
