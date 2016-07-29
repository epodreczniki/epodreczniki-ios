







#import "EPTextbooksListContainerCarouselView.h"
#import "EPTextbookCarouselCellView.h"
#import "EPURL.h"

@interface EPTextbooksListContainerCarouselView ()

@property (nonatomic) BOOL pageIndicatorStopUpdating;
@property (nonatomic, readonly) UIImage *placeholderImage;

@end

@implementation EPTextbooksListContainerCarouselView

@synthesize placeholderImage = _placeholderImage;

#pragma mark - Public properties

- (EPSettingsTextbooksListContainerType)containerType {
    return EPSettingsTextbooksListContainerTypeCarousel;
}

#pragma mark - Private properties

- (UIImage *)placeholderImage {
    if (!_placeholderImage) {
        _placeholderImage = [UIImage imageNamed:@"IconPlaceholderSmall"];
    }
    return _placeholderImage;
}

#pragma mark - Public methods

- (void)reloadData {
    [self.carousel reloadData];
    [self.pageIndicator reloadData];
}

- (void)reloadCellAtIndex:(int)index {

    EPCollection *oldCollection = [self collectionForIndex:index];

    EPDownloadTextbookProxy *proxy = [self proxyForRootID:oldCollection.rootID];

    if (![oldCollection.contentID isEqualToString:proxy.storeCollection.actualContentID]) {

        [self reloadDataSourceItemAtIndex:index withContentID:proxy.storeCollection.actualContentID];

        EPCollection *newCollection = [self collectionForIndex:index];

        UIView *view = [self.carousel itemViewAtIndex:index];
        EPTextbookCarouselCellView *cell = view.subviews[0];

        cell.titleLabel.text = newCollection.textbookTitle;
        cell.authorLabel.text = newCollection.textbookSubtitle;
        [[EPConfiguration activeConfiguration].downloadUtil loadCoverForContentID:newCollection.contentID completion:^(UIImage *image, BOOL fromCache) {
            
            if (!image) {
                image = self.placeholderImage;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setCoverImage:image animated:NO];
            });
        }];
        [cell setNeedsLayout];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {

}

- (void)didRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    [self.pageIndicator reloadData];

    NSArray *items = [self.carousel visibleItemViews];
    if (![NSObject isNull:items]) {
        for (UIView *view in items) {
            
            NSArray *subviews = view.subviews;
            if (subviews.count == 0) {
                continue;
            }
            
            EPTextbookCarouselCellView *cell = subviews[0];
            [self updateLayoutForView:view andCell:cell animated:YES];
        }
    }
}

#pragma mark - Private methods

- (void)updateLayoutForView:(UIView *)view andCell:(EPTextbookCarouselCellView *)carouselCellView animated:(BOOL)animated {

    CGRect frame = CGRectZero;
    frame.size.width = self.carousel.frame.size.width;
    if ([UIApplication sharedApplication].isPortrait) {
        frame.origin.y = 20 + 44;
        frame.size.height = self.carousel.frame.size.height - frame.origin.y;
    }
    else {
        frame.origin.y += 20 + 32;
        frame.size.height = self.carousel.frame.size.height - frame.origin.y;
    }
    
    if (animated) {
        carouselCellView.animatedLayoutChange = YES;
    }

    carouselCellView.frame = frame;
    view.bounds = self.carousel.bounds;
}

#pragma mark - iCarouselDataSource

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsForCotainer:)]) {
        return [self.dataSource numberOfItemsForCotainer:self];
    }
    
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {

    EPCollection *collection = [self collectionForIndex:(int)index];

    EPTextbookCarouselCellView *carouselCellView = [EPTextbookCarouselCellView viewWithNibName:@"EPTextbookCarouselCellView"];

    if (!view) {
        view = [UIView new];
        view.autoresizesSubviews = NO;
    }
    if ([view.subviews count] > 0) {
        [view.subviews[0] removeFromSuperview];
    }
    
    [self updateLayoutForView:view andCell:carouselCellView animated:NO];
    [view addSubview:carouselCellView];

    if (collection) {
        carouselCellView.titleLabel.text = collection.textbookTitle;
        carouselCellView.authorLabel.text = collection.textbookSubtitle;
        carouselCellView.delegate = self;
        carouselCellView.tag = index;
        carouselCellView.delegate = self;
        carouselCellView.proxy = [self proxyForRootID:collection.rootID];
        [carouselCellView prepareView];
        
#if DEBUG_OBJECTS
        [carouselCellView.downloadTextbookProxy printMe];
#endif

        [[EPConfiguration activeConfiguration].downloadUtil loadCoverForContentID:collection.contentID completion:^(UIImage *image, BOOL fromCache) {
            
            if (!image) {
                image = self.placeholderImage;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                if ([carousel itemViewAtIndex:index]) {
                    [carouselCellView setCoverImage:image animated:NO];
                }
            });
        }];
    }
    
    return view;
}

#pragma mark - iCarouselDelegate

- (void)carouselDidScroll:(iCarousel *)carousel {

    if (carousel.currentItemIndex == self.pageIndicator.selecedIndex) {
        self.pageIndicatorStopUpdating = false;
    }

    if (self.pageIndicatorStopUpdating) {
        return;
    }

    if (carousel.currentItemIndex != self.pageIndicator.selecedIndex) {
        [self.pageIndicator moveIndicatorToIndex:(int)carousel.currentItemIndex];
    }
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    if ([UIApplication sharedApplication].isPortrait) {
        return [UIScreen mainScreen].portraitScreenSize.width;
    }
    else {
        return [UIScreen mainScreen].landscapeScreenSize.width;
    }
}

#pragma mark - EPPageIndicatorDataSource

- (int)numberOfItemsForPageIndicator:(EPPageIndicator *)pageIndicator {
    
    return (int)[self numberOfItemsInCarousel:self.carousel];
}

#pragma mark - EPPageIndicatorDelegate

- (void)pageIndicator:(EPPageIndicator *)pageIndicator didChangeIndex:(int)index {


    self.pageIndicatorStopUpdating = YES;

    [self.carousel scrollToItemAtIndex:index animated:NO];
}

@end
