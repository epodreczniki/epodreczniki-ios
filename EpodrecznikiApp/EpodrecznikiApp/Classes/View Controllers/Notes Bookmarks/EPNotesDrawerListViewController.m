







#import "EPNotesDrawerListViewController.h"
#import "EPTextbookDrawerViewController.h"
#import "EPNoteEditTableViewController.h"

@implementation EPNotesDrawerListViewController {
    NSMutableArray* _array;
    EPNote *selectedNote;
    UILabel *labelNoBookmarks;
    UILabel *labelNoNotes;
}



- (void)viewDidLoad {
    [super viewDidLoad];


    labelNoBookmarks = [[UILabel alloc] initWithFrame:self.notesListTableView.frame];
    labelNoBookmarks.autoresizingMask = self.notesListTableView.autoresizingMask;
    labelNoBookmarks.textAlignment = NSTextAlignmentCenter;
    labelNoBookmarks.backgroundColor = [UIColor whiteColor];
    labelNoBookmarks.text = NSLocalizedString(@"EPNotesDrawerListViewController_labelNoBookmarks", nil);
    [self.view addSubview:labelNoBookmarks];
    
    labelNoNotes = [[UILabel alloc] initWithFrame:self.notesListTableView.frame];
    labelNoNotes.autoresizingMask = self.notesListTableView.autoresizingMask;
    labelNoNotes.textAlignment = NSTextAlignmentCenter;
    labelNoNotes.backgroundColor = [UIColor whiteColor];
    labelNoNotes.text = NSLocalizedString(@"EPNotesDrawerListViewController_labelNoNotes", nil);
    [self.view addSubview:labelNoNotes];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNoteNotification:) name:kTextbookReaderDeleteNoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNoteNotification:) name:kTextbookReaderUpdateNoteNotification object:nil];
    
    if (self.openedFromDetailsWindow) {
        [self.backButton setTitle: @""];
    }
    else {
        [self.backButton setTitle: NSLocalizedString(@"EPNotesDrawerListViewController_backButton", nil)];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _array = nil;
    selectedNote = nil;
}

-(void) viewWillAppear:(BOOL)animated {
    [self segmentSelectionChanged:self.chooserSegmentControl];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EPNotesDrawerToNotesEditSegue"]) {
        EPNoteEditTableViewController *noteVC = (EPNoteEditTableViewController *)[segue.destinationViewController topViewController];
        noteVC.note = selectedNote;
    }
}


#pragma mark - Private methods

- (void) loadNotes {

    
    self.navigationItem.title = NSLocalizedString(@"EPNotesDrawerListViewController_switchNotes", nil);
    
    if (self.openedFromDetailsWindow)
    {

    }
    else
    {
        EPTextbookDrawerViewController *drawer = (EPTextbookDrawerViewController *)self.parentViewController.parentViewController;
        self.textbookRootID =  drawer.textbookRootID;
    }
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    _array = [notesModel getNotesForTextbook:self.textbookRootID];
    [self.notesListTableView reloadData];
    
    labelNoNotes.hidden = (_array.count > 0);
    labelNoBookmarks.hidden = YES;
}

