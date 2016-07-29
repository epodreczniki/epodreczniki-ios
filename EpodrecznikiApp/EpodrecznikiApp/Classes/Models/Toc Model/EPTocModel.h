







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"
#import "EPTocConfiguration.h"
#import "EPAnchor.h"

@interface EPTocModel : EPConfigurableObject

@property (nonatomic, strong) EPTocConfiguration *tocConfiguration;
@property (nonatomic, readonly) NSMutableDictionary *anchorsDictionary;


- (NSInteger)pageIndexByPageItem:(EPPageItem *)pageItem inTeacherMode:(BOOL)teacherMode;
- (NSInteger)pageIndexByPageItemPath:(NSString *)path inTeacherMode:(BOOL)teacherMode;
- (NSInteger)pageIndexByPageId:(NSString *)pageId inTeacherMode:(BOOL)teacherMode;


- (EPAnchor *)anchorForPageItemPath:(NSString *)path;
- (void)setAnchor:(EPAnchor *)anchor forPageItemPath:(NSString *)path;


- (NSInteger)numberOfItemsInTeacherMode:(BOOL)teacherMode;
- (EPPageItem *)pageItemForIndex:(NSInteger)index inTeacherMode:(BOOL)teacherMode;


- (EPTocItem *)rootTocItem;
- (EPTocItem *)tocItemForIDRef:(NSString *)idRef;

@end
