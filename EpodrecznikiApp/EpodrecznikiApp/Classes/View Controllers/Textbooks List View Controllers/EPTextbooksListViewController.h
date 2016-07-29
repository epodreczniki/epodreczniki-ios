







#import <Foundation/Foundation.h>
#import "EPTextbooksListContainer.h"

@interface EPTextbooksListViewController : UIViewController <EPTextbooksListContainerDataSource, EPTextbooksListContainerDelegate, EPAccessibilityUtilDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionsButton;

- (IBAction)optionsButtonAction:(id)sender;

@end