-(void) loadBookmarks {

    
    self.navigationItem.title = NSLocalizedString(@"EPNotesDrawerListViewController_switchBookmarks", nil);
    
    if (self.openedFromDetailsWindow)
    {

    }
    else
    {
        EPTextbookDrawerViewController *drawer = (EPTextbookDrawerViewController *)self.parentViewController.parentViewController;
        self.textbookRootID =  drawer.textbookRootID;
    }
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    _array = [notesModel getBookmarksForTextbook:self.textbookRootID];
    [self.notesListTableView reloadData];
    
    labelNoBookmarks.hidden = (_array.count > 0);
    labelNoNotes.hidden = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {




    
    UITableViewCell *cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    EPNote* note = [_array objectAtIndex:indexPath.row];
    CGFloat cellWidth = cell.contentView.frame.size.width;
    
    UIColor *cellColor = [UIColor whiteColor];
    if ([note.type isEqualToString:@"0"]) {
        cellColor = UIColorFromRGB(noteType0);
    }
    else if ([note.type isEqualToString:@"1"]) {
        cellColor = UIColorFromRGB(noteType1);
    }
    else if ([note.type isEqualToString:@"2"]) {
        cellColor = UIColorFromRGB(noteType2);
    }
    else if ([note.type isEqualToString:@"3"]) {
        cellColor = UIColorFromRGB(noteType3);
    }
    else if ([note.type isEqualToString:@"4"]) {
        cellColor = UIColorFromRGB(noteType4);
    }
    else if ([note.type isEqualToString:@"5"]) {
        cellColor = UIColorFromRGB(noteType5);
    }
    else if ([note.type isEqualToString:@"6"]) {
        cellColor = UIColorFromRGB(noteType6);
    }
    
    
    if (self.chooserSegmentControl.selectedSegmentIndex == 0) {
        cell.textLabel.text = note.subject;
        cell.backgroundColor = cellColor;
    }
    else
    {
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(7, 7, cellWidth-55, 30)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textLabel.text = note.subject;
        [cell.contentView addSubview:textLabel];
        
        UIButton *showNoteTextButton = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth-50, 0, 50, 40)];
        showNoteTextButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        UIImage *normalImage = [UIImage imageNamed: @"IconNotes.png"];
        [showNoteTextButton setImage:normalImage forState:UIControlStateNormal];
        showNoteTextButton.tag = indexPath.row;
        [showNoteTextButton addTarget:self action:@selector(showNoteText:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:showNoteTextButton];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(7, 37, cellWidth-55, 2)];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        line.backgroundColor = cellColor;
        [cell.contentView addSubview:line];
    }
    

       return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {   
    @try {
        EPNote *currentItem = _array[indexPath.row];
        NSString* json = [currentItem getFromJsonField:@"pageItem"];
        EPPageItem *pageItem = [EPPageItem pageItemFromString:json];
        EPConfiguration *configuration = [EPConfiguration activeConfiguration];
        if (pageItem.isTeacher) {
            if (configuration.user.state.isTeacher == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EPNotesDrawerListViewController_WarningTeachersOnlyTitle", nil)
                                                                message:NSLocalizedString(@"EPNotesDrawerListViewController_WarningTeachersOnlyText", nil)
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
        }

        EPAnchor *anchorObject = [EPAnchor new];
        anchorObject.isNote = YES;
        anchorObject.anchorValue = [NSString stringWithFormat:@"%@", currentItem.localNoteId];
        anchorObject.anchorPath = pageItem.path;
        [configuration.tocModel setAnchor:anchorObject forPageItemPath:pageItem.path];
        
        if (self.openedFromDetailsWindow) {

            [configuration.textbookUtil setLastViewedPageItem:pageItem forTextbookRootID:self.textbookRootID];

            EPTextbookDrawerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EPTextbookDrawerViewController"];
            vc.textbookRootID = self.textbookRootID;
            [self presentViewController:vc animated:YES completion:nil];
        }
        else {

            NSInteger pageIndex = [configuration.tocModel pageIndexByPageId:currentItem.pageId inTeacherMode:pageItem.isTeacher];

            NSDictionary *dictionary = @{
                kTextbookReaderLoadPageByIndexNotificationPageIndexKey: @(pageIndex)
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookReaderLoadPageByIndexNotification object:nil userInfo:dictionary];

            [self backButtonAction:self];
        }
    }
    @catch (NSException *exception) {

    }
}

#pragma mark - Actions

-(void)showNoteText:(UIButton *) clikedButton {

    EPNote *clikedItem = _array[clikedButton.tag];
    selectedNote = clikedItem;
    
    [self performSegueWithIdentifier:@"EPNotesDrawerToNotesEditSegue" sender:nil];
}

- (IBAction)segmentSelectionChanged:(id)sender {
    if (self.chooserSegmentControl.selectedSegmentIndex == 0) {
        [self loadBookmarks];
    }
    else {
        [self loadNotes];
    }
}

- (IBAction)backButtonAction:(id)sender {
    if (self.parentViewController && self.parentViewController.parentViewController) {
        MMDrawerController *drawer = (MMDrawerController *)self.parentViewController.parentViewController;
        [drawer closeDrawerAnimated:YES completion:nil];
    }
}

#pragma mark - Notifications
- (void)deleteNoteNotification:(NSNotification *)notification {
    EPNote* note = notification.object;
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    [notesModel deleteNote:note onWebView:nil];
    
    _array = [notesModel getNotesForTextbook:self.textbookRootID];
    [self.notesListTableView reloadData];

    
    labelNoNotes.hidden = (_array.count > 0);
}


- (void)updateNoteNotification:(NSNotification *)notification {
    EPNote* note = notification.object;
    
    EPNotesModel *notesModel = [EPConfiguration activeConfiguration].notesModel;
    [notesModel updateNote:note onWebView:nil   ];
    _array = [notesModel getNotesForTextbook:self.textbookRootID];
    [self.notesListTableView reloadData];
}



@end
