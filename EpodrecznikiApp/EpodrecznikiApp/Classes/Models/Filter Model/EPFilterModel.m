







#import "EPFilterModel.h"

@interface EPFilterModel ()

@property (nonatomic, strong) NSMutableArray *schools;
@property (nonatomic, strong) NSMutableArray *subjects;

@end

@implementation EPFilterModel

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        self.schools = [NSMutableArray new];
        self.subjects = [NSMutableArray new];
        
        NSData *schoolData = [NSData dataWithContentsOfFile:[aConfiguration.pathModel pathForLocalSchoolsFile]];
        NSArray *jsonSchools = [NSJSONSerialization JSONObjectWithData:schoolData options:NSJSONReadingAllowFragments error:nil];
        for (NSArray *item in jsonSchools) {
            EPSchool *school = [EPSchool new];
            school.schoolEducationLevel = item[0];
            school.schoolClassLevel = item[1];
            school.schoolName = item[2];
            school.className = item[3];
            [self.schools addObject:school];
        }
        
        NSData *subjectsData = [NSData dataWithContentsOfFile:[aConfiguration.pathModel pathForLocalSubjectsFile]];
        NSArray *jsonSubjects = [NSJSONSerialization JSONObjectWithData:subjectsData options:NSJSONReadingAllowFragments error:nil];
        for (NSArray *item in jsonSubjects) {
            EPSubject *subject = [EPSubject new];
            subject.subjectID = item[0];
            subject.subjectName = item[1];
            [self.subjects addObject:subject];
        }
    }
    return self;
}

- (void)dealloc {
    self.schools = nil;
    self.subjects = nil;
}

#pragma mark - Public methods

- (NSArray *)arrayOfSchools {
    return [NSArray arrayWithArray:self.schools];
}

- (NSArray *)arrayOfSubjects {
    return [NSArray arrayWithArray:self.subjects];
}

@end
