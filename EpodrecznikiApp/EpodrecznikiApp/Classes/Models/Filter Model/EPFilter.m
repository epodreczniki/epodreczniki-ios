







#import "EPFilter.h"

#define kFilterTypeKey      @"kFilterTypeKey"
#define kFilterValueKey     @"kFilterValueKey"

@implementation EPFilter

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.filterType = EPFilterTypeNone;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        if (![NSObject isNullOrEmpty:string]) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            self.filterType = [dictionary[kFilterTypeKey] intValue];
            self.filterValue = dictionary[kFilterValueKey];
        }
    }
    return self;
}

- (void)dealloc {
    self.filterValue = nil;
}

#pragma mark - Public methods

- (NSString *)stringFromFilter {
    NSDictionary *dictionary = @{
        kFilterTypeKey: @(self.filterType),
        kFilterValueKey: (self.filterValue ? self.filterValue : @"")
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return json;
}

@end
