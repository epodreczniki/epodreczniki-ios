







#import <UIKit/UIKit.h>

@interface EPNotesDrawerListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *notesListTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooserSegmentControl;
- (IBAction)segmentSelectionChanged:(id)sender;


- (IBAction)backButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (nonatomic, copy) NSString *textbookRootID;
@property (nonatomic) BOOL openedFromDetailsWindow;

@end
