







#import "EPTocUtil.h"

@implementation EPTocUtil

#pragma mark - Read Write

- (EPTocConfiguration *)readTocConfigurationForPath:(NSString *)path {
    EPTocConfiguration *toc = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    [self fixParent:toc.tocRoot inChildren:toc.tocRoot.children];
    return toc;
}

- (void)fixParent:(EPTocItem *)parent inChildren:(NSArray *)children {
    if ([NSObject isNullOrEmpty:children]) {
        return;
    }
    
    for (EPTocItem *child in children) {
        child.parent = parent;
        [self fixParent:child inChildren:child.children];
    }
}

- (void)writeTocConfiguration:(EPTocConfiguration *)tocConfiguration toPath:(NSString *)path {
    [NSKeyedArchiver archiveRootObject:tocConfiguration toFile:path];
}

#pragma mark - Parsing

- (EPTocItem *)parseTocFromFile:(NSString *)tocFile {
    
    NSData *data = [NSData dataWithContentsOfFile:tocFile];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if ([object isKindOfClass:[NSArray class]]) {
        @try {
            NSMutableArray *treeItemArray = [NSMutableArray new];
            EPTocItem *root = [EPTocItem new];
            root.itemID = @"root";
            root.title = root.itemID;
            root.root = YES;
            
            for (NSDictionary *node in object) {
                
                EPTocItem *item = [self parseTreeNode:node];
                if (item) {
                    item.parent = root;
                    [treeItemArray addObject:item];
                }
            }
            
            if (treeItemArray.count > 0) {
                
                root.children = [NSArray arrayWithArray:treeItemArray];
                return root;
            }
        }
        @catch (NSException *exception) {

        }
    }
    
    return nil;
}

- (EPTocItem *)parseTreeNode:(NSDictionary *)object {
    if ([NSObject isNullOrEmpty:object]) {
        return nil;
    }
    
    EPTocItem *item = [EPTocItem new];
    item.itemID = [self stringOrEmpty:object forKey:@"id"];
    item.title = [self stringOrEmpty:object forKey:@"title"];
    item.pathRef = [self stringOrEmpty:object forKey:@"pathRef"];
    item.numbering = [self stringOrEmpty:object forKey:@"numbering"];
    item.teacher = [object[@"isTeacher"] boolValue];
    item.contentStatus = [self arrayOfStrings:object forKey:@"contentStatus"];
    item.children = [self arrayOfChildren:object forKey:@"children" andParent:item];
    
    return item;
}

