







#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EPNotesModel.h"
#import "EPNote.h"

@class EPWebViewJavascriptProxy;

@protocol EPWebViewJavascriptProxyProtocol <JSExport>

- (void)openExternalLink:(NSString *)urlString;
- (void)openExternalWindow:(NSString *)urlString :(BOOL)showOverlay;
- (BOOL)isTeacher;
- (BOOL)canPlayVideo:(NSString *)url :(NSString *)container;
- (void)openPageLink:(NSString *)file :(id)anchor;
- (void)notifyModalWindowVisible;
- (void)notifyModalWindowHidden;
- (void)notifyEverythingWillBeLoaded;
- (void)notifyEverythingWasLoaded;
- (void)notifyFontButtonsEnabled:(BOOL)dec :(BOOL)inc;
- (void)getStateForWomi:(NSString *)womiID;
- (void)setStateForWomi:(NSString *)womiID :(NSString *)jsonString;

- (void)getStateForOpenQuestions:(NSString *)idsArray;
- (void)setStateForOpenQuestion:(NSString *)openQuestionID :(NSString *)base64str;


- (void)notifyButtonsState:(BOOL)b0 :(BOOL)b1 :(BOOL)b2 :(BOOL)b3 :(BOOL)b4;
- (void)notifyButtonsStateHide;


- (void) showNoteCreate:(NSString *)noteText :(NSString *)noteLocation :(NSString *)notesToMerge;
- (void) showMessage:(NSString*)message;
- (void) handleNoteClick:(NSString*)noteId;
- (void) getNoteByLocalNoteId:(NSString*)noteId;
- (NSString*) getNotesForCurrentView;

@end

@interface EPWebViewJavascriptProxy : NSObject

+ (void)configureProxyForObject:(id <EPWebViewJavascriptProxyProtocol>)object andWebView:(UIWebView *)webView;
+ (void)freeObjectForWebView:(UIWebView *)webView;


+ (void)hideHTMLNavigationBarInWebView:(UIWebView *)webView;
+ (void)clickNavigationButton:(int)num inWebView:(UIWebView *)webView;


+ (void)openExternalLink:(NSString *)urlString;
+ (BOOL)isTeacher;
+ (BOOL)canPlayVideo:(NSString *)url container:(NSString *)container inWebView:(UIWebView *)webView;
+ (void)jumpToAnchor:(NSString *)anchor inWebView:(UIWebView *)webView;
+ (void)jumpToNote:(NSString *)anchor inWebView:(UIWebView *)webView;
+ (void)decreaseFontSizeInWebView:(UIWebView *)webView;
+ (void)increaseFontSizeInWebView:(UIWebView *)webView;
+ (void)updateSizeInWebView:(UIWebView *)webView;
+ (void)closeWindowInWebView:(UIWebView *)webView;
+ (void)playVideoForContainer:(NSString *)container inWebView:(UIWebView *)webView;
+ (void)stopVideoPlaybackInWebView:(UIWebView *)webView;
+ (void)updateWomiState:(NSString *)state inWebView:(UIWebView *)webView;
+ (void)updateOpenQuestionsStates:(NSString *)base64str inWebView:(UIWebView *)webView;


+ (void) startAddNote:(UIWebView *)webView;
+ (NSString*)getSelectedText:(UIWebView *)webView;
+ (void) noteCreateCallback:(UIWebView *)webView noteAsJson:(NSString*)note notesToMarge:(NSString*)notesToMarge;
+ (void) noteEditCallback:(UIWebView *)webView noteAsJson:(NSString*)note;
+ (void) noteDeleteCallback:(UIWebView *)webView noteId:(NSString*)localNoteId ;
+ (void) showNotes:(UIWebView *)webView notesListAsJson:(NSString*)notes;

@end
