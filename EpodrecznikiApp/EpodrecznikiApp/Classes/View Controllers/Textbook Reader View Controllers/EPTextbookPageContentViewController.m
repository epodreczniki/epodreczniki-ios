







#import "EPTextbookPageContentViewController.h"
#import "EPExternalWebviewViewController.h"
#import "EPTextbookPagerViewController.h"

@interface EPTextbookPageContentViewController ()

@property (nonatomic) BOOL isWebviewLoaded;
@property (nonatomic) BOOL isProxySet;
@property (nonatomic) BOOL notificationWasSent;
@property (nonatomic) BOOL canJumpToPageStart;
@property (nonatomic, strong) NSTimer *loadTimer;
@property (nonatomic) BOOL willAddBookmark;


@property (nonatomic) BOOL isExternalWindowVisible;

@end

@implementation EPTextbookPageContentViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView.scalesPageToFit = NO;
    self.webView.scrollView.bounces = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.isWebviewLoaded = NO;
    self.isProxySet = NO;
    self.notificationWasSent = NO;
    self.isExternalWindowVisible = NO;
    self.canJumpToPageStart = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFontSizeNotification:) name:kTextbookReaderUpdateFontSizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNoteNotification:) name:kTextbookReaderDeleteNoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNoteNotification:) name:kTextbookReaderUpdateNoteNotification object:nil];
    
    [self prepareContextMenu];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.isWebviewLoaded) {
        self.isWebviewLoaded = YES;
        [self loadWebView];
    }

    else if (self.isExternalWindowVisible) {
        self.isExternalWindowVisible = NO;
    }

    else if (self.canJumpToPageStart) {
        [self.webView.scrollView setContentOffset:CGPointZero animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookReaderClearWebviewPointerNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearWebviewPointerNotification:) name:kTextbookReaderClearWebviewPointerNotification object:nil];

    [self setupProxy];

    if (self.notificationWasSent) {
        [self delegatePageReadyState:YES force:YES];
    }

    self.canJumpToPageStart = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    EPTextbookPagerViewController *pager = (EPTextbookPagerViewController *)[self.navigationController topViewController];
    UIViewController *presented = [pager presentedViewController];
    if (presented && [presented isKindOfClass:[UINavigationController class]]) {
        UIViewController *top = [(UINavigationController *)presented topViewController];
        if ([top isKindOfClass:[EPExternalWebviewViewController class]]) {
            self.isExternalWindowVisible = YES;
        }
    }

    [self unsetupProxy];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookReaderClearWebviewPointerNotification object:nil];

    self.canJumpToPageStart = YES;


    if (![NSStringFromClass([presented class]) isEqualToString:@"MPInlineVideoFullscreenViewController"]) {

        [EPWebViewJavascriptProxy stopVideoPlaybackInWebView:self.webView];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.webView removeFromSuperview];
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.webView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.textbookRootID = nil;
    self.pageItem = nil;
    self.delegate = nil;
    [self.loadTimer invalidate];
    self.loadTimer = nil;

}

#pragma mark - Private methods

- (void)loadWebView {
    
    self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:kMaxLoadTimeForTextbookPage target:self selector:@selector(loadTimerTick) userInfo:nil repeats:NO];
    [self.indicator startAnimating];
    
    EPPathModel *pathModel = [EPConfiguration activeConfiguration].pathModel;
    NSString *fullPath = [pathModel pathInContentForFile:self.pageItem.path withTextbookRootID:self.textbookRootID];

    NSURL *url = [NSURL fileURLWithPath:fullPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];


    [self.webView loadRequest:request];
}

- (void)loadTimerTick {

    
    @synchronized (self) {
        
        if (!self.notificationWasSent) {
            self.notificationWasSent = YES;
            [self.loadTimer invalidate];
            self.loadTimer = nil;

            [self hideOverlay];
        }
    }
}

- (void)hideOverlay {
    
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{

        [UIView animateWithDuration:0.2f animations:^{
            
            weakSelf.overlay.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            
            [weakSelf.indicator stopAnimating];
            [weakSelf.indicator removeFromSuperview];
            [weakSelf.overlay removeFromSuperview];
            weakSelf.indicator = nil;
            weakSelf.overlay = nil;

            [weakSelf delegatePageReadyState:YES force:NO];
        }];
    });
}

