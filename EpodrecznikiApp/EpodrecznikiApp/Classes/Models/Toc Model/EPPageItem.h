







#import <Foundation/Foundation.h>

@interface EPPageItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *itemIDRef;
@property (nonatomic, getter = isTeacher) BOOL teacher;
@property (nonatomic, copy) NSString *pageId;
@property (nonatomic, copy) NSString *moduleId;

- (NSString *)stringFromPageItem;
+ (EPPageItem *)pageItemFromString:(NSString *)string;

@end
