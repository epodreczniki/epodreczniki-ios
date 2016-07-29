







#import "EPConfigurableObject.h"

@implementation EPConfigurableObject

@synthesize configuration = _configuration;

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    NSAssert(aConfiguration, @"Configuration cannot be nil");
    self = [super init];
    if (self) {
        _configuration = aConfiguration;
    }
    return self;
}

- (void)dealloc {
    _configuration = nil;
}

@end
