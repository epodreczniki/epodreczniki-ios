







#import "EPNoteEditTableViewController.h"
#import "EPNotesModel.h"


#define UIColorFromRGB(rgbValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
            green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
            blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
            alpha:1.0]

@interface EPNoteEditTableViewController ()

@end



@implementation EPNoteEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];




    
    if (self.note.subject== nil || self.note.subject.length == 0) {
        self.titleTextField.text = NSLocalizedString(@"EPNoteEditTableViewController_newNoteDefaultName", nil);
    }
    else {
        self.titleTextField.text = self.note.subject;
    }
    self.contentTextView.text = self.note.value;
    
    if (self.editingMode == EPNoteReadOnly_Mode) {
        self.titleTextField.enabled = NO;
        self.contentTextView.editable = NO;
        self.segmentColorPicker.enabled = NO;
        self.saveButton.hidden = YES;

        [self.cacelButton setTitle:NSLocalizedString(@"EPNoteEditTableViewController_closeButton", nil)];
        [self checkIfITsOnlyBookmark:self.note];
    }
    else {
        self.editButton.enabled = NO;
        if (self.editingMode == EPNoteCreateNew_Mode) {
            if ([self.note.notesToMerge length] > 0) {

                [self loadNotesToMerge:self.note.notesToMerge];
            }
            [self.contentTextView becomeFirstResponder];
            

            [self.cacelButton setTitle:NSLocalizedString(@"EPNoteEditTableViewController_cancelButton", nil)];
        }
    }
    
    [self.editButton setTitle: NSLocalizedString(@"EPNoteEditTableViewController_editButton", nil)];
    [self.saveButton setTitle: NSLocalizedString( @"EPNoteEditTableViewController_saveButton", nil) forState: UIControlStateNormal];
    self.navigationItem.titleView = self.saveButton;
    [self setTitle:NSLocalizedString(@"EPNoteEditTableViewController_windowTitle", nil)];
    
    if (self.note.isBookmarkOnly) {
        [self setTitle:NSLocalizedString(@"EPNoteEditTableViewController_titleBookmark", nil)];
        [self setSelectedSegmentColorForBookmarks];
    }
    else {
        [self setTitle:NSLocalizedString(@"EPNoteEditTableViewController_titleNote", nil)];
        [self setSelectedSegmentColorForNotes];
    }

    [self.segmentColorPicker addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self selectInitialColor:self.note];

    [self addCloseDissmisButtonOverKeyboard];
}

- (void) viewDidAppear:(BOOL)animated {

    [self.tableView  scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];



    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


-(void) addCloseDissmisButtonOverKeyboard {
    if ([UIDevice currentDevice].isIPhone ) {

        UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EPLoginChooseUserCell_closeButtonTitle", nil)
                                                                          style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonAction)];

        UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 44.0f)];
        accessoryView.backgroundColor = [UIColor colorWithWhite:0.900 alpha:0.600];
        accessoryView.items = @[
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                dismissButton
                                ];

        self.contentTextView.inputAccessoryView = accessoryView;
        self.titleTextField.inputAccessoryView = accessoryView;
    }
}

#pragma mark - note/bookmarks types

-(void)checkIfITsOnlyBookmark:(EPNote*)note {
    if ([note.type isEqualToString:@"0"] || [note.type isEqualToString:@"1"] || [note.type isEqualToString:@"2"] || [note.type isEqualToString:@"3"]) {
        note.isBookmarkOnly = YES;
    }
}


-(void)selectInitialColor:(EPNote*)note {
    int segmentIndex=0;
    if ([note.type length] > 0) {
        if ([note.type isEqualToString:@"0"]) {
            segmentIndex=0;
        }
        else if ([note.type isEqualToString:@"1"]) {
            segmentIndex=1;
        }
        else if ([note.type isEqualToString:@"2"]) {
            segmentIndex=2;
        }
        else if ([note.type isEqualToString:@"3"]) {
            segmentIndex=3;
        }
        else if ([note.type isEqualToString:@"4"]) {
            segmentIndex=0;
        }
        else if ([note.type isEqualToString:@"5"]) {
            segmentIndex=1;
        }
        else if ([note.type isEqualToString:@"6"]) {
            segmentIndex=2;
        }
    }
    
    [self.segmentColorPicker setSelectedSegmentIndex:segmentIndex];
    [self.segmentColorPicker setImage:[UIImage imageNamed:@"IconMsgOk.png"] forSegmentAtIndex:segmentIndex];

}

-(void)setSelectedSegmentColorForNotes {
    [self.segmentColorPicker removeSegmentAtIndex:3 animated:NO];


    [[self.segmentColorPicker.subviews objectAtIndex:2] setBackgroundColor:UIColorFromRGB(noteType4)];
    [[self.segmentColorPicker.subviews objectAtIndex:2] setTintColor:UIColorFromRGB(noteType4)];
    
    [[self.segmentColorPicker.subviews objectAtIndex:1] setBackgroundColor:UIColorFromRGB(noteType5)];
    [[self.segmentColorPicker.subviews objectAtIndex:1] setTintColor:UIColorFromRGB(noteType5)];
    
    [[self.segmentColorPicker.subviews objectAtIndex:0] setBackgroundColor:UIColorFromRGB(noteType6)];
    [[self.segmentColorPicker.subviews objectAtIndex:0] setTintColor:UIColorFromRGB(noteType6)];

        }