- (void)setupProxy {
    if (!self.isProxySet) {
        [EPWebViewJavascriptProxy configureProxyForObject:self andWebView:self.webView];
        self.isProxySet = YES;
    }
}

- (void)unsetupProxy {
    if (self.isProxySet) {
        [EPWebViewJavascriptProxy freeObjectForWebView:self.webView];
        self.isProxySet = NO;
    }
}

- (void)delegatePageReadyState:(BOOL)loaded force:(BOOL)force {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:pageIsReady:force:)]) {
        [self.delegate textbookPageContent:self pageIsReady:loaded force:force];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setupProxy];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {


    [self hideOverlay];
}

#pragma mark - EPWebViewJavascriptProxyProtocol

- (void)openExternalLink:(NSString *)urlString {

    
    [EPWebViewJavascriptProxy openExternalLink:urlString];
}

- (void)openExternalWindow:(NSString *)urlString  :(BOOL)showOverlay {

    
    EPPathModel *pathModel = [EPConfiguration activeConfiguration].pathModel;
    NSString *fileToOpen = [pathModel pathForFile:urlString withTextbookRootID:self.textbookRootID];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:openExternalWindow:andShowOverlay:)]) {
        [self.delegate textbookPageContent:self openExternalWindow:fileToOpen andShowOverlay:showOverlay];
    }
}

- (BOOL)isTeacher {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(isTeacherForTextbookPageContent:)]) {
        return [self.delegate isTeacherForTextbookPageContent:self];
    }
    
    return NO;
}

- (BOOL)canPlayVideo:(NSString *)url :(NSString *)container {
    return [EPWebViewJavascriptProxy canPlayVideo:url container:container inWebView:self.webView];
}

- (void)notifyButtonsState:(BOOL)b0 :(BOOL)b1 :(BOOL)b2 :(BOOL)b3 :(BOOL)b4 {
    
}

- (void)notifyButtonsStateHide {
    
}

- (void)openPageLink:(NSString *)file :(id)anchor {

    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:openPaginaLink::)]) {
        
        NSString *anchorString = nil;
        if (![NSObject isNullOrEmpty:anchor]) {
            anchorString = anchor;
        }

        if ([self.pageItem.path isEqualToString:file] && anchorString) {
            [EPWebViewJavascriptProxy jumpToAnchor:anchorString inWebView:self.webView];
        }

        else {
            [self.delegate textbookPageContent:self openPaginaLink:file :anchorString];
        }
    }
}

- (void)notifyModalWindowVisible {

    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:setScrollState:)]) {
        [self.delegate textbookPageContent:self setScrollState:NO];
    }
}

- (void)notifyModalWindowHidden {

    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:setScrollState:)]) {
        [self.delegate textbookPageContent:self setScrollState:YES];
    }
}

- (void)notifyEverythingWillBeLoaded {
    
}

- (void)notifyEverythingWasLoaded {

    [self jumpToBookmark];

    [self loadTimerTick];
}

- (void)notifyFontButtonsEnabled:(BOOL)dec :(BOOL)inc {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:didUpdateFontDecreaseButton:)]) {
        [self.delegate textbookPageContent:self didUpdateFontDecreaseButton:dec];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:didUpdateFontIncreaseButton:)]) {
        [self.delegate textbookPageContent:self didUpdateFontIncreaseButton:inc];
    }
}

- (void)getStateForWomi:(NSString *)womiID {
    
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    NSString *womiState = [configuration.womiModel getWomiStateForWomiID:womiID andUserID:configuration.userID andRootID:self.textbookRootID];
    [EPWebViewJavascriptProxy updateWomiState:womiState inWebView:self.webView];
}

- (void)setStateForWomi:(NSString *)womiID :(NSString *)jsonString {
    
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    [configuration.womiModel setWomiState:jsonString forWomiID:womiID andUserID:configuration.userID andRootID:self.textbookRootID];
}

- (void)getStateForOpenQuestions:(NSString *)idsArray {

    
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    NSString *base64State = [configuration.womiModel getOpenQuestionStateForIds:idsArray andUserID:configuration.userID andRootID:self.textbookRootID];
    [EPWebViewJavascriptProxy updateOpenQuestionsStates:base64State inWebView:self.webView];
}

