







#import "NSFileManager+Epodreczniki.h"

@implementation NSFileManager (Epodreczniki)

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){

    }
    else {

    }
    return success;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path {
    return [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
}

@end
