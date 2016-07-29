







#import <UIKit/UIKit.h>

@protocol EPTextbooksListContainerDataSource;
@protocol EPTextbooksListContainerDelegate;

@protocol EPTextbooksListContainerCellDelegate <NSObject>

- (void)view:(UIView *)view didSelectDownloadButtonAtIndex:(int)index;
- (void)view:(UIView *)view didSelectUpdateButtonAtIndex:(int)index;
- (void)view:(UIView *)view didSelectDeleteButtonAtIndex:(int)index;
- (void)view:(UIView *)view didSelectCancelButtonAtIndex:(int)index;
- (void)view:(UIView *)view didSelectReadButtonAtIndex:(int)index;
- (void)view:(UIView *)view didSelectDetailsButtonAtIndex:(int)index;
- (void)view:(UIView *)view didRaiseError:(NSError *)error atIndex:(int)index;
- (void)view:(UIView *)view shouldReloadCellAtIndex:(int)index;

@end

@interface EPTextbooksListContainer : UIView <EPTextbooksListContainerCellDelegate>

@property (weak, nonatomic) id <EPTextbooksListContainerDataSource> dataSource;
@property (weak, nonatomic) id <EPTextbooksListContainerDelegate> delegate;
@property (nonatomic, readonly) EPSettingsTextbooksListContainerType containerType;
@property (nonatomic, readonly) NSInteger selectedItemIndex;


- (void)reloadData;
- (void)reloadCellAtIndex:(int)index;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void)didRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;


- (EPCollection *)collectionForIndex:(int)index;
- (EPDownloadTextbookProxy *)proxyForRootID:(NSString *)rootID;
- (void)reloadDataSourceItemAtIndex:(int)index withContentID:(NSString *)contentID;

@end

@protocol EPTextbooksListContainerDataSource <NSObject>

- (int)numberOfItemsForCotainer:(EPTextbooksListContainer *)container;
- (EPCollection *)itemforIndex:(int)index;
- (void)reloadItemAtIndex:(int)index withContentID:(NSString *)contentID;

@end

@protocol EPTextbooksListContainerDelegate <NSObject>

- (void)container:(EPTextbooksListContainer *)container didSelectDownloadButtonAtIndex:(int)index;
- (void)container:(EPTextbooksListContainer *)container didSelectUpdateButtonAtIndex:(int)index;
- (void)container:(EPTextbooksListContainer *)container didSelectDeleteButtonAtIndex:(int)index;
- (void)container:(EPTextbooksListContainer *)container didSelectCancelButtonAtIndex:(int)index;
- (void)container:(EPTextbooksListContainer *)container didSelectReadButtonAtIndex:(int)index;
- (void)container:(EPTextbooksListContainer *)container didSelectDetailsButtonAtIndex:(int)index;
- (void)container:(EPTextbooksListContainer *)container didRaiseError:(NSError *)error atIndex:(int)index;

@end

@protocol EPTextbooksListContainerCell <NSObject>

@end
