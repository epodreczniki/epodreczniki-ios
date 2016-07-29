







#import "EPTocConfiguration.h"

#define kTocRootKey                 @"kTocRootKey"
#define kPagesTeacherArrayKey       @"kPagesTeacherArrayKey"
#define kPagesStudentArrayKey       @"kPagesStudentArrayKey"
#define kPathToIndexStudent         @"kPathToIndexStudent"
#define kPathToIndexTeacher         @"kPathToIndexTeacher"

@implementation EPTocConfiguration

#pragma mark - Lifecycle

- (NSString *)description {
    NSString *string = [NSString stringWithFormat:@"EPTocConfiguration:\ntocRoot: %@\npagesStudent: %@\npagesTeacher: %@", self.tocRoot, self.pagesStudentArray, self.pagesTeacherArray];
    
    return string;
}

- (void)dealloc {
    self.tocRoot = nil;
    self.pagesTeacherArray = nil;
    self.pagesStudentArray = nil;
    self.pathToIndexStudent = nil;
    self.pathToIndexTeacher = nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.tocRoot = [aDecoder decodeObjectForKey:kTocRootKey];
        self.pagesTeacherArray = [aDecoder decodeObjectForKey:kPagesTeacherArrayKey];
        self.pagesStudentArray = [aDecoder decodeObjectForKey:kPagesStudentArrayKey];
        self.pathToIndexStudent = [aDecoder decodeObjectForKey:kPathToIndexStudent];
        self.pathToIndexTeacher = [aDecoder decodeObjectForKey:kPathToIndexTeacher];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.tocRoot forKey:kTocRootKey];
    [aCoder encodeObject:self.pagesTeacherArray forKey:kPagesTeacherArrayKey];
    [aCoder encodeObject:self.pagesStudentArray forKey:kPagesStudentArrayKey];
    [aCoder encodeObject:self.pathToIndexStudent forKey:kPathToIndexStudent];
    [aCoder encodeObject:self.pathToIndexTeacher forKey:kPathToIndexTeacher];
}

@end
