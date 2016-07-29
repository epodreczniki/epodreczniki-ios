







#import <UIKit/UIKit.h>

@protocol EPPageIndicatorDataSource;
@protocol EPPageIndicatorDelegate;

@interface EPPageIndicator : UIView

@property (nonatomic, assign) int selecedIndex;
@property (nonatomic, readonly) int numberOfItems;
@property (nonatomic, weak) IBOutlet id <EPPageIndicatorDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <EPPageIndicatorDelegate> delegate;

- (void)reloadData;
- (void)moveIndicatorToIndex:(int)index;
- (void)moveIndicatorToIndex:(int)index animated:(BOOL)animated;

@end

@protocol EPPageIndicatorDataSource <NSObject>

- (int)numberOfItemsForPageIndicator:(EPPageIndicator *)pageIndicator;

@end

@protocol EPPageIndicatorDelegate <NSObject>

- (void)pageIndicator:(EPPageIndicator *)pageIndicator didChangeIndex:(int)index;

@end