-(void)segmentAction:(UISegmentedControl*)sender {
    for(int i=0;i<[sender subviews].count;i++)
    {
        [sender setImage:[UIImage imageNamed:@""] forSegmentAtIndex:i];
    }

    
    [sender setImage:[UIImage imageNamed:@"IconMsgOk.png"] forSegmentAtIndex:sender.selectedSegmentIndex];

}

-(void)setSelectedSegmentColorForBookmarks {

    [[self.segmentColorPicker.subviews objectAtIndex:3] setBackgroundColor:UIColorFromRGB(noteType0)];
    [[self.segmentColorPicker.subviews objectAtIndex:3] setTintColor:UIColorFromRGB(noteType0)];
    
    [[self.segmentColorPicker.subviews objectAtIndex:2] setBackgroundColor:UIColorFromRGB(noteType1)];
    [[self.segmentColorPicker.subviews objectAtIndex:2] setTintColor:UIColorFromRGB(noteType1)];
    
    [[self.segmentColorPicker.subviews objectAtIndex:1] setBackgroundColor:UIColorFromRGB(noteType2)];
    [[self.segmentColorPicker.subviews objectAtIndex:1] setTintColor:UIColorFromRGB(noteType2)];
    
    [[self.segmentColorPicker.subviews objectAtIndex:0] setBackgroundColor:UIColorFromRGB(noteType3)];
    [[self.segmentColorPicker.subviews objectAtIndex:0] setTintColor:UIColorFromRGB(noteType3)];
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"EPNoteEditTableViewController_headerName", nil);
    }
    else if (section == 1)
    {
        if (self.note.isBookmarkOnly) {
            return @"";
        }
        else {
            return NSLocalizedString(@"EPNoteEditTableViewController_headerContent", nil);
        }
    }
    else if (section == 2) {
        return @"";
    }
    else if (section == 3) {
        if (self.note.isBookmarkOnly) {
            return NSLocalizedString(@"EPNoteEditTableViewController_bookmarkColor", nil);
        }
        else {
            return NSLocalizedString(@"EPNoteEditTableViewController_notesColor", nil);
        }
    }
    else {
        return @"";
    }
}







- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.note.isBookmarkOnly) {
        if (section == 1) {
            return 0;
        }
    }
    return 1;
}

#pragma mark - UITextFieldDelegate












#pragma mark - Actions

- (void)dismissButtonAction {
    [self.contentTextView resignFirstResponder];
    [self.titleTextField resignFirstResponder];
}


- (IBAction)cancelButtonAction:(id)sender {
    if (self.editingMode == EPNoteEditExisting_Mode) {


        [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookReaderDeleteNoteNotification object:self.note];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editButtonAction:(id)sender {
    if (self.editingMode == EPNoteReadOnly_Mode) {
        self.titleTextField.enabled = YES;
        self.contentTextView.editable = YES;
        self.segmentColorPicker.enabled = YES;
        self.saveButton.hidden = NO;

        self.editButton.title =
            NSLocalizedString(@"EPNoteEditTableViewController_cancelButton", nil);
        self.editingMode = EPNoteEditExisting_Mode;

        self.cacelButton.title =
            NSLocalizedString(@"EPNoteEditTableViewController_deleteButton", nil);
        self.cacelButton.tintColor = [UIColor redColor];
        [self.contentTextView becomeFirstResponder];
    }
    else if (self.editingMode == EPNoteEditExisting_Mode) {
        self.titleTextField.enabled = NO;
        self.contentTextView.editable = NO;
        self.segmentColorPicker.enabled = NO;
        self.saveButton.hidden = YES;
        self.editButton.title =
            NSLocalizedString(@"EPNoteEditTableViewController_editButton", nil);
        self.editingMode = EPNoteReadOnly_Mode;
        
        self.cacelButton.title = 
            NSLocalizedString(@"EPNoteEditTableViewController_closeButton", nil);
        self.cacelButton.tintColor = self.editButton.tintColor;
    }
}

- (IBAction)saveButtonAction:(id)sender {
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    
    self.note.subject = self.titleTextField.text;
    self.note.value = self.contentTextView.text;
    
    int type = (int)self.segmentColorPicker.selectedSegmentIndex;
    if (self.note.isBookmarkOnly) {
        self.note.type = [NSString stringWithFormat: @"%d", type];
    }
    else {
        type += 4;
        self.note.type = [NSString stringWithFormat: @"%d", type];
    }
    
    if (self.editingMode == EPNoteCreateNew_Mode) {
        [notesModel addNote:self.note onWebView:self.refernceWebView];
    }
    else if (self.editingMode == EPNoteEditExisting_Mode) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookReaderUpdateNoteNotification object:self.note];

    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void) loadNotesToMerge:(NSString*)notesToMerge {
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    NSString* content = [notesModel mergeContentTextOfNotes:notesToMerge];
    self.contentTextView.text = content;
}
@end
