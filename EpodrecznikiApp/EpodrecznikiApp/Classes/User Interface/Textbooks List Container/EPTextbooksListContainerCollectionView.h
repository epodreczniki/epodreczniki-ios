







#import <UIKit/UIKit.h>
#import "EPTextbooksListContainer.h"

@interface EPTextbooksListContainerCollectionView : EPTextbooksListContainer <UICollectionViewDataSource, UICollectionViewDelegate, EPTextbooksListContainerCellDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
