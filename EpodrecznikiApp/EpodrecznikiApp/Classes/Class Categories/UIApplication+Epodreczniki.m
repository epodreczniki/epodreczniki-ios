







#import "UIApplication+Epodreczniki.h"

@implementation UIApplication (Epodreczniki)

- (BOOL)isPortrait {
    return UIDeviceOrientationIsPortrait((UIDeviceOrientation)[self statusBarOrientation]);
}

- (BOOL)isLandscape {
    return UIDeviceOrientationIsLandscape((UIDeviceOrientation)[self statusBarOrientation]);
}

#pragma mark - Public properties

- (NSString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)libraryDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)tmpDirectory {
    return NSTemporaryDirectory();
}

@end
