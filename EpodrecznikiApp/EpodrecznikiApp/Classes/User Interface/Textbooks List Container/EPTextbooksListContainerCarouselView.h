







#import <UIKit/UIKit.h>
#import "EPTextbooksListContainer.h"
#import "iCarousel.h"
#import "EPPageIndicator.h"

@interface EPTextbooksListContainerCarouselView : EPTextbooksListContainer <iCarouselDataSource, iCarouselDelegate, EPPageIndicatorDataSource, EPPageIndicatorDelegate>

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet EPPageIndicator *pageIndicator;

@end
