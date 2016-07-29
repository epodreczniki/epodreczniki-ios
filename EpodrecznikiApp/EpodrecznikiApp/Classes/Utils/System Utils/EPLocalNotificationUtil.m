







#import "EPLocalNotificationUtil.h"

@implementation EPLocalNotificationUtil

- (void)cancelAllLocalNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)postLocalNotificationWithMessage:(NSString *)message andFireDate:(NSDate *)fireDate {
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.repeatInterval = 0;
    notification.alertBody = message;
    notification.fireDate = fireDate;
    notification.timeZone = [NSTimeZone  defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
