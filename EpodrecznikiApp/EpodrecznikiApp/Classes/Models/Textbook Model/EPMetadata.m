







#import "EPMetadata.h"

@implementation EPMetadata

#pragma mark - Lifecycle

- (void)dealloc {
    self.rootID = nil;
    self.storeContentID = nil;
    self.apiContentID = nil;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@""];
    [string appendString:@"<EPMetadata> {\n"];
    [string appendFormat:@"\trootID: %@,\n", self.rootID];
    [string appendFormat:@"\tstoreContentID: %@,\n", self.storeContentID];
    [string appendFormat:@"\tapiContentID: %@,\n", self.apiContentID];
    [string appendString:@"}"];
    
    return string;
}

#pragma mark - Public methods

- (NSString *)actualContentID {
    if (![NSObject isNullOrEmpty:self.storeContentID]) {
        return self.storeContentID;
    }
    if (![NSObject isNullOrEmpty:self.apiContentID]) {
        return self.apiContentID;
    }
    return nil;
}

@end
