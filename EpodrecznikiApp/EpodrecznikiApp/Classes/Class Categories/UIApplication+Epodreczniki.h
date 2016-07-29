







#import <UIKit/UIKit.h>

@interface UIApplication (Epodreczniki)

@property (nonatomic, readonly, getter = isPortrait) BOOL portrait;
@property (nonatomic, readonly, getter = isLandscape) BOOL landscape;
@property (nonatomic, readonly) NSString *documentsDirectory;
@property (nonatomic, readonly) NSString *libraryDirectory;
@property (nonatomic, readonly) NSString *tmpDirectory;

@end
