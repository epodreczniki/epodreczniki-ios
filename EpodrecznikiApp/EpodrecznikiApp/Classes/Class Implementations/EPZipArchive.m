







#import "EPZipArchive.h"
#import "ZipArchive.h"

@implementation EPZipArchive

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination {
    return [EPZipArchive unzipFileAtPath:path toDestination:destination progressBlock:nil];
}

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination progressBlock:(void (^)(long fileIndex, long filesCount))progressBlock {
    ZipArchive *archive = [ZipArchive new];

    if ([archive UnzipOpenFile:path]) {

        archive.progressBlock = ^(int percentage, int filesProcessed, unsigned long numFiles) {
            if (progressBlock) {
                progressBlock((long)filesProcessed, numFiles);
            }
        };

        BOOL result = [archive UnzipFileTo:destination overWrite:YES];

        archive.progressBlock = nil;
        
        return result;
    }
    
    return NO;
}

@end
