







#import <UIKit/UIKit.h>

#import "MMDrawerController.h"
#import "MMDrawerController+Subclass.h"
#import "MMDrawerController+Storyboard.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerVisualState.h"
#import "UIViewController+MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface EPTextbookDrawerViewController : MMDrawerController

@property (nonatomic, copy) NSString *textbookRootID;

@end
