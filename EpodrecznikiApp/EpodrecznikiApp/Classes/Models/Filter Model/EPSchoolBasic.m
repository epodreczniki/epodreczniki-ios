







#import "EPSchoolBasic.h"

#define kSchoolEducationLevelKey    @"kSchoolEducationLevelKey"
#define kSchoolClassLevelKey        @"kSchoolClassLevelKey"

@implementation EPSchoolBasic

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        if (![NSObject isNullOrEmpty:string]) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            self.schoolEducationLevel = dictionary[kSchoolEducationLevelKey];
            self.schoolClassLevel = dictionary[kSchoolClassLevelKey];
        }
    }
    return self;
}

- (NSString *)stringFromSchoolBasic {
    NSDictionary *dictionary = @{
        kSchoolEducationLevelKey: (self.schoolEducationLevel ? self.schoolEducationLevel : @""),
        kSchoolClassLevelKey: (self.schoolClassLevel ? self.schoolClassLevel : @"")
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return json;
}

@end
