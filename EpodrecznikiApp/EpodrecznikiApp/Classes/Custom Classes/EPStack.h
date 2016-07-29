







#import <Foundation/Foundation.h>

@interface EPStack : NSObject

- (void)push:(id)object;
- (id)pop;
- (void)clear;
- (NSInteger)size;

@end