- (NSString *)stringOrEmpty:(NSDictionary *)dictionary forKey:(NSString *)key {
    id value = dictionary[key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    
    return @"";
}

- (NSArray *)arrayOfStrings:(NSDictionary *)object forKey:(NSString *)key {
    
    id array = object[key];
    
    if ([array isKindOfClass:[NSArray class]]) {
        
        for (id item in array) {
            if (![item isKindOfClass:[NSString class]]) {
                return nil;
            }
        }
        
        return array;
    }
    
    return nil;
}

- (NSArray *)arrayOfChildren:(NSDictionary *)object forKey:(NSString *)key andParent:(EPTocItem *)parent {
    
    id children = object[key];
    if ([children isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *itemChildren = [NSMutableArray new];
        for (NSDictionary *child in children) {
            
            EPTocItem *childItemNode = [self parseTreeNode:child];
            if (childItemNode) {
                childItemNode.parent = parent;
                [itemChildren addObject:childItemNode];
            }
        }
        
        return [NSArray arrayWithArray:itemChildren];
    }
    
    return nil;
}

- (NSArray *)parsePagesFromFile:(NSString *)pagesFile {
    
    NSData *data = [NSData dataWithContentsOfFile:pagesFile];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if ([object isKindOfClass:[NSArray class]]) {
        @try {
            NSMutableArray *pagesArray = [NSMutableArray new];
            
            for (NSDictionary *page in object) {
                
                EPPageItem *item = [EPPageItem new];
                item.path = [self stringOrEmpty:page forKey:@"path"];
                item.itemIDRef = [self stringOrEmpty:page forKey:@"idRef"];
                item.teacher = [page[@"isTeacher"] boolValue];
                item.moduleId = [self stringOrEmpty:page forKey:@"moduleId"];
                item.pageId = [self stringOrEmpty:page forKey:@"pageId"];
                
                [pagesArray addObject:item];
            }
            
            return [NSArray arrayWithArray:pagesArray];
        }
        @catch (NSException *exception) {

        }
    }
    
    return nil;
}

- (NSArray *)studentArrayFromTeacherArray:(NSArray *)teacherArray {
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:teacherArray];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    
    for (int i = 0; i < mutableArray.count; i++) {
        
        EPTocItem *item = mutableArray[i];
        if (item.isTeacher) {
            [indexSet addIndex:i];
        }
    }

    [mutableArray removeObjectsAtIndexes:indexSet];
    
    return [NSArray arrayWithArray:mutableArray];
}

#pragma mark - Load toc into model

- (void)loadTocForTextbookRootID:(NSString *)textbookRootID {
    if ([NSObject isNullOrEmpty:textbookRootID]) {
        return;
    }
    
#if MODE_DEVELOPER
    NSString *navigationPath = [self.configuration.pathModel pathForNavigationWithTextbookPath:[UIApplication sharedApplication].documentsDirectory];
#else
    NSString *textbookPath = [self.configuration.pathModel pathForInstalledTextbookWithTextbookRootID:textbookRootID];
    NSString *navigationPath = [self.configuration.pathModel pathForNavigationWithTextbookPath:textbookPath];
#endif
    
    self.configuration.tocModel.tocConfiguration = [self readTocConfigurationForPath:navigationPath];

    if (!self.configuration.tocModel.tocConfiguration) {

    }
}

- (void)unloadToc {
    self.configuration.tocModel.tocConfiguration = nil;
    [self.configuration.tocModel.anchorsDictionary removeAllObjects];
}

#pragma mark - Other

- (NSArray *)colorsForTocItem:(EPTocItem *)tocItem andTeacher:(BOOL)teacherMode {
    if (!tocItem) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray new];
    EPTocItemColorType lastColor = EPTocItemColorTypeNone;
    EPTocItemColorType newColor = EPTocItemColorTypeNone;
    
    NSMutableArray *items = [NSMutableArray new];
    if (tocItem) {
        [items addObject:tocItem];
    }
    if (tocItem.children) {
        [items addObjectsFromArray:tocItem.children];
    }
    
    for (EPTocItem *item in items) {
        UIColor *color = nil;
        newColor = [self colorTypeForTocItem:item withLastColor:lastColor andTeacher:teacherMode];
        
        if (newColor == lastColor) {
            color = [self colorForItemColorType:EPTocItemColorTypeNone];
        }
        else {
            lastColor = newColor;
            color = [self colorForItemColorType:newColor];
        }
        
        [self colorForItemColorType:lastColor];
        [result addObject:color];
    }
    
    return [NSArray arrayWithArray:result];
}

- (EPTocItemColorType)colorTypeForTocItem:(EPTocItem *)tocItem withLastColor:(EPTocItemColorType)lastColor andTeacher:(BOOL)teacherMode {
    if (tocItem && !tocItem.isRoot) {

        if (teacherMode) {
            lastColor = [self nextColorForLastColor:lastColor];
        }

        else {
            
            if (tocItem.isTeacher) {

            }
            else {
                lastColor = [self nextColorForLastColor:lastColor];
            }
        }
    }
    
    return lastColor;
}

- (EPTocItemColorType)nextColorForLastColor:(EPTocItemColorType)lastColor {
    if (lastColor == EPTocItemColorTypeNone) {
        return EPTocItemColorTypeDark;
    }
    if (lastColor == EPTocItemColorTypeDark) {
        return EPTocItemColorTypeLight;
    }
    if (lastColor == EPTocItemColorTypeLight) {
        return EPTocItemColorTypeDark;
    }
    return EPTocItemColorTypeNone;
}

- (UIColor *)colorForItemColorType:(EPTocItemColorType)colorType {
    
    if (colorType == EPTocItemColorTypeDark) {
        return [[UIColor lightGrayColor] colorWithAlphaComponent:0.15f];
    }
    else if (colorType == EPTocItemColorTypeLight) {
        return [UIColor whiteColor];
    }
    
    return [UIColor redColor];
}

- (NSDictionary *)createIndexDictionaryFromArray:(NSArray *)array {
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    for (int i = 0; i < array.count; i++) {
        EPPageItem *item = array[i];
        if (item && item.path) {
            result[item.path] = @(i);
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

@end
