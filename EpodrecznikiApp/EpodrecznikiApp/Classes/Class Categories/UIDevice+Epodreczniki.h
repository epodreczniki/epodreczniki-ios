







#import <UIKit/UIKit.h>

@interface UIDevice (Epodreczniki)

@property (nonatomic, readonly, getter = isIPad) BOOL ipad;
@property (nonatomic, readonly, getter = isIPhone) BOOL iphone;
@property (nonatomic, readonly, getter = isScreen35inch) BOOL screen35inch;
@property (nonatomic, readonly, getter = isScreen40inch) BOOL screen40inch;
@property (nonatomic, readonly) BOOL hasCellularHardware;

@end
