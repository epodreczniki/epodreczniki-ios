







#import "EPTocItem.h"

#define kItemIDKey              @"kItemIDKey"
#define kTitleKey               @"kTitleKey"
#define kTeacherKey             @"kTeacherKey"
#define kPathRefKey             @"kPathRefKey"
#define kNumberingKey           @"kNumberingKey"
#define kContentStatusKey       @"kContentStatusKey"

#define kChildrenKey            @"kChildrenKey"
#define kParentKey              @"kParentKey"
#define kIsRootKey              @"kIsRootKey"

@implementation EPTocItem

#pragma mark - Lifecycle

- (void)dealloc {

    
    self.itemID = nil;
    self.title = nil;
    self.pathRef = nil;
    self.numbering = nil;
    self.contentStatus = nil;
    
    self.parent = nil;
    self.children = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"EPTocItem (%@, %d, %@, sub: %d, parent: %@)", self.itemID, self.isTeacher, self.title, (int)[self.children count], self.parent ? self.parent.title : @"nil"];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.itemID = [aDecoder decodeObjectForKey:kItemIDKey];
        self.title = [aDecoder decodeObjectForKey:kTitleKey];
        self.teacher = [aDecoder decodeBoolForKey:kTeacherKey];
        self.pathRef = [aDecoder decodeObjectForKey:kPathRefKey];
        self.numbering = [aDecoder decodeObjectForKey:kNumberingKey];
        self.contentStatus = [aDecoder decodeObjectForKey:kContentStatusKey];
        
        self.children = [aDecoder decodeObjectForKey:kChildrenKey];

        self.root = [aDecoder decodeBoolForKey:kIsRootKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.itemID forKey:kItemIDKey];
    [aCoder encodeObject:self.title forKey:kTitleKey];
    [aCoder encodeBool:self.isTeacher forKey:kTeacherKey];
    [aCoder encodeObject:self.pathRef forKey:kPathRefKey];
    [aCoder encodeObject:self.numbering forKey:kNumberingKey];
    [aCoder encodeObject:self.contentStatus forKey:kContentStatusKey];
    
    [aCoder encodeObject:self.children forKey:kChildrenKey];

    [aCoder encodeBool:self.isRoot forKey:kIsRootKey];
}

#pragma mark - Punlic properties

- (NSString *)displayTitle {
    
    if (self.numbering.length == 0) {
        return self.title;
    }
    
    return [NSString stringWithFormat:@"%@ %@", self.numbering, self.title];
}

- (BOOL)showsLeftArrow {
    return self.parent != nil;
}

- (BOOL)showsRightArrow {
    return [self.children count] > 0;
}

#pragma mark - Public methods

- (BOOL)hierarchyContains:(EPTocItem *)item {
    EPTocItem *tmp = self.parent;
    while (tmp) {
        
        if (tmp == item) {
            return YES;
        }
        tmp = tmp.parent;
    }
    
    return NO;
}

@end

@implementation EPTocItemSearchResult

- (void)dealloc {
    self.item = nil;
    self.itemParent = nil;
}

@end
