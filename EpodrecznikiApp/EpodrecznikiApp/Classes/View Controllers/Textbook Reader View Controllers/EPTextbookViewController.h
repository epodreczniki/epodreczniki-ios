







#import <UIKit/UIKit.h>
#import "EPWebViewJavascriptProxy.h"

@interface EPTextbookViewController : UIViewController <UIWebViewDelegate, EPWebViewJavascriptProxyProtocol>

@property (nonatomic, copy) NSString *textbookRootID;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonFontMinus;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonFontPlus;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonList;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonArrowLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonArrowRight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonExit;

- (IBAction)buttonFontMinusAction:(id)sender;
- (IBAction)buttonFontPlusAction:(id)sender;
- (IBAction)buttonListAction:(id)sender;
- (IBAction)buttonArrowLeftAction:(id)sender;
- (IBAction)buttonArrowRightAction:(id)sender;
- (IBAction)buttonExitAction:(id)sender;

@end
