







#import <UIKit/UIKit.h>
#import "EPTextbookPageContentViewController.h"

@interface EPTextbookPagerViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, EPTextbookPageContentViewControllerDelegate>

@property (nonatomic, readonly) NSString *textbookRootID;
@property (nonatomic, copy) NSString *viewTitle;

@property (nonatomic) EPNote* note;
@property (nonatomic) BOOL isCreatingNewNote;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *drawerButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *optionsButton;
@property (nonatomic, strong) UIBarButtonItem *notesButton;
@property (nonatomic, strong) UIBarButtonItem *closeButton;

@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigationLeftButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigationRightButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *navigationHistoryBackButton;

- (IBAction)drawerButtonAction:(id)sender;
- (IBAction)optionsButtonAction:(id)sender;
- (IBAction)navigationLeftButtonAction:(id)sender;
- (IBAction)navigationRightButtonAction:(id)sender;
- (IBAction)historyBackButtonAction:(id)sender;
- (void)closeButtonAction:(id)sender;

@end
