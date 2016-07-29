







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

@interface EPLocalNotificationUtil : EPConfigurableObject

- (void)cancelAllLocalNotifications;
- (void)postLocalNotificationWithMessage:(NSString *)message andFireDate:(NSDate *)fireDate;

@end
