







#import "EPStoreCollection.h"

@implementation EPStoreCollection

- (void)dealloc {
    self.rootID = nil;
    self.apiContentID = nil;
    self.storeContentID = nil;
    self.storeTmpID = nil;
    self.storeUrl = nil;
    self.storePath = nil;

}

- (NSString *)description {
    NSString *stateString = @"";
    switch (self.state) {
        case EPTextbookStateTypeUnknown:
            stateString = @"EPTextbookStateTypeUnknown";
            break;
        case EPTextbookStateTypeToDownload:
            stateString = @"EPTextbookStateTypeToDownload";
            break;
        case EPTextbookStateTypeDownloading:
            stateString = @"EPTextbookStateTypeDownloading";
            break;
        case EPTextbookStateTypeNormal:
            stateString = @"EPTextbookStateTypeNormal";
            break;
        case EPTextbookStateTypeToUpdate:
            stateString = @"EPTextbookStateTypeToUpdate";
            break;
        case EPTextbookStateTypeUpdating:
            stateString = @"EPTextbookStateTypeUpdating";
            break;
        default:
            break;
    }
    
    NSMutableString *string = [NSMutableString stringWithString:@""];
    [string appendString:@"<EPStoreCollection> {\n"];
    [string appendFormat:@"\trootID: %@,\n", self.rootID];
    [string appendFormat:@"\tapiContentID: %@,\n", self.apiContentID];
    [string appendFormat:@"\tapiSize: %llu,\n", self.apiSize];
    [string appendFormat:@"\tstoreContentID: %@,\n", self.storeContentID];
    [string appendFormat:@"\tstoreTmpID: %@,\n", self.storeTmpID];
    [string appendFormat:@"\tstoreCompleted: %d,\n", self.storeCompleted];
    [string appendFormat:@"\tstoreUrl: %@,\n", self.storeUrl];
    [string appendFormat:@"\tstorePath: %@,\n", self.storePath];
    [string appendFormat:@"\tstate: %@,\n", stateString];
    [string appendString:@"}"];
    
    return string;
}

@end