- (void)setStateForOpenQuestion:(NSString *)openQuestionID :(NSString *)base64str {


    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    [configuration.womiModel setOpenQuestionState:openQuestionID state:base64str andUserID:configuration.userID andRootID:self.textbookRootID];
}


- (NSString*)getSelectedText {
    return [EPWebViewJavascriptProxy getSelectedText:self.webView];
}

- (void) startAddNote {
    [EPWebViewJavascriptProxy startAddNote:self.webView];
}

- (void) showNoteCreate:(NSString *)noteText :(NSString *)noteLocation :(NSString *)notesToMerge {
    EPNote *noteToAdd = [[EPNote alloc ]init];
    
    if (noteText.length > 40) {
        noteText = [noteText substringToIndex:40];
        noteText = [NSString stringWithFormat: @"%@...", noteText];
    }
    noteToAdd.subject = noteText;
    noteToAdd.location = noteLocation;
    if ([notesToMerge rangeOfString:@"undefined"].location == NSNotFound) {
        noteToAdd.notesToMerge = notesToMerge;
    }
    else {
        noteToAdd.notesToMerge =  @"";        
    }

    [noteToAdd setAllIds:self.pageItem withRootID:self.textbookRootID];
    noteToAdd.isBookmarkOnly = self.willAddBookmark;
    self.isExternalWindowVisible = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:openNotesWindow:isEditing:)]) {
        [self.delegate textbookPageContent:self openNotesWindow:noteToAdd isEditing:YES];
    }
}

- (void)showMessage:(NSString *)message {

}

- (void) handleNoteClick:(NSString*)noteId {

    
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    EPNote* noteToShow = [notesModel getNoteById:noteId];
    
    self.isExternalWindowVisible = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textbookPageContent:openNotesWindow:isEditing:)]) {
        [self.delegate textbookPageContent:self openNotesWindow:noteToShow isEditing:NO];
    }
}

- (void) getNoteByLocalNoteId:(NSString*)noteId {

}

- (NSString*) getNotesForCurrentView {

    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    notesModel._notes = [notesModel getNotesForPage:self.pageItem.pageId];
    NSString* notesJson = [notesModel notesToJson:notesModel._notes];
    return notesJson;
}


#pragma mark - Notifications

- (void)clearWebviewPointerNotification:(NSNotification *)notification {

    [EPWebViewJavascriptProxy freeObjectForWebView:self.webView];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookReaderClearWebviewPointerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTextbookReaderUpdateFontSizeNotification object:nil];
}

- (void)updateFontSizeNotification:(NSNotification *)notification {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(isPageActiveForTextbookPageContent:)]) {

        if (![self.delegate isPageActiveForTextbookPageContent:self]) {
            [EPWebViewJavascriptProxy updateSizeInWebView:self.webView];
        }
    }
}

- (void)deleteNoteNotification:(NSNotification *)notification {
    EPNote* note = notification.object;
    
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    [notesModel deleteNote:note onWebView:self.webView];

}

- (void)updateNoteNotification:(NSNotification *)notification {
    EPNote* note = notification.object;
    
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    [notesModel updateNote:note onWebView:self.webView];

}


#pragma mark - Notes

- (void)prepareContextMenu {
    UIMenuItem *menuItemNote = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"EPTextbookPageContentViewController_addNoteMenuOption", nil) action:@selector(addNote)];
    UIMenuItem *menuItemBookmark = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"EPTextbookPageContentViewController_addBookmarkMenuOption", nil) action:@selector(addBookmark)];

    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:menuItemNote, menuItemBookmark, nil]];
}

- (void)addNote {
    self.willAddBookmark = NO;
    [self startAddNote];
}


- (void)addBookmark {
    self.willAddBookmark = YES;
    [self startAddNote];
}

#pragma mark - Public methods

- (void)jumpToBookmark {

    EPTocModel *tocModel = [EPConfiguration activeConfiguration].tocModel;
    EPAnchor *anchorObject = [tocModel anchorForPageItemPath:self.pageItem.path];
    if (anchorObject) {

        if (anchorObject.isNote) {
            [EPWebViewJavascriptProxy jumpToNote:anchorObject.anchorValue inWebView:self.webView];
        }

        else {
            [EPWebViewJavascriptProxy jumpToAnchor:anchorObject.anchorValue inWebView:self.webView];
        }

        [tocModel setAnchor:nil forPageItemPath:self.pageItem.path];
    }
}

@end
