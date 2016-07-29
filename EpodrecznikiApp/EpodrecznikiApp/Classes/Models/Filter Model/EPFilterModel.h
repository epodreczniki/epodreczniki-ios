







#import <Foundation/Foundation.h>
#import "EPFilter.h"
#import "EPSchool.h"
#import "EPSubject.h"

@interface EPFilterModel : EPConfigurableObject

- (NSArray *)arrayOfSchools;
- (NSArray *)arrayOfSubjects;

@end
