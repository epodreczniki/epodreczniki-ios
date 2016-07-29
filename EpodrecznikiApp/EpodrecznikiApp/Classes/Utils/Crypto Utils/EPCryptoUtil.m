







#import "EPCryptoUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation EPCryptoUtil

#pragma mark - Public methods

- (NSString *)createSalt {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *hash = [self makeHashSHA512:uuid];
    return hash;
}

- (NSString *)createHashWithString:(NSString *)string andSalt:(NSString *)salt {
    if ([NSObject isNullOrEmpty:string]) {
        return nil;
    }
    if ([NSObject isNullOrEmpty:salt]) {
        return nil;
    }
    
    NSString *inputString = [NSString stringWithFormat:@"%@%@", salt, string];
    NSString *hash = [self makeHashSHA512:inputString];
    
    return hash;
}

- (BOOL)matchesHash:(NSString *)sourceHash withString:(NSString *)string andSalt:(NSString *)salt {
    if ([NSObject isNullOrEmpty:sourceHash]) {
        return NO;
    }
    if ([NSObject isNullOrEmpty:string]) {
        return NO;
    }
    if ([NSObject isNullOrEmpty:salt]) {
        return NO;
    }
    
    NSString *resultString = [self createHashWithString:string andSalt:salt];
    BOOL result = [resultString isEqualToString:sourceHash];
    
    return result;
}

#pragma mark - Private methods

- (NSString *)makeHashSHA512:(NSString *)inputString {
    if ([NSObject isNullOrEmpty:inputString]) {
        return nil;
    }
    
    NSData *inputData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *outputData = [self SHA512HashWithData:inputData];
    
    if ([NSObject isNullOrEmpty:outputData]) {
        return nil;
    }
    
    NSMutableString *outputString = [NSMutableString new];
    unsigned char *bytes = (unsigned char *)outputData.bytes;
    for (int i = 0; i < outputData.length; i++) {
        [outputString appendFormat:@"%.2x", (int)bytes[i]];
    }
    
    return [NSString stringWithString:outputString];
}

- (NSData *)SHA512HashWithData:(NSData *)data {
    unsigned char hash[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512_CTX context;
    CC_SHA512_Init(&context);
    CC_SHA512_Update(&context, [data bytes], (CC_LONG)data.length);
    CC_SHA512_Final(hash, &context);
    return [NSData dataWithBytes:hash length:CC_SHA512_DIGEST_LENGTH];
}

@end
