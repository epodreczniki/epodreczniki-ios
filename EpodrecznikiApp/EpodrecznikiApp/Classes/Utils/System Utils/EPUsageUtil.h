







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

@interface EPUsageUtil : EPConfigurableObject

@end

@interface EPUsageUtil (Memory)

- (unsigned long long)numberOfFreeMemoryBytes;
- (BOOL)canLoadImageToMemoryFromPath:(NSString *)path;
- (unsigned long long)numberOfBytesInMemoryForImageSize:(CGSize)size;

@end

@interface EPUsageUtil (Storage)

- (CGSize)imageSizeFromPath:(NSString *)path;
- (uint64_t)numberOfFreeStorageBytes;
- (BOOL)canStoreFileWithSize:(uint64_t)sizeInBytes;
- (BOOL)canStoreAndUnarchiveFileWithSize:(uint64_t)sizeInBytes;

@end
