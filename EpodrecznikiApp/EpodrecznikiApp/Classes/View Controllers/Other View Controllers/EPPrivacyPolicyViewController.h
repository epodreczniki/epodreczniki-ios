







#import <UIKit/UIKit.h>

@interface EPPrivacyPolicyViewController : UIViewController <UITextViewDelegate, EPAccessibilityUtilDelegate>

@property (weak, nonatomic) IBOutlet UITextView *policyTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;
@property (nonatomic) BOOL isFirstViewController;
@property (nonatomic) BOOL isPolicyAccepted;

- (IBAction)acceptButtonAction:(id)sender;

@end
