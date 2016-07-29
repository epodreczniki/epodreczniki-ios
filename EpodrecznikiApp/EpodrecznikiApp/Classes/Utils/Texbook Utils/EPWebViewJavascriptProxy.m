







#import "EPWebViewJavascriptProxy.h"

@implementation EPWebViewJavascriptProxy : NSObject

+ (void)configureProxyForObject:(id <EPWebViewJavascriptProxyProtocol>)object andWebView:(UIWebView *)webView {
    if (object == nil || webView == nil) {
        return;
    }

    @try {
        JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        if (context) {
            context[@"iosProxy"] = object;
        }
    }
    @catch (NSException *exception) {

    }
}

+ (void)freeObjectForWebView:(UIWebView *)webView {
    
    @try {
        JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        if (context) {
            context[@"iosProxy"] = nil;
        }
    }
    @catch (NSException *exception) {

    }
}

#pragma mark - Old reader methods

+ (void)hideHTMLNavigationBarInWebView:(UIWebView *)webView {

    @try {
        NSString *script = @"(function(){try{document.getElementsByClassName('permanent-navigation')[0].style.display='none';}catch(e){}})()";
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)clickNavigationButton:(int)num inWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = [NSString stringWithFormat:@"clickNavigationButton(%d)", num];
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

#pragma mark - Common

+ (void)openExternalLink:(NSString *)urlString {

    
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

+ (BOOL)isTeacher {
    
    EPUser *user = [EPConfiguration activeConfiguration].user;
    BOOL value = user.state.isTeacher;

    
    return value;
}

+ (BOOL)canPlayVideo:(NSString *)url container:(NSString *)container inWebView:(UIWebView *)webView {
    
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];

    EPNetworkUtil *networkUtil = configuration.networkUtil;
    if (!networkUtil.isNetworkReachableAndAllowed) {
        [configuration.windowsUtil showNoInternetWindow];
        
        return NO;
    }

    return YES;
}

+ (void)jumpToAnchor:(NSString *)anchor inWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = [NSString stringWithFormat:@"jumpToAnchor(\"%@\")", anchor];
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)jumpToNote:(NSString *)anchor inWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = [NSString stringWithFormat:@"jumpToNote(\"%@\")", anchor];
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)decreaseFontSizeInWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = @"decreaseSize()";
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)increaseFontSizeInWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = @"increaseSize()";
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)updateSizeInWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = @"updateSize()";
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)closeWindowInWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = @"closeWindow()";
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)playVideoForContainer:(NSString *)container inWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = [NSString stringWithFormat:@"$('%@').jPlayer('play')", container];
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)stopVideoPlaybackInWebView:(UIWebView *)webView {
    
    @try {
        NSString *script = @"stopPlayback()";
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void)updateWomiState:(NSString *)state inWebView:(UIWebView *)webView {    
    @try {
        NSString *script = [NSString stringWithFormat:@"updateWomiState('%@')", state];
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void) updateOpenQuestionsStates:(NSString *)base64str inWebView:(UIWebView *)webView {
    @try {
        NSString *script = [NSString stringWithFormat:@"updateOpenQuestionsStates('%@')", base64str];
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

#pragma mark - Notes

+ (void) startAddNote:(UIWebView *)webView {
    @try {
        NSString *script = @"startAddNote(true)";
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (NSString*)getSelectedText:(UIWebView *)webView {
    NSString* result = @"";
    @try {
        NSString *script = @"getSelectedText()";
        result =
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
    return result;
}

+ (void) noteCreateCallback:(UIWebView *)webView noteAsJson:(NSString*)note notesToMarge:(NSString*)notesToMarge {
    @try {
        NSString *script = [NSString stringWithFormat:@"noteCreateCallback('%@', '%@' )", note, notesToMarge];
        [webView stringByEvaluatingJavaScriptFromString:script];        
    }
    @catch (NSException *exception) {

    }
}

+ (void) noteEditCallback:(UIWebView *)webView noteAsJson:(NSString*)note {
    @try {

        NSString *script = [NSString stringWithFormat:@"noteEditCallback('%@')", note];
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void) noteDeleteCallback:(UIWebView *)webView noteId:(NSString*)localNoteId {
    @try {

        NSString *script = [NSString stringWithFormat:@"noteDeleteCallback('%@')", localNoteId];
        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}

+ (void) showNotes:(UIWebView *)webView notesListAsJson:(NSString*)notes {
    @try {

        NSString *script = [NSString stringWithFormat:@"showNotes('%@')", notes];


        [webView stringByEvaluatingJavaScriptFromString:script];
    }
    @catch (NSException *exception) {

    }
}



@end
