







#import <UIKit/UIKit.h>
#import "EPWebViewJavascriptProxy.h"

@class EPTextbookPageContentViewController;

@protocol EPTextbookPageContentViewControllerDelegate <NSObject>

- (BOOL)isTeacherForTextbookPageContent:(EPTextbookPageContentViewController *)pageContent;
- (BOOL)isPageActiveForTextbookPageContent:(EPTextbookPageContentViewController *)pageContent;
- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent openPaginaLink:(NSString *)file :(id)anchor;
- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent setScrollState:(BOOL)enabled;
- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent pageIsReady:(BOOL)ready force:(BOOL)force;
- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent didUpdateFontIncreaseButton:(BOOL)state;
- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent didUpdateFontDecreaseButton:(BOOL)state;
- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent openExternalWindow:(NSString *)path andShowOverlay:(BOOL)showOverlay;
- (void)textbookPageContent:(EPTextbookPageContentViewController *)pageContent openNotesWindow:(EPNote *)note isEditing:(BOOL)isEditing;

@end

@interface EPTextbookPageContentViewController : UIViewController <UIWebViewDelegate, EPWebViewJavascriptProxyProtocol>


@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *overlay;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, weak) id <EPTextbookPageContentViewControllerDelegate> delegate;
@property (nonatomic, strong) EPPageItem *pageItem;
@property (nonatomic, copy) NSString *textbookRootID;
@property (nonatomic) NSInteger pageIndex;

- (void)jumpToBookmark;

@end
