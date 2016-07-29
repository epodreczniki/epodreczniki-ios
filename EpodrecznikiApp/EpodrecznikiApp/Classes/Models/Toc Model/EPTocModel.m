







#import "EPTocModel.h"

@implementation EPTocModel

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        _anchorsDictionary = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    _anchorsDictionary = nil;
}

#pragma mark - Index

- (NSInteger)pageIndexByPageItem:(EPPageItem *)pageItem inTeacherMode:(BOOL)teacherMode {
    if (!self.tocConfiguration) {
        return 0;
    }
    
    if (pageItem) {
        return [self pageIndexByPageItemPath:pageItem.path inTeacherMode:teacherMode];
    }
    
    return 0;
}

- (NSInteger)pageIndexByPageItemPath:(NSString *)path inTeacherMode:(BOOL)teacherMode {
    if (!self.tocConfiguration) {
        return 0;
    }
    
    NSInteger pageIndex = 0;
    
    if (path) {
        
        NSNumber *index = nil;
        if (teacherMode) {
            index = self.tocConfiguration.pathToIndexTeacher[path];
        }
        else {
            index = self.tocConfiguration.pathToIndexStudent[path];
        }
        
        if (index) {
            pageIndex = [index integerValue];
        }
    }
    
    return pageIndex;
}

- (NSInteger)pageIndexByPageId:(NSString *)pageId inTeacherMode:(BOOL)teacherMode {
    if (!self.tocConfiguration) {
        return 0;
    }
    
    NSInteger index = 0;
        if (teacherMode) {
            for (int i=0; i<self.tocConfiguration.pagesTeacherArray.count; i++) {
                EPPageItem* page = self.tocConfiguration.pagesTeacherArray[i];
                if ([pageId isEqualToString:page.pageId]) {
                    index = (NSInteger)i;
                    break;
                }
            }
        }
        else {
            for (int i=0; i<self.tocConfiguration.pagesStudentArray.count; i++) {
                EPPageItem* page = self.tocConfiguration.pagesStudentArray[i];
                if ([pageId isEqualToString:page.pageId]) {
                    index = (NSInteger)i;
                    break;
                }
            }
        }

    
    return index;
}

#pragma mark - Anchors

- (EPAnchor *)anchorForPageItemPath:(NSString *)path {
    if (!self.anchorsDictionary) {
        return nil;
    }
    
    if ([NSObject isNullOrEmpty:path]) {
        return nil;
    }
    
    return self.anchorsDictionary[path];
}

- (void)setAnchor:(EPAnchor *)anchor forPageItemPath:(NSString *)path {
    if (!self.anchorsDictionary) {
        return;
    }
    
    if (![NSObject isNullOrEmpty:path]) {

        if (![NSObject isNullOrEmpty:anchor]) {
            self.anchorsDictionary[path] = anchor;
        }

        else {
            [self.anchorsDictionary removeObjectForKey:path];
        }
    }
}

#pragma mark - Items

- (NSInteger)numberOfItemsInTeacherMode:(BOOL)teacherMode {
    if (!self.tocConfiguration) {
        return 0;
    }
    
    if (teacherMode) {
        return [self.tocConfiguration.pagesTeacherArray count];
    }
    else {
        return [self.tocConfiguration.pagesStudentArray count];
    }
}

- (EPPageItem *)pageItemForIndex:(NSInteger)index inTeacherMode:(BOOL)teacherMode {
    if (!self.tocConfiguration) {
        return nil;
    }
    
    if (teacherMode) {
        return self.tocConfiguration.pagesTeacherArray[index];
    }
    else {
        return self.tocConfiguration.pagesStudentArray[index];
    }
}

#pragma mark - Tree

- (EPTocItem *)rootTocItem {
    if (!self.tocConfiguration) {
        return nil;
    }
    return self.tocConfiguration.tocRoot;
}

- (EPTocItem *)tocItemForIDRef:(NSString *)idRef {
    if (!idRef && !self.tocConfiguration) {
        return nil;
    }
    
    return [self searchForIDRef:idRef withItem:self.tocConfiguration.tocRoot];
}

- (EPTocItem *)searchForIDRef:(NSString *)idRef withItem:(EPTocItem *)tocItem {
    
    for (EPTocItem *childItem in tocItem.children) {
        EPTocItem *resultItem = [self searchForIDRef:idRef withItem:childItem];
        if (resultItem) {
            return resultItem;
        }
    }
    
    if ([tocItem.itemID isEqualToString:idRef]) {
        return tocItem;
    }
    
    return nil;
}

@end
