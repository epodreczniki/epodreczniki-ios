







@interface EPZipArchive : NSObject

@property (nonatomic, copy) void (^progressBlock)(long fileIndex, long filesCount);

+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination;
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination progressBlock:(void (^)(long fileIndex, long filesCount))progressBlock;

@end
