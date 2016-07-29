







#import <Foundation/Foundation.h>

@interface EPFilter : NSObject

@property (nonatomic) EPFilterType filterType;
@property (nonatomic, copy) NSString *filterValue;

- (instancetype)initWithString:(NSString *)string;
- (NSString *)stringFromFilter;

@end
