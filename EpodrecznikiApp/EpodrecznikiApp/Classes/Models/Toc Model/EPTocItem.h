







#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EPTocItemColorType) {
    EPTocItemColorTypeNone,
    EPTocItemColorTypeDark,
    EPTocItemColorTypeLight
};

@interface EPTocItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, getter = isTeacher) BOOL teacher;
@property (nonatomic, copy) NSString *pathRef;
@property (nonatomic, copy) NSString *numbering;
@property (nonatomic, copy) NSArray *contentStatus;
@property (nonatomic, readonly) NSString *displayTitle;


@property (nonatomic, weak) EPTocItem *parent;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, readonly) BOOL showsLeftArrow;
@property (nonatomic, readonly) BOOL showsRightArrow;
@property (nonatomic, getter = isRoot) BOOL root;

- (BOOL)hierarchyContains:(EPTocItem *)item;

@end

@interface EPTocItemSearchResult : NSObject

@property (nonatomic) BOOL hasResult;
@property (nonatomic, weak) EPTocItem *item;
@property (nonatomic, weak) EPTocItem *itemParent;

@end
