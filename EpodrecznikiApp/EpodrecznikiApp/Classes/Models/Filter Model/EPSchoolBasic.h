







#import <Foundation/Foundation.h>

@interface EPSchoolBasic : NSObject

@property (nonatomic, copy) NSString *schoolEducationLevel;
@property (nonatomic, copy) NSString *schoolClassLevel;


- (instancetype)initWithString:(NSString *)string;
- (NSString *)stringFromSchoolBasic;

@end
