







#import <Foundation/Foundation.h>

@class EPConfiguration;

@interface EPConfigurableObject : NSObject

@property (nonatomic, weak, readonly) EPConfiguration *configuration;

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration;

@end
