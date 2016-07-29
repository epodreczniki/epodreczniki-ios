







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

@interface EPDateUtil : EPConfigurableObject

- (NSString *)dateTimeFromDate:(NSDate *)date;
- (NSDate *)dateFromDateTimeString:(NSString *)string;

@end
