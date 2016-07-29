







#import "EPExternalWebviewViewController.h"

@interface EPExternalWebviewViewController ()

@property (nonatomic, strong) NSTimer *loadTimer;
@property (nonatomic) BOOL notificationWasSent;

@end

@implementation EPExternalWebviewViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView.scalesPageToFit = NO;
    self.webView.scrollView.bounces = NO;
    self.closeButton.title = NSLocalizedString(@"EPExternalWebviewViewController_closeButtonTitle", nil);
    self.closeButton.enabled = NO;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self loadWebView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.webView removeFromSuperview];
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.webView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.path = nil;
    [self.loadTimer invalidate];
    self.loadTimer = nil;

}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - UIViewControllerRotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [self.navigationController.presentingViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Private methods

- (void)loadWebView {
    
    if (self.showOverlay) {
        self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:kMaxLoadTimeForGeogebraPage target:self selector:@selector(loadTimerTick) userInfo:nil repeats:NO];
        [self.indicator startAnimating];
    }
    else {
        [self hideOverlay];
    }

    NSURL *url = [NSURL fileURLWithPath:self.path];
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
        
        [weakSelf.indicator stopAnimating];
        weakSelf.indicator.hidden = YES;
        weakSelf.overlay.hidden = YES;
        weakSelf.closeButton.enabled = YES;
    });
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [EPWebViewJavascriptProxy configureProxyForObject:self andWebView:self.webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {


    [self hideOverlay];
}

#pragma mark - Actions

- (IBAction)closeButtonAction:(id)sender {
    [EPWebViewJavascriptProxy freeObjectForWebView:self.webView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EPWebViewJavascriptProxyProtocol

- (void)openExternalLink:(NSString *)urlString {
    [EPWebViewJavascriptProxy openExternalLink:urlString];
}

- (void)openExternalWindow:(NSString *)urlString :(BOOL)showOverlay {
    
}

- (BOOL)isTeacher {
    return NO;
}

- (BOOL)canPlayVideo:(NSString *)url :(NSString *)container {
    return NO;
}

- (void)openPageLink:(NSString *)file :(id)anchor {
    
}

- (void)notifyModalWindowVisible {
    
}

- (void)notifyModalWindowHidden {
    
}

- (void)notifyEverythingWillBeLoaded {
    
    self.notificationWasSent = NO;
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf.indicator startAnimating];
        weakSelf.indicator.hidden = NO;
        weakSelf.overlay.hidden = NO;
        weakSelf.closeButton.enabled = NO;
    });
}

- (void)notifyEverythingWasLoaded {

    [self loadTimerTick];
}

- (void)notifyFontButtonsEnabled:(BOOL)dec :(BOOL)inc {
    
}

- (void)notifyButtonsState:(BOOL)b0 :(BOOL)b1 :(BOOL)b2 :(BOOL)b3 :(BOOL)b4 {
    
}

- (void)notifyButtonsStateHide {
    
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
    ;
}

@end
