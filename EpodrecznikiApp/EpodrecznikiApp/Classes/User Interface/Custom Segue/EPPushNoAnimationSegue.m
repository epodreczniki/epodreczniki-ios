







#import "EPPushNoAnimationSegue.h"

@implementation EPPushNoAnimationSegue

- (void)perform {
    [[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:NO];
}

@end
