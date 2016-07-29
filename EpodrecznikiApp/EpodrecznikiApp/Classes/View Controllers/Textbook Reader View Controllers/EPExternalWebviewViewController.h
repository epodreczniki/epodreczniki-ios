







#import <UIKit/UIKit.h>
#import "EPWebViewJavascriptProxy.h"

@interface EPExternalWebviewViewController : UIViewController <UIWebViewDelegate, EPWebViewJavascriptProxyProtocol>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *overlay;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *closeButton;

@property (nonatomic, copy) NSString *path;
@property (nonatomic) BOOL showOverlay;

- (IBAction)closeButtonAction:(id)sender;

@end
