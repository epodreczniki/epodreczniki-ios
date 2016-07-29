







#import "EPStack.h"

@interface EPStack()

@property (nonatomic, strong) NSMutableArray *contents;

@end

@implementation EPStack

- (id)init {
    if (self = [super init]) {
        self.contents = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc {
    [self.contents removeAllObjects];
    self.contents = nil;
}

- (void)push:(id)object {
    [self.contents addObject:object];
}

- (id)pop {
    id returnObject = [self.contents lastObject];
    if (returnObject) {
        [self.contents removeLastObject];
    }
    return returnObject;
}

- (void)clear {
    [self.contents removeAllObjects];
}

- (NSInteger)size {
    return [self.contents count];
}

@end
