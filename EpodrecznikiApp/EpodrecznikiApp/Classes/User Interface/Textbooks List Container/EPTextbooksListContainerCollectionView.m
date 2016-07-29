







#import "EPTextbooksListContainerCollectionView.h"
#import "EPTextbookCollectionViewCell.h"
#import "EPURL.h"

@interface EPTextbooksListContainerCollectionView ()

@property (nonatomic, strong) NSMutableArray *cellHeights;
@property (nonatomic, assign) BOOL portrait;
@property (nonatomic, readonly) UIImage *placeholderImage;

- (CGSize)sizeForItemAtIndex:(int)index;

@end

@implementation EPTextbooksListContainerCollectionView

@synthesize placeholderImage = _placeholderImage;

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [self.collectionView registerNib:[UINib nibWithNibName:@"EPTextbookCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"collectionViewCell"];

    [self didRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];

    self.cellHeights = [NSMutableArray new];
}

- (void)dealloc {
    _placeholderImage = nil;
}

#pragma mark - Public properties

- (EPSettingsTextbooksListContainerType)containerType {
    return EPSettingsTextbooksListContainerTypeCollection;
}

#pragma mark - Public methods

- (void)reloadData{
    [self.collectionView reloadData];
}

- (void)reloadCellAtIndex:(int)index {

    EPCollection *oldCollection = [self collectionForIndex:index];

    EPDownloadTextbookProxy *proxy = [self proxyForRootID:oldCollection.rootID];

    if (![oldCollection.contentID isEqualToString:proxy.storeCollection.actualContentID]) {

        [self reloadDataSourceItemAtIndex:index withContentID:proxy.storeCollection.actualContentID];

        EPCollection *newCollection = [self collectionForIndex:index];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        EPTextbookCollectionViewCell *cell = (EPTextbookCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

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

- (void)didRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(56, 56, 56, 56);
        flowLayout.minimumLineSpacing = 56;
        flowLayout.minimumInteritemSpacing = 56;
        flowLayout.itemSize = CGSizeMake(300, 600);
        
        [self.collectionView setCollectionViewLayout:flowLayout animated:YES];
    }

    else {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(31, 31, 31, 31);
        flowLayout.minimumLineSpacing = 31;
        flowLayout.minimumInteritemSpacing = 31;
        flowLayout.itemSize = CGSizeMake(300, 600);
        
        [self.collectionView setCollectionViewLayout:flowLayout animated:YES];
    }
}

#pragma mark - Private properties

- (UIImage *)placeholderImage {
    if (!_placeholderImage) {
        _placeholderImage = [UIImage imageNamed:@"IconPlaceholderSmall"];
    }
    return _placeholderImage;
}

#pragma mark - Private methods

- (CGSize)sizeForItemAtIndex:(int)index {
    if (index < 0 || index >= [self.cellHeights count]) {
        return CGSizeZero;
    }

    NSValue *sizeValue = self.cellHeights[index];
    CGSize cellSize = [sizeValue CGSizeValue];
    if (CGSizeEqualToSize(cellSize, CGSizeZero)) {

        EPCollection *collection = [self collectionForIndex:index];
        
        NSString *title = collection.textbookTitle;
        NSString *author = collection.textbookSubtitle;
        
        EPTextbookCollectionViewCell *cell = [EPTextbookCollectionViewCell viewWithNibName:@"EPTextbookCollectionViewCell"];
        cellSize = [cell sizeForCellWithTextbookTitle:title andAuthor:author];

        sizeValue = [NSValue valueWithCGSize:cellSize];
        [self.cellHeights replaceObjectAtIndex:index withObject:sizeValue];
    }
    return cellSize;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    [self.cellHeights removeAllObjects];

    self.portrait = [UIApplication sharedApplication].isPortrait;

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsForCotainer:)]) {
        NSInteger count =  [self.dataSource numberOfItemsForCotainer:self];

        for (int i = 0; i < count; i++) {
            [self.cellHeights addObject:[NSValue valueWithCGSize:CGSizeZero]];
        }
        
        return count;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    EPCollection *collection = [self collectionForIndex:(int)indexPath.row];
    
#if DEBUG_OBJECTS
    [collection printMe];
#endif

    EPTextbookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];

    if (collection) {
        cell.titleLabel.text = collection.textbookTitle;
        cell.authorLabel.text = collection.textbookSubtitle;
        cell.tag = indexPath.row;
        cell.delegate = self;
        cell.proxy = [self proxyForRootID:collection.rootID];
        [cell prepareView];
        [cell setNeedsLayout];
        
#if DEBUG_OBJECTS
        [cell.downloadTextbookProxy printMe];
#endif

        [[EPConfiguration activeConfiguration].downloadUtil loadCoverForContentID:collection.contentID completion:^(UIImage *image, BOOL fromCache) {
            
            if (!image) {
                image = self.placeholderImage;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                if ([collectionView cellForItemAtIndexPath:indexPath]) {
                    [cell setCoverImage:image animated:!fromCache];
                }
            });
        }];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize resultSize = CGSizeZero;

    if (self.portrait) {
        
        int firstIndex = (int)indexPath.row;
        int secondIndex = (firstIndex % 2 == 0) ? (firstIndex + 1) : (firstIndex - 1);
        
        CGSize firstSize = [self sizeForItemAtIndex:firstIndex];
        CGSize secondSize = [self sizeForItemAtIndex:secondIndex];
        
        resultSize.width = MAX(firstSize.width, secondSize.width);
        resultSize.height = MAX(firstSize.height, secondSize.height);
    }

    else {
        
        int firstIndex = (int)indexPath.row;
        int secondIndex = 0;
        int thirdIndex = 0;
        
        if (firstIndex % 3 == 0) {
            secondIndex = firstIndex + 1;
            thirdIndex = firstIndex + 2;
        }
        else if (firstIndex % 3 == 1) {
            secondIndex = firstIndex - 1;
            thirdIndex = firstIndex + 1;
        }
        else {
            secondIndex = firstIndex - 1;
            thirdIndex = firstIndex - 2;
        }
        
        CGSize firstSize = [self sizeForItemAtIndex:firstIndex];
        CGSize secondSize = [self sizeForItemAtIndex:secondIndex];
        CGSize thirdSize = [self sizeForItemAtIndex:thirdIndex];
        
        resultSize.width = MAX(firstSize.width, MAX(secondSize.width, thirdSize.width));
        resultSize.height = MAX(firstSize.height, MAX(secondSize.height, thirdSize.height));
    }
    
    return resultSize;
}

@end
