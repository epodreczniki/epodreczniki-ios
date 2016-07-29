







#import "EPTocViewController.h"
#import "MMDrawerController.h"
#import "EPTextbookDrawerViewController.h"

@interface EPTocViewController ()

@property (nonatomic) BOOL isTeacherMode;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) EPTocItem *tocRootItem;
@property (nonatomic, weak) EPTocItem *currentTocItem;

@end

@implementation EPTocViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.bounces = NO;
    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"EPTocViewController_textbookList", nil);
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"EPTocViewController_return", nil);

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.tableView.preservesSuperviewLayoutMargins = NO;
    }

    self.navigationController.navigationBar.translucent = NO;

    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    self.isTeacherMode = configuration.user.state.isTeacher;

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0,0, self.tableView.frame.size.width, 50)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.text = NSLocalizedString(@"EPTocViewController_tocTitle", nil);
    label.font = [UIFont boldSystemFontOfSize:17.0f];
    label.textAlignment = NSTextAlignmentCenter;
    
    [headerView addSubview:label];
    self.tableView.tableHeaderView = headerView;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTocPathNotification:) name:kTextbookUpdateTocLocationNotification object:nil];

    EPPageItem *pageItem = [configuration.textbookUtil lastViewedPageItemForTextbookRootID:self.textbookRootID];
    EPTocItemSearchResult *result = [self tocItemResultFromPageItem:pageItem];
    
    [self loadCurrentTocItem:result.item];
    [self loadTocItem:result.itemParent];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tocRootItem = nil;
    self.colors = nil;
    self.currentTocItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.translucent = YES;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Private properties

- (NSString *)textbookRootID {
    
    if (self.parentViewController && self.parentViewController.parentViewController && [self.parentViewController.parentViewController isKindOfClass:[EPTextbookDrawerViewController class]]) {
        return [(EPTextbookDrawerViewController *)self.parentViewController.parentViewController textbookRootID];
    }
    
    return nil;
}

#pragma mark - Actions

- (IBAction)homeButtonAction:(id)sender {
    if (self.parentViewController) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)returnButtonAction:(id)sender {
    if (self.parentViewController && self.parentViewController.parentViewController) {
        MMDrawerController *drawer = (MMDrawerController *)self.parentViewController.parentViewController;
        [drawer closeDrawerAnimated:YES completion:nil];
    }
}

#pragma mark - Private methods

- (void)loadTocItem:(EPTocItem *)tocItem {

    self.tocRootItem = tocItem;

    self.colors = [[EPConfiguration activeConfiguration].tocUtil colorsForTocItem:tocItem andTeacher:self.isTeacherMode];
}

- (void)loadCurrentTocItem:(EPTocItem *)tocItem {

    self.currentTocItem = tocItem;
}

