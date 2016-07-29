







#import "EPFilterUtil.h"

@implementation EPFilterUtil

- (NSArray *)filterCollections:(NSArray *)collections withFilter:(EPFilter *)filter {
    
    NSMutableArray *result = [NSMutableArray new];
    
    for (EPCollection *collection in collections) {
        if ([self canPassCollection:collection usingFilter:filter]) {
            [result addObject:collection];
        }
    }
    
    return [NSArray arrayWithArray:result];
}

- (BOOL)canPassCollection:(EPCollection *)collection usingFilter:(EPFilter *)filter {
    if (filter.filterType == EPFilterTypeNotSet) {
        return YES;
    }
    else if (filter.filterType == EPFilterTypeNone) {
        return YES;
    }
    else if (filter.filterType == EPFilterTypeByEducationLevel) {
        
        EPSchoolBasic *schoolBasic = [[EPSchoolBasic alloc] initWithString:filter.filterValue];
        return [schoolBasic.schoolEducationLevel isEqualToString:collection.schoolEducationLevel] &&
                [schoolBasic.schoolClassLevel isEqualToString:collection.schoolClass];
    }
    else if (filter.filterType == EPFilterTypeBySubject) {
        return [filter.filterValue isEqualToString:collection.subjectID];
    }
    
    return NO;
}

@end
