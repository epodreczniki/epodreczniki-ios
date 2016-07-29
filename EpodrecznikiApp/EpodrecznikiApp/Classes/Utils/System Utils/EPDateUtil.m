







#import "EPDateUtil.h"

@interface EPDateUtil()

@property (nonatomic, strong) NSDateFormatter *dateTimeFormatter;

@end

@implementation EPDateUtil

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        self.dateTimeFormatter = [NSDateFormatter new];
        [self.dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [self.dateTimeFormatter setLocale:enUSPOSIXLocale];
    }
    return self;
}

- (void)dealloc {
    self.dateTimeFormatter = nil;
}

#pragma mark - Public methods

- (NSString *)dateTimeFromDate:(NSDate *)date {
    if (!date) {
        return nil;
    }
    return [self.dateTimeFormatter stringFromDate:date];
}

- (NSDate *)dateFromDateTimeString:(NSString *)string {
    if (!string) {
        return nil;
    }
    return [self.dateTimeFormatter dateFromString:string];
}

@end
