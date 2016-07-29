







#import <Foundation/Foundation.h>
#import "EPTocItem.h"
#import "EPPageItem.h"

@interface EPTocConfiguration : NSObject <NSCoding>

@property (nonatomic, strong) EPTocItem *tocRoot;
@property (nonatomic, strong) NSArray *pagesTeacherArray;
@property (nonatomic, strong) NSArray *pagesStudentArray;

@property (nonatomic, strong) NSDictionary *pathToIndexStudent;
@property (nonatomic, strong) NSDictionary *pathToIndexTeacher;

@end
