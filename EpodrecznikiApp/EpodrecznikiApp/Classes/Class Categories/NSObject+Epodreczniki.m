







#import "NSObject+Epodreczniki.h"

@implementation NSObject (Epodreczniki)

- (void)printMe {

}

+ (BOOL)isNullOrEmpty:(id)object {
    return object == nil
        || [object isKindOfClass:[NSNull class]]
        || ([object respondsToSelector:@selector(length)] && ![object respondsToSelector:@selector(count)] && [object length] == 0)
        || ([object respondsToSelector:@selector(count)] && [object count] == 0);
}

+ (BOOL)isNull:(id)object {
    return object == nil
        || [object isKindOfClass:[NSNull class]];
}

@end
