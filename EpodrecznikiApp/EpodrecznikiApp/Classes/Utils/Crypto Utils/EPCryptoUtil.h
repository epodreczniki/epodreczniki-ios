







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

@interface EPCryptoUtil : EPConfigurableObject

- (NSString *)createSalt;
- (NSString *)createHashWithString:(NSString *)string andSalt:(NSString *)salt;
- (BOOL)matchesHash:(NSString *)sourceHash withString:(NSString *)string andSalt:(NSString *)salt;

@end
