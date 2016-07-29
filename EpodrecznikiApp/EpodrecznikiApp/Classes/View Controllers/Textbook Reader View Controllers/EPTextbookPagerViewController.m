







#import "EPTextbookPagerViewController.h"
#import "EPTextbookDrawerViewController.h"
#import "EPActionSheetHandler.h"
#import "EPExternalWebviewViewController.h"
#import "EPNoteEditTableViewController.h"
#import "EPStack.h"

@interface EPTextbookPagerViewController ()

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIToolbar *buttonsToolbar;
@property (nonatomic) BOOL isFontIncreaseEnabled;
@property (nonatomic) BOOL isFontDecreaseEnabled;
@property (nonatomic) BOOL areNavigationButtonsVisible;
@property (nonatomic, strong) EPStack *historyStack;
@property (nonatomic) BOOL isTeacherMode;
@property (nonatomic) NSInteger pagesCount;
@property (nonatomic) NSInteger lastPageIndex;
@property (nonatomic, strong) NSTimer *loadTimer;


@property (nonatomic, copy) NSString *externalWindowPath;
@property (nonatomic) BOOL externalWindowShowOverlay;


@property (nonatomic) BOOL tmpAreNavigationButtonsVisible;

@end

@implementation EPTextbookPagerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    EPCollection *collection = [[EPConfiguration activeConfiguration].textbookUtil collectionForRootID:self.textbookRootID];
    self.viewTitle = collection.textbookTitle;
    self.navigationItem.title = self.viewTitle;
    self.closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EPTextbookPagerViewController_closeButtonTitle", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonAction:)];

    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    self.isTeacherMode = configuration.user.state.isTeacher;
    self.pagesCount = [configuration.tocModel numberOfItemsInTeacherMode:self.isTeacherMode];
    self.lastPageIndex = -1;
    self.areNavigationButtonsVisible = configuration.user.state.areNavigationButtonsVisible;
    
    self.historyStack = [EPStack new];
    self.bottomToolbar.items = @[
        self.navigationLeftButton,
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        self.navigationHistoryBackButton,
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        self.navigationRightButton
    ];
    self.navigationHistoryBackButton.title = NSLocalizedString(@"EPTextbookPagerViewController_historyBackButtonTitle", nil);
    [self updateHistoryButton];

    [self initPagerController];

    [self updateToolbarState];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPageByIndexNotification:) name:kTextbookReaderLoadPageByIndexNotification object:nil];

    self.notesButton = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"IconBookmark"]
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(rightDrawerAction:)];
    
    self.navigationItem.rightBarButtonItems = @[self.optionsButton, self.notesButton];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.pageViewController.dataSource = nil;
    self.pageViewController.delegate = nil;
    [self.pageViewController.view removeFromSuperview];
    [self removeFromParentViewController];
    self.pageViewController = nil;
    self.viewTitle = nil;
    
    self.optionsButton = nil;
    self.notesButton = nil;
    self.drawerButton = nil;
    self.closeButton = nil;
    self.bottomToolbar.items = @[];
    self.bottomToolbar = nil;
    self.navigationLeftButton = nil;
    self.navigationRightButton = nil;
    self.navigationHistoryBackButton = nil;
    [self.historyStack clear];
    self.historyStack = nil;
    
    if (self.loadTimer) {
        [self.loadTimer invalidate];
        self.loadTimer = nil;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EPExternalWebviewViewControllerSegue"]) {
        EPExternalWebviewViewController *externalVC = (EPExternalWebviewViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
        externalVC.path = self.externalWindowPath;
        externalVC.showOverlay = self.externalWindowShowOverlay;
        self.externalWindowPath = nil;
    }
    else if ([segue.identifier isEqualToString:@"EPNoteSegue"]) {
        EPNoteEditTableViewController *noteVC = (EPNoteEditTableViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
        noteVC.note = self.note;
        if(self.isCreatingNewNote) {
            noteVC.editingMode  = EPNoteCreateNew_Mode;
        }
        else {
            noteVC.editingMode  = EPNoteReadOnly_Mode;
        }

        EPTextbookPageContentViewController *pageContent = [self activePageContentViewController];
        noteVC.refernceWebView = pageContent.webView;
    }
    
}

#pragma mark - UIViewControllerRotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self updateReaderSize];
}

