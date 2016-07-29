







#import "EPPageItem.h"

#define kPathKey            @"kPathKey"
#define kItemIDRefKey       @"kItemIDRefKey"
#define kTeacherKey         @"kTeacherKey"
#define kPageIdKey          @"kPageIdKey"
#define kModuleIdKey        @"kModuleIdKey"


@implementation EPPageItem

#pragma mark - Lifecycle

- (void)dealloc {
    self.path = nil;
    self.itemIDRef = nil;
    self.moduleId = nil;
    self.pageId = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"EPPagesItem (%@, %d, %@, %@, %@)", self.itemIDRef, self.isTeacher, self.path, self.pageId, self.moduleId];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.path = [aDecoder decodeObjectForKey:kPathKey];
        self.itemIDRef = [aDecoder decodeObjectForKey:kItemIDRefKey];
        self.teacher = [aDecoder decodeBoolForKey:kTeacherKey];
        self.moduleId = [aDecoder decodeObjectForKey:kModuleIdKey];
        self.pageId = [aDecoder decodeObjectForKey:kPageIdKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.path forKey:kPathKey];
    [aCoder encodeObject:self.itemIDRef forKey:kItemIDRefKey];
    [aCoder encodeBool:self.isTeacher forKey:kTeacherKey];
    [aCoder encodeObject:self.moduleId forKey:kModuleIdKey];
    [aCoder encodeObject:self.pageId forKey:kPageIdKey];
}

#pragma mark - Public methods

- (NSString *)stringFromPageItem {
    
    NSDictionary *dictionary = @{
        kPathKey: (self.path ? self.path : @""),
        kItemIDRefKey: (self.itemIDRef ? self.itemIDRef : @""),
        kTeacherKey: @(self.isTeacher),
        kModuleIdKey: (self.moduleId ? self.moduleId : @""),
        kPageIdKey: (self.pageId ? self.pageId : @""),
    };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return json;
}

+ (EPPageItem *)pageItemFromString:(NSString *)string {
    if ([NSObject isNullOrEmpty:string]) {
        return nil;
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    if (dictionary) {
        
        EPPageItem *pageItem = [EPPageItem new];
        pageItem.path = dictionary[kPathKey];
        pageItem.itemIDRef = dictionary[kItemIDRefKey];
        pageItem.teacher = [dictionary[kTeacherKey] boolValue];
        pageItem.moduleId = dictionary[kModuleIdKey];
        pageItem.pageId = dictionary[kPageIdKey];
        
        if (!pageItem.path) {
            pageItem.path = @"";
        }
        if (!pageItem.itemIDRef) {
            pageItem.itemIDRef = @"";
        }
        if (!pageItem.moduleId) {
            pageItem.moduleId = @"";
        }
        if (!pageItem.pageId) {
            pageItem.pageId = @"";
        }
        
        return pageItem;
    }
    
    return nil;
}

@end
