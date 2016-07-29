







#import "EPUsageUtil.h"
#import <mach/mach.h>
#import <ImageIO/ImageIO.h>

@implementation EPUsageUtil

@end

@implementation EPUsageUtil (Memory)

- (unsigned long long)numberOfFreeMemoryBytes {
    mach_msg_type_number_t host_size = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vm_stat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != 0) {
        return 0UL;
    }
    return (unsigned long)vm_stat.free_count * (4UL * RAM_KB);
}

- (BOOL)canLoadImageToMemoryFromPath:(NSString *)path {
    
#if DEBUG_LOW_MEMORY
    return NO;
#endif
    
    unsigned long long imageBytesCount = [self numberOfBytesInMemoryForImageSize:[self imageSizeFromPath:path]];
    imageBytesCount = (unsigned long long)ceil(imageBytesCount * 1.2l);
    unsigned long long freeBytesCount = [self numberOfFreeMemoryBytes];
    
    BOOL memOK = freeBytesCount > imageBytesCount;
    BOOL sizeOK = imageBytesCount < kMaxImageSizeInBytesStoredInMemory;
    
#if DEBUG_MEMORY

#endif
    
    return memOK && sizeOK;
}

- (unsigned long long)numberOfBytesInMemoryForImageSize:(CGSize)size {
    return (unsigned long long)size.width * (unsigned long long)size.height * 4UL;
}

@end

@implementation EPUsageUtil (Storage)

- (CGSize)imageSizeFromPath:(NSString *)path {
    
    NSURL *imageFileURL = [NSURL fileURLWithPath:path];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageFileURL, NULL);
    if (imageSource == NULL) {
        return CGSizeZero;
    }
    
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    if (imageProperties != NULL) {
        CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL) {
            CFNumberGetValue(widthNum, kCFNumberCGFloatType, &width);
        }
        
        CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL) {
            CFNumberGetValue(heightNum, kCFNumberCGFloatType, &height);
        }
        
        CFRelease(imageProperties);
    }
    
    CFRelease(imageSource);
    
    return CGSizeMake(width, height);
}

- (uint64_t)numberOfFreeStorageBytes {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:nil];
    uint64_t freeSpace = [[dictionary objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    return freeSpace;
}

- (BOOL)canStoreFileWithSize:(uint64_t)sizeInBytes {
    return [self numberOfFreeStorageBytes] > sizeInBytes;
}

- (BOOL)canStoreAndUnarchiveFileWithSize:(uint64_t)sizeInBytes {
    return [self canStoreFileWithSize:(sizeInBytes * 2LL)];
}

@end