- (void)updateReaderSize {
    
    UINavigationController *navigationController = (UINavigationController *)self.parentViewController;
    CGRect frame = navigationController.navigationBar.frame;
    CGFloat barHeight = frame.origin.y + frame.size.height;

    CGSize screenSize;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        screenSize = [UIScreen mainScreen].portraitScreenSize;
    }
    else {
        screenSize = [UIScreen mainScreen].landscapeScreenSize;
    }
    
    CGFloat bottomToolbarHeight = 0.0f;
    if (self.areNavigationButtonsVisible) {
        bottomToolbarHeight = self.bottomToolbar.frame.size.height;
    }

    CGRect pagerFrame = CGRectMake(0, barHeight, screenSize.width, screenSize.height - barHeight - bottomToolbarHeight);
    self.pageViewController.view.frame = pagerFrame;

    CGRect toolbarFrame = self.bottomToolbar.frame;
    toolbarFrame.size.width = screenSize.width;
    toolbarFrame.origin.y = pagerFrame.origin.y + pagerFrame.size.height;
    
    self.bottomToolbar.frame = toolbarFrame;
}

#pragma mark - Private properties

- (NSString *)textbookRootID {
    
    if (self.parentViewController && self.parentViewController.parentViewController && [self.parentViewController.parentViewController isKindOfClass:[EPTextbookDrawerViewController class]]) {
        return [(EPTextbookDrawerViewController *)self.parentViewController.parentViewController textbookRootID];
    }
    
    return nil;
}

