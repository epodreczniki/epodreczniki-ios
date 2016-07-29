







#import <Foundation/Foundation.h>

@interface EPJsonAPI : NSObject

@property (nonatomic, copy, readonly) NSString *apiURL;

- (instancetype)initWithApiURL:(NSString *)anApiURL;
- (id)objectFromAPI;
- (id)objectFromAPIWithUriString:(NSString *)uri;
- (id)objectFromAPIForPage:(int)page andLimit:(int)limit;

@end
