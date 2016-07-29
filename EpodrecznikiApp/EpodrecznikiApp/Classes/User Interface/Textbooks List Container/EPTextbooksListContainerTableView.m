







#import "EPTextbooksListContainerTableView.h"
#import "EPTextbookTableViewCell.h"

@implementation EPTextbooksListContainerTableView

#pragma mark - Lifecycle

- (void)awakeFromNib {

    [self.tableView registerNib:[UINib nibWithNibName:@"EPTextbookTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"tableViewCell"];
    self.tableView.separatorColor = [UIColor whiteColor];

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.tableView.preservesSuperviewLayoutMargins = NO;
    }
}

#pragma mark - Public properties

- (EPSettingsTextbooksListContainerType)containerType {
    return EPSettingsTextbooksListContainerTypeTable;
}

#pragma mark - Public methods

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)reloadCellAtIndex:(int)index {

    EPCollection *oldCollection = [self collectionForIndex:index];

    EPDownloadTextbookProxy *proxy = [self proxyForRootID:oldCollection.rootID];

    if (![oldCollection.contentID isEqualToString:proxy.storeCollection.actualContentID]) {

        [self reloadDataSourceItemAtIndex:index withContentID:proxy.storeCollection.actualContentID];

        EPCollection *newCollection = [self collectionForIndex:index];

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        EPTextbookTableViewCell *cell = (EPTextbookTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

        cell.titleLabel.text = newCollection.textbookTitle;
        cell.authorLabel.text = newCollection.textbookSubtitle;
        [cell setNeedsLayout];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsForCotainer:)]) {
        int count = [self.dataSource numberOfItemsForCotainer:self];
        
        if (count == 0) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        else {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        
        return count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    EPCollection *collection = [self collectionForIndex:(int)indexPath.row];

    EPTextbookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (collection) {
        cell.titleLabel.text = collection.textbookTitle;
        cell.authorLabel.text = collection.textbookSubtitle;
        cell.delegate = self;
        cell.tag = indexPath.row;
    }

    if (collection) {
        cell.proxy = [self proxyForRootID:collection.rootID];
        [cell prepareView];
    }

    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    EPCollection *collection = [self collectionForIndex:(int)indexPath.row];
    EPDownloadTextbookProxy *proxy = [self proxyForRootID:collection.rootID];
    EPTextbookStateType state = proxy.storeCollection.state;

    if (state == EPTextbookStateTypeNormal || state == EPTextbookStateTypeToUpdate) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(container:didSelectReadButtonAtIndex:)]) {
            [self.delegate container:self didSelectReadButtonAtIndex:(int)indexPath.row];
        }
    }
    else {
        
        EPTextbookTableViewCell *cell = (EPTextbookTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell detailsButtonAction:nil];
    }
}

@end