#pragma mark - Actions
-(void)rightDrawerAction:(id)sender {
    
    if (self.parentViewController && self.parentViewController.parentViewController && [self.parentViewController.parentViewController isKindOfClass:[EPTextbookDrawerViewController class]]) {
        
        EPTextbookDrawerViewController *drawer = (EPTextbookDrawerViewController *)self.parentViewController.parentViewController;
        [drawer toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    }
}

- (IBAction)drawerButtonAction:(id)sender {

    
    if (self.parentViewController && self.parentViewController.parentViewController && [self.parentViewController.parentViewController isKindOfClass:[EPTextbookDrawerViewController class]]) {
        
        EPTextbookDrawerViewController *drawer = (EPTextbookDrawerViewController *)self.parentViewController.parentViewController;
        [drawer toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
}

- (IBAction)optionsButtonAction:(id)sender {

    
    self.optionsButton.enabled = NO;
    self.notesButton.enabled = NO;

    EPActionSheetHandler *asHandler = [EPActionSheetHandler new];
    asHandler.title = NSLocalizedString(@"EPTextbookPagerViewController_actionSheetOptionsTitle", nil);

    [asHandler addButtonWithTitle:NSLocalizedString(@"EPTextbookPagerViewController_textbookListButtonTitle", nil) andActionBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];

    if (self.isFontIncreaseEnabled) {
        [asHandler addButtonWithTitle:NSLocalizedString(@"EPTextbookPagerViewController_fontIncreaseButtonTitle", nil) andActionBlock:^{
            
            EPTextbookPageContentViewController *pageContent = [self activePageContentViewController];
            if (pageContent) {
                [EPWebViewJavascriptProxy increaseFontSizeInWebView:pageContent.webView];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookReaderUpdateFontSizeNotification object:nil];
            }
        }];
    }

    if (self.isFontDecreaseEnabled) {
        [asHandler addButtonWithTitle:NSLocalizedString(@"EPTextbookPagerViewController_fontDecreaseButtonTitle", nil) andActionBlock:^{
            
            EPTextbookPageContentViewController *pageContent = [self activePageContentViewController];
            if (pageContent) {
                [EPWebViewJavascriptProxy decreaseFontSizeInWebView:pageContent.webView];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookReaderUpdateFontSizeNotification object:nil];
            }
        }];
    }

    NSString *navigationButtonTitle = nil;
    if (self.areNavigationButtonsVisible) {
        navigationButtonTitle = NSLocalizedString(@"EPTextbookPagerViewController_hideButtonsTitle", nil);
    }
    else {
        navigationButtonTitle = NSLocalizedString(@"EPTextbookPagerViewController_showButtonsTitle", nil);
    }
    
    [asHandler addButtonWithTitle:navigationButtonTitle andActionBlock:^{
        
        EPUser *user = [EPConfiguration activeConfiguration].user;
        self.areNavigationButtonsVisible = !self.areNavigationButtonsVisible;
        if (self.areNavigationButtonsVisible) {
            user.state.navigationButtonsVisibilityType = EPSettingsNavigationButtonsVisibilityTypeVisible;
            [user update];
        }
        else {
            user.state.navigationButtonsVisibilityType = EPSettingsNavigationButtonsVisibilityTypeHidden;
            [user update];
        }
        
        [self updateToolbarState];
    }];

    [asHandler addDismissBlock:^{
        
        self.optionsButton.enabled = YES;
        self.notesButton.enabled = YES;
    }];

    [asHandler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbookPagerViewController_closeButtonTitle", nil) andActionBlock:nil];

    if ([UIDevice currentDevice].isIPad) {
        [asHandler showFromBarButtonItem:self.optionsButton animated:YES];
    }

    else {
        [asHandler showInView:self.view];
    }
}

- (IBAction)navigationLeftButtonAction:(id)sender {
    
    NSInteger newIndex = self.lastPageIndex - 1;
    if (newIndex >= 0) {
        [self setPagerUserInteractionState:NO];
        [self loadPageByIndex:newIndex];
    }
}

- (IBAction)navigationRightButtonAction:(id)sender {
    
    NSInteger newIndex = self.lastPageIndex + 1;
    if (newIndex < self.pagesCount) {
        [self setPagerUserInteractionState:NO];
        [self loadPageByIndex:newIndex];
    }
}

- (IBAction)historyBackButtonAction:(id)sender {
    
    if ([self.historyStack size] > 1) {
        
        [self.historyStack pop];
        NSNumber *pageIndex = [self.historyStack pop];
        
        [self setPagerUserInteractionState:NO];
        [self loadPageByIndex:[pageIndex intValue]];
    }
}

- (void)closeButtonAction:(id)sender {
    
    EPTextbookPageContentViewController *pageVC = [self activePageContentViewController];
    [EPWebViewJavascriptProxy closeWindowInWebView:pageVC.webView];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = ((EPTextbookPageContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerPageAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = ((EPTextbookPageContentViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == self.pagesCount) {
        return nil;
    }
    
    return [self viewControllerPageAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {


    [self setPagerUserInteractionState:NO];

    self.lastPageIndex = [pendingViewControllers[0] pageIndex];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {

    if (!completed) {


        self.lastPageIndex = [previousViewControllers[0] pageIndex];

        [self setPagerUserInteractionState:YES];
        
        return;
    }


    EPTextbookPageContentViewController *pageContent = (EPTextbookPageContentViewController *)pageViewController.viewControllers[0];

    [self saveLastPageItem:pageContent.pageItem andLastPageIndex:pageContent.pageIndex];
}

#pragma mark - Private methods

- (EPTextbookPageContentViewController *)viewControllerPageAtIndex:(NSInteger)index {
    
    EPTextbookPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EPTextbookPageContentViewController"];
    pageContentViewController.pageIndex = index;
    pageContentViewController.delegate = self;
    pageContentViewController.textbookRootID = self.textbookRootID;

    EPTocModel *tocModel = [EPConfiguration activeConfiguration].tocModel;
    pageContentViewController.pageItem = [tocModel pageItemForIndex:index inTeacherMode:self.isTeacherMode];

    pageContentViewController.view.frame = self.pageViewController.parentViewController.view.frame;
    
    return pageContentViewController;
}

- (EPTextbookPageContentViewController *)activePageContentViewController {
    return [self.pageViewController.viewControllers lastObject];
}

- (void)initPagerController {

    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pageViewController.view.frame = self.view.frame;
    self.pageViewController.view.autoresizingMask = UIViewAutoresizingNone;

    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    EPPageItem *pageItem = [configuration.textbookUtil lastViewedPageItemForTextbookRootID:self.textbookRootID];

    NSInteger pageIndex = [configuration.tocModel pageIndexByPageItem:pageItem inTeacherMode:self.isTeacherMode];

    [self setPagerUserInteractionState:NO];
    [self loadPageByIndex:pageIndex];

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.view sendSubviewToBack:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)loadPageByIndex:(NSInteger)pageIndex {
    
    if (pageIndex == self.lastPageIndex || pageIndex < 0 || pageIndex >= self.pagesCount) {
        
        EPTextbookPageContentViewController *pageContent = [self activePageContentViewController];
        [pageContent jumpToBookmark];
        
        return;
    }

    UIPageViewControllerNavigationDirection direction;
    if (pageIndex > self.lastPageIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    }
    else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }

    EPTextbookPageContentViewController *activeViewController = [self viewControllerPageAtIndex:pageIndex];

    [self saveLastPageItem:activeViewController.pageItem andLastPageIndex:pageIndex];

    NSArray *viewControllers = @[activeViewController];
    [self.pageViewController setViewControllers:viewControllers direction:direction animated:NO completion:nil];
}

- (void)saveLastPageItem:(EPPageItem *)pageItem andLastPageIndex:(NSInteger)pageIndex {

    [[EPConfiguration activeConfiguration].textbookUtil setLastViewedPageItem:pageItem forTextbookRootID:self.textbookRootID];

    self.lastPageIndex = pageIndex;

    [self.historyStack push:@(pageIndex)];
    [self updateHistoryButton];

    NSDictionary *dictionary = @{
        kTextbookUpdateTocLocationNotificationPageItemKey: pageItem
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookUpdateTocLocationNotification object:nil userInfo:dictionary];
}

- (void)setPagerUserInteractionState:(BOOL)state {
    
    self.pageViewController.view.userInteractionEnabled = state;
    self.navigationLeftButton.enabled = (state && self.lastPageIndex > 0);
    self.navigationRightButton.enabled = (state && (self.lastPageIndex + 1) < self.pagesCount);
    self.navigationItem.leftBarButtonItem.enabled = state;
    self.navigationItem.rightBarButtonItem.enabled = state;
    self.notesButton.enabled = state;
    
    if (!state) {
        self.navigationHistoryBackButton.enabled = state;
    }
    else {
        [self updateHistoryButton];
    }

    if (self.loadTimer) {

        
        [self.loadTimer invalidate];
        self.loadTimer = nil;
    }
    
    if (!state) {

        
        self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:kMaxLoadTimeForTextbookPage target:self selector:@selector(unlockUI) userInfo:nil repeats:NO];
    }
}

- (void)unlockUI {
    [self.loadTimer invalidate];
    self.loadTimer = nil;

    
    [self setPagerUserInteractionState:YES];
}

- (void)updateToolbarState {

    [self updateReaderSize];
}

- (void)updateHistoryButton {
    
    if (self.pageViewController.view.userInteractionEnabled) {
        self.navigationHistoryBackButton.enabled = ([self.historyStack size] > 1);
    }
}

#pragma mark - EPTextbookPageContentViewControllerDelegate

- (BOOL)isTeacherForTextbookPageContent:(EPTextbookPageContentViewController *)pageContent {

    
    return self.isTeacherMode;
}

- (BOOL)isPageActiveForTextbookPageContent:(EPTextbookPageContentViewController *)pageContent {

    
    return pageContent.pageIndex == self.lastPageIndex;
}

- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent openPaginaLink:(NSString *)file :(id)anchor {

    
    EPTocModel *tocModel = [EPConfiguration activeConfiguration].tocModel;

    if (anchor) {
        EPAnchor *anchorObject = [EPAnchor new];
        anchorObject.isNote = NO;
        anchorObject.anchorValue = anchor;
        anchorObject.anchorPath = file;
        [tocModel setAnchor:anchorObject forPageItemPath:file];
    }

    NSInteger pageIndex = [tocModel pageIndexByPageItemPath:file inTeacherMode:self.isTeacherMode];

    [self loadPageByIndex:pageIndex];
}

- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent openExternalWindow:(NSString *)path andShowOverlay:(BOOL)showOverlay {
    
    self.externalWindowPath = path;
    self.externalWindowShowOverlay = showOverlay;
    [self performSegueWithIdentifier:@"EPExternalWebviewViewControllerSegue" sender:nil];
}

- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent openNotesWindow:(EPNote*)note isEditing:(BOOL)isEditing{
    self.note = note;
    self.isCreatingNewNote = isEditing;
    [self performSegueWithIdentifier:@"EPNoteSegue" sender:nil];
}

- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent didUpdateFontIncreaseButton:(BOOL)state {

    
    self.isFontIncreaseEnabled = state;
}

- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent didUpdateFontDecreaseButton:(BOOL)state {

    
    self.isFontDecreaseEnabled = state;
}

- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent setScrollState:(BOOL)enabled {


    self.pageViewController.scrollingEnabled = enabled;

    if (enabled) {
        self.navigationItem.leftBarButtonItem = self.drawerButton;
        self.navigationItem.rightBarButtonItems = @[self.optionsButton, self.notesButton];
        self.navigationItem.title = self.viewTitle;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = self.closeButton;
        self.navigationItem.title = nil;
    }

    if (enabled) {

        if (self.tmpAreNavigationButtonsVisible) {
            self.areNavigationButtonsVisible = self.tmpAreNavigationButtonsVisible;
            self.navigationController.toolbar.hidden = NO;
            [self updateReaderSize];
        }
    }
    else {

        if (self.areNavigationButtonsVisible) {
            self.tmpAreNavigationButtonsVisible = self.areNavigationButtonsVisible;
            self.areNavigationButtonsVisible = NO;
            self.navigationController.toolbar.hidden = YES;
            [self updateReaderSize];
        }
    }
}

- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent pageIsReady:(BOOL)ready force:(BOOL)force {

    
    if (self.lastPageIndex == pageContent.pageIndex || force) {
        
        [self setPagerUserInteractionState:ready];
    }
}





#pragma mark - Notifications

- (void)loadPageByIndexNotification:(NSNotification *)notification {

    
    NSNumber *index = notification.userInfo[kTextbookReaderLoadPageByIndexNotificationPageIndexKey];
    if (index) {

        NSInteger pageIndex = [index integerValue];

        [self loadPageByIndex:pageIndex];
    }
}

@end