- (EPTocItemSearchResult *)tocItemResultFromPageItem:(EPPageItem *)pageItem {
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];

    EPTocItemSearchResult *result = [EPTocItemSearchResult new];
    result.hasResult = NO;
    result.itemParent = configuration.tocModel.tocConfiguration.tocRoot;
    
    if (pageItem) {
        EPTocItem *tmpItem = [configuration.tocModel tocItemForIDRef:pageItem.itemIDRef];
        if (tmpItem) {
            result.hasResult = YES;
            if (tmpItem.parent) {
                result.item = tmpItem;
                result.itemParent = tmpItem.parent;
            }

            else {
                result.item = tmpItem;
                result.itemParent = tmpItem;
            }
        }
    }
    
    return result;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        
        if (self.tocRootItem.showsLeftArrow) {
            numberOfRows++;
        }
    }
    else if (section == 1) {
        
        numberOfRows = [self.tocRootItem.children count];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EPTocViewControllerCell *cell = nil;
    EPTocItem *currentItem = nil;

    if (indexPath.section == 0) {

        currentItem = self.tocRootItem;

        cell = [tableView dequeueReusableCellWithIdentifier:@"tocCellLeft"];
        cell.cellType = EPTocViewControllerCellLeft;
    }

    else {

        currentItem = self.tocRootItem.children[indexPath.row];

        if (currentItem.showsRightArrow) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"tocCellRight"];
            cell.cellType = EPTocViewControllerCellRight;
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"tocCellNone"];
            cell.cellType = EPTocViewControllerCellNone;
        }
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

    cell.delegate = self;
    cell.tag = indexPath.row;
    cell.tocTitleLabel.attributedText = nil;
    cell.tocTitleLabel.text = currentItem.displayTitle;
    cell.topSeparatorView.hidden = !((self.tocRootItem.showsLeftArrow && indexPath.section == 0)
                                    || (indexPath.section == 1 && indexPath.row == 0 && !self.tocRootItem.showsLeftArrow));

    NSInteger index = indexPath.section + indexPath.row;
    cell.backgroundColor = self.colors[index];

    if (!cell.backgroundView) {
        UIView *backgroundColorView = [UIView new];
        backgroundColorView.backgroundColor = [self.view.tintColor colorWithAlphaComponent:0.6f];
        [cell setSelectedBackgroundView:backgroundColorView];
    }
    
    if (self.currentTocItem) {
        BOOL showBullet = (currentItem == self.currentTocItem)
                        || (indexPath.section == 1 && currentItem.showsRightArrow && [self.currentTocItem hierarchyContains:currentItem]);
        
        if (showBullet) {
            
            NSString *text = [NSString stringWithFormat:@"• %@", cell.tocTitleLabel.text];
            
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor epBlueColor] range:NSMakeRange(0, 1)];
            [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 1)];
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(1, attrStr.length - 1)];
            
            cell.tocTitleLabel.attributedText = attrStr;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = tableView.rowHeight;
    
    if (indexPath.section == 1) {
        
        EPTocItem *currentItem = self.tocRootItem.children[indexPath.row];

        if (self.isTeacherMode) {

        }

        else {

            if (currentItem.isTeacher) {
                height = 0.0f;
            }
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EPTocItem *currentItem = nil;
    if (indexPath.section == 0) {
        currentItem = self.tocRootItem;
    }
    else if (indexPath.section == 1) {
        currentItem = self.tocRootItem.children[indexPath.row];
    }

    EPTocConfiguration *tocConfig = [EPConfiguration activeConfiguration].tocModel.tocConfiguration;
    NSNumber *pageIndex = nil;
    
    if (self.isTeacherMode) {
        pageIndex = tocConfig.pathToIndexTeacher[currentItem.pathRef];
    }
    else {
        pageIndex = tocConfig.pathToIndexStudent[currentItem.pathRef];
    }
    if (!pageIndex) {
        pageIndex = @0;
    }
    
    NSDictionary *dictionary = @{
        kTextbookReaderLoadPageByIndexNotificationPageIndexKey: pageIndex
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookReaderLoadPageByIndexNotification object:nil userInfo:dictionary];

    [self returnButtonAction:self];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

#pragma mark - EPTocViewControllerCellDelegate

- (void)tocViewControllerCell:(EPTocViewControllerCell *)cell didSelectLeftButtonForIndex:(NSInteger)index {

    if (self.tocRootItem.parent) {
        [self loadTocItem:self.tocRootItem.parent];
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)tocViewControllerCell:(EPTocViewControllerCell *)cell didSelectRightButtonForIndex:(NSInteger)index {

    if (self.tocRootItem.children[index]) {
        [self loadTocItem:self.tocRootItem.children[index]];
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - Notifications

- (void)updateTocPathNotification:(NSNotification *)notification {

    
    EPPageItem *pageItem = notification.userInfo[kTextbookUpdateTocLocationNotificationPageItemKey];
    EPTocItemSearchResult *result = [self tocItemResultFromPageItem:pageItem];

    if (!result.hasResult) {
        return;
    }

    [self loadCurrentTocItem:result.item];
    [self loadTocItem:result.itemParent];

    [self.tableView reloadData];
}

@end
