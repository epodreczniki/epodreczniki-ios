







#import <UIKit/UIKit.h>
#import "EPNotesModel.h"
#import "EPNote.h"
#import "EPTextbookPagerViewController.h"

typedef NS_ENUM(NSInteger, EPNoteEditMode) {
    EPNoteReadOnly_Mode                = 0,
    EPNoteCreateNew_Mode                 = 1,
    EPNoteEditExisting_Mode                   = 2
    
};

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface EPNoteEditTableViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cacelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;


@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentColorPicker;


- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)editButtonAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;


@property (nonatomic, assign) EPNote* note;

@property EPNoteEditMode editingMode;
@property (nonatomic, assign) UIWebView* refernceWebView;

- (void) loadNotesToMerge:(NSString*)notesToMerge;


typedef enum {
    noteType0 = 0xa9d6a4,
    noteType1 = 0x9fddf6,
    noteType2 = 0xfac9cf,
    noteType3 = 0xfff49a,
    noteType4 = 0x43bb00,
    noteType5 = 0x5da5d9,
    noteType6 = 0xec0c00
} NoteTypesColors;


@end
