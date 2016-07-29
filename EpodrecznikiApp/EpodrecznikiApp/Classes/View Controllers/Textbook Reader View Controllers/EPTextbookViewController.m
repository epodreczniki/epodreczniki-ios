







#import "EPTextbookViewController.h"
#import "EPProgressHUD.h"
#import "EPBackButtonItem.h"

@interface EPTextbookViewController () {
    NSNumber *_isTeacher;
}

@end

@implementation EPTextbookViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

#if MODE_DEVELOPER
    self.navigationItem.title = @"Test";
    self.textbookRootID = @"123";
#else
    EPCollection *collection = [[EPConfiguration activeConfiguration].textbookUtil collectionForRootID:self.textbookRootID];
    self.navigationItem.title = collection.textbookTitle;
#endif
    self.webView.scalesPageToFit = NO;

    self.buttonFontMinus.enabled = NO;
    self.buttonFontPlus.enabled = NO;
    self.buttonList.enabled = NO;
    self.buttonArrowLeft.enabled = NO;
    self.buttonArrowRight.enabled = NO;
    self.buttonExit.title = NSLocalizedString(@"EPTextbookViewController_exitButtonTitle", nil);
    [self.navigationController setToolbarHidden:YES animated:NO];

    self.buttonFontMinus.accessibilityLabel = NSLocalizedString(@"Accessability_navigationFontMinus", nil);
    self.buttonFontPlus.accessibilityLabel = NSLocalizedString(@"Accessability_navigationFontPlus", nil);
    self.buttonList.accessibilityLabel = NSLocalizedString(@"Accessability_navigationList", nil);
    self.buttonArrowLeft.accessibilityLabel = NSLocalizedString(@"Accessability_navigationArrowLeft", nil);
    self.buttonArrowRight.accessibilityLabel = NSLocalizedString(@"Accessability_navigationArrowRight", nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    [self loadWebView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.webView.delegate = nil;
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];

    self.webView = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [EPWebViewJavascriptProxy freeObjectForWebView:self.webView];
}

- (void)dealloc {
    self.textbookRootID = nil;
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView removeFromSuperview];
    self.webView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Private methods

- (void)loadWebView {
    
#if MODE_DEVELOPER
    NSString *fullPath = [[UIApplication sharedApplication].documentsDirectory stringByAppendingPathComponent:@"content/index.html"];
#else
    NSString *fullPath = [[EPConfiguration activeConfiguration].textbookUtil lastViewedPathForTextbookRootID:self.textbookRootID];
#endif

    NSURL *url = [NSURL fileURLWithPath:fullPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];


    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [EPWebViewJavascriptProxy configureProxyForObject:self andWebView:self.webView];

    [[EPConfiguration activeConfiguration].textbookUtil setLastViewedPath:[self.webView.request.URL path] forTextbookRootID:self.textbookRootID];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

#pragma mark - Navigation

- (IBAction)buttonFontMinusAction:(id)sender {
    [EPWebViewJavascriptProxy clickNavigationButton:0 inWebView:self.webView];
}

- (IBAction)buttonFontPlusAction:(id)sender {
    [EPWebViewJavascriptProxy clickNavigationButton:1 inWebView:self.webView];
}

- (IBAction)buttonListAction:(id)sender {
    [EPWebViewJavascriptProxy clickNavigationButton:2 inWebView:self.webView];
}

- (IBAction)buttonArrowLeftAction:(id)sender {
    [EPWebViewJavascriptProxy clickNavigationButton:3 inWebView:self.webView];
}

- (IBAction)buttonArrowRightAction:(id)sender {
    [EPWebViewJavascriptProxy clickNavigationButton:4 inWebView:self.webView];
}

- (IBAction)buttonExitAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EPWebViewJavascriptProxyProtocol

- (void)openExternalLink:(NSString *)urlString {
    [EPWebViewJavascriptProxy openExternalLink:urlString];
}

- (void)openExternalWindow:(NSString *)urlString :(BOOL)showOverlay {
    
}

- (BOOL)isTeacher {
    @synchronized (self) {
        return [EPWebViewJavascriptProxy isTeacher];
    }
}

- (BOOL)canPlayVideo:(NSString *)url :(NSString *)container {
    return [EPWebViewJavascriptProxy canPlayVideo:url container:container inWebView:self.webView];
}

- (void)notifyButtonsState:(BOOL)b0 :(BOOL)b1 :(BOOL)b2 :(BOOL)b3 :(BOOL)b4 {
    
    [self buttonFontMinus].enabled = b0;
    [self buttonFontPlus].enabled = b1;
    [self buttonList].enabled = b2;
    [self buttonArrowLeft].enabled = b3;
    [self buttonArrowRight].enabled = b4;

    if ([self navigationController].isToolbarHidden) {
        [[self navigationController] setToolbarHidden:NO animated:YES];
    }

    [EPWebViewJavascriptProxy hideHTMLNavigationBarInWebView:self.webView];
}

- (void)notifyButtonsStateHide {
    
    [self buttonFontMinus].enabled = NO;
    [self buttonFontPlus].enabled = NO;
    [self buttonList].enabled = NO;
    [self buttonArrowLeft].enabled = NO;
    [self buttonArrowRight].enabled = NO;

    if (![self navigationController].isToolbarHidden) {
        [[self navigationController] setToolbarHidden:YES animated:YES];
    }

    [EPWebViewJavascriptProxy hideHTMLNavigationBarInWebView:self.webView];
}

- (void)openPageLink:(NSString *)file :(id)anchor {
    
}

- (void)notifyModalWindowVisible {
    
}

- (void)notifyModalWindowHidden {
    
}

- (void)notifyEverythingWillBeLoaded {
    
}

- (void)notifyEverythingWasLoaded {
    
}

- (void)notifyFontButtonsEnabled:(BOOL)aminus :(BOOL)aplus {
    
}

- (void)getStateForWomi:(NSString *)womiID {
    
}

- (void)setStateForWomi:(NSString *)womiID :(NSString *)jsonString {
    
}

- (void)getStateForOpenQuestions:(NSString *)idsArray {
    
}

- (void)setStateForOpenQuestion:(NSString *)openQuestionID :(NSString *)base64str {
    
}

- (void)showMessage:(NSString *)message {

}

- (void) showNoteCreate:(NSString *)noteText :(NSString *)noteLocation :(NSString *)notesToMerge {

}

- (void) handleNoteClick:(NSString*)noteId {

}

- (void) getNoteByLocalNoteId:(NSString*)noteId {

}

- (NSString*) getNotesForCurrentView {

    return @"";
}

@end
