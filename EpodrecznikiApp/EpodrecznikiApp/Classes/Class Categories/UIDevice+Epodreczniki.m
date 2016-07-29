







#import "UIDevice+Epodreczniki.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation UIDevice (Epodreczniki)

- (BOOL)isIPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (BOOL)isIPhone {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

- (BOOL)isScreen35inch {
    return [UIScreen mainScreen].portraitScreenSize.height == 480.0f;
}

- (BOOL)isScreen40inch {
    return [UIScreen mainScreen].portraitScreenSize.height == 568.0f;
}

- (BOOL)hasCellularHardware {
    CTTelephonyNetworkInfo *ctInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = ctInfo.subscriberCellularProvider;
    return carrier != nil;
}

@end
