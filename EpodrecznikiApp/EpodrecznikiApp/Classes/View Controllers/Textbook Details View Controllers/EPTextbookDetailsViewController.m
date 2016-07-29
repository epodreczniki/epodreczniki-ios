







#import "EPTextbookDetailsViewController.h"
#import "EPTextbookViewController.h"
#import "EPTextbookDrawerViewController.h"
#import "EPURL.h"
#import "EPBackButtonItem.h"
#import "EPAlertViewHandler.h"
#import "EPProgressHUD.h"
#import "EPNotesDrawerListViewController.h"
#import "EPCreatorsRole.h"

#import "EPTextbookCollectionViewCellReverseView.h"
#import "EPTextbookCarouselCellView.h"
#import "EPAppDelegate.h"

@interface EPTextbookDetailsViewController ()

@property (nonatomic, weak) EPDownloadTextbookProxy *proxy;
@property (nonatomic) CGFloat margin;

- (void)loadCoverFromCollection:(EPCollection *)collection;
- (void)loadDetailsFromCollection:(EPCollection *)collection;
- (void)prepareView;
- (void)setTextviewAsDimmed:(BOOL)dimmed;

@end

@implementation EPTextbookDetailsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"EPTextbookDetailsViewController_navigationBarTitle", nil);
    self.navigationItem.backBarButtonItem = [EPBackButtonItem new];

    if ([UIDevice currentDevice].isIPad) {
        self.margin = 166.0 / 6.0;
    }
    else {
        self.margin = 69.0 / 6.0;
    }

    EPTextbookModel *textbookModel = EPConfiguration.activeConfiguration.textbookModel;
    EPMetadata *metadata = [textbookModel metadataWithRootID:self.textbookRootID];
    EPCollection *collection = [textbookModel collectionWithContentID:metadata.actualContentID];
    
#if DEBUG_OBJECTS
    [collection printMe];
#endif

    self.buttonsView = [EPDetailsButtonsView viewWithNibName:@"EPDetailsButtonsView"];
    self.buttonsView.delegate = self;
    [self.view addSubview:self.buttonsView];
    [self.view sendSubviewToBack:self.buttonsView];
    [self.coverImageView makeAccessabilityTrait:UIAccessibilityTraitStaticText withLabel:@" "];

    self.proxy = [[EPConfiguration activeConfiguration].downloadUtil downloadTextbookProxyForRootID:self.textbookRootID];
    self.proxy.delegate = self;
    
#if DEBUG_STATE_TRANSITIONS
    self.proxy.storeCollection.state = EPTextbookStateTypeToDownload;
#endif

    [self loadCoverFromCollection:collection];

    [self loadDetailsFromCollection:collection];
    if (self.proxy.storeCollection.state == EPTextbookStateTypeUpdating) {
        [self setTextviewAsDimmed:YES];
    }
    else {
        [self setTextviewAsDimmed:NO];
    }

    [self prepareView];

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self willRotateToInterfaceOrientation:orientation duration:0];

#if DEBUG_STATE_TRANSITIONS
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Debug" style:UIBarButtonItemStylePlain target:self action:@selector(debugTransitions)];
#endif
}

- (void)dealloc {
    self.textbookRootID = nil;
    self.coverImageView.progressImage = nil;
    self.textView.attributedText = nil;
    self.buttonsView.delegate = nil;
    self.proxy = nil;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EPTextbookViewControllerSegue"]) {
        EPTextbookViewController *vc = (EPTextbookViewController *)[segue.destinationViewController topViewController];
        vc.textbookRootID = self.textbookRootID;
    }
    else if ([segue.identifier isEqualToString:@"EPTextbookDrawerViewControllerSegue"]) {
        EPTextbookDrawerViewController *vc = (EPTextbookDrawerViewController *)segue.destinationViewController;
        vc.textbookRootID = self.textbookRootID;
    }
    else if ([segue.identifier isEqualToString:@"FromDetailsToNotesListSegue"]) {
        EPNotesDrawerListViewController *vc = (EPNotesDrawerListViewController *)segue.destinationViewController;
        vc.textbookRootID = self.textbookRootID;
        vc.openedFromDetailsWindow = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.isMovingFromParentViewController) {
        self.proxy.delegate = nil;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - View rotation

- (void)viewWillLayoutSubviews {

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self willRotateToInterfaceOrientation:orientation duration:0];

    [self.navigationItem.titleView layoutIfNeeded];
    [self.navigationItem.titleView setNeedsLayout];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    int y = 64;
    CGSize screenSize;

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        screenSize = [UIScreen mainScreen].portraitScreenSize;

        if ([UIDevice currentDevice].isIPad) {
            self.coverAndMarkView.frame = CGRectMake(0 + self.margin, y + self.margin, 165, 234);
            self.buttonsView.frame = CGRectMake(
                self.coverAndMarkView.frame.size.width + self.margin,
                y,
                screenSize.width - self.coverAndMarkView.frame.size.width,
                166
            );
            self.textView.frame = CGRectMake(
                self.coverAndMarkView.frame.origin.x + self.coverAndMarkView.frame.size.width + self.margin,
                y + self.buttonsView.frame.size.height,
                self.buttonsView.frame.size.width - 3 * self.margin,
                screenSize.height - (y + self.buttonsView.frame.size.height) - self.margin
            );
        }

        else {
            self.coverAndMarkView.frame = CGRectMake(0 + self.margin, y + self.margin, 68, 96);
            self.buttonsView.frame = CGRectMake(
                self.coverAndMarkView.frame.size.width + self.margin,
                y,
                screenSize.width - self.coverAndMarkView.frame.size.width,
                69
            );
            self.textView.frame = CGRectMake(
                self.coverAndMarkView.frame.origin.x + self.coverAndMarkView.frame.size.width + self.margin,
                y + self.buttonsView.frame.size.height,
                self.buttonsView.frame.size.width - 3 * self.margin,
                screenSize.height - (y + self.buttonsView.frame.size.height) - self.margin
            );
        }
    }

    else {
        screenSize = [UIScreen mainScreen].landscapeScreenSize;

        if ([UIDevice currentDevice].isIPad) {
            self.coverAndMarkView.frame = CGRectMake(0 + self.margin, y + self.margin, 410, 580);
            self.buttonsView.frame = CGRectMake(
                self.coverAndMarkView.frame.size.width + self.margin,
                y,
                screenSize.width - self.coverAndMarkView.frame.size.width,
                166
            );
            self.textView.frame = CGRectMake(
                self.coverAndMarkView.frame.size.width + 2 * self.margin,
                y + self.buttonsView.frame.size.height,
                self.buttonsView.frame.size.width - 3 * self.margin,
                screenSize.height - (y + self.buttonsView.frame.size.height) - self.margin
            );
        }

        else {
            y = 52;
            self.coverAndMarkView.frame = CGRectMake(
                0 + self.margin, y + self.margin,
                (screenSize.height - y - 2 * self.margin) / 1.4133333,
                screenSize.height - y - 2 * self.margin
            );
            self.buttonsView.frame = CGRectMake(
                self.coverAndMarkView.frame.size.width + self.margin,
                y,
                screenSize.width - self.coverAndMarkView.frame.size.width,
                69
            );
            self.textView.frame = CGRectMake(
                self.coverAndMarkView.frame.size.width + 2 * self.margin,
                y + self.buttonsView.frame.size.height,
                self.buttonsView.frame.size.width - 3 * self.margin,
                screenSize.height - (y + self.buttonsView.frame.size.height) - self.margin
            );
        }
    }

    [self.textView setContentOffset:CGPointMake(0, 0)];
    [self.coverAndMarkView bringSubviewToFront:self.textView];
    [UIView addShadowToView:self.coverImageView];
}

#pragma mark - Private methods

- (void)loadCoverFromCollection:(EPCollection *)collection {

    self.coverImageView.progressImage = [UIImage imageNamed:@"IconPlaceholder"];

    [[EPConfiguration activeConfiguration].downloadUtil loadCoverForContentID:collection.contentID completion:^(UIImage *image, BOOL fromCache) {

        if (!image) {
            return;
        }

        self.coverImageView.progressImage = image;
    }];
}

- (void)loadDetailsFromCollection:(EPCollection *)collection {
    
    NSMutableParagraphStyle *paragraphStyle = nil;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    NSRange range = NSMakeRange(0, [attributedText mutableString].length);
    NSString *tmpString = nil;
    
    CGFloat fontSize = 0.0f;
    CGFloat fontScale = 1.0;
    CGFloat marginSize = 1.0;
    if ([UIDevice currentDevice].isIPhone) {
        fontScale = 0.5;
        marginSize = 0.0;
    }
    else {
        fontScale = 1.00;
        marginSize = 0.0;
    }

    if (![NSObject isNullOrEmpty:collection.textbookTitle])
    {

        tmpString = [NSString stringWithFormat:@"%@\n", collection.textbookTitle];
        [[attributedText mutableString] appendString:tmpString];
        
        range = NSMakeRange(range.location + range.length, tmpString.length);
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.paragraphSpacing = 8.0;
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        
        fontSize = 44.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }
    
    if (![NSObject isNullOrEmpty:collection.textbookSubtitle])
    {


        tmpString = [NSString stringWithFormat:@"%@\n", collection.textbookSubtitle];
        [[attributedText mutableString] appendString:tmpString];
        
        range = NSMakeRange(range.location + range.length, tmpString.length);
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.paragraphSpacing = 20.0;
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        
        fontSize = 28.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }

    if (![NSObject isNullOrEmpty:collection.schoolEducationLevel])
    {
        BOOL isLast = (!collection.schoolClass && !collection.subjectName);

        tmpString = [NSString stringWithFormat:@"%@ ", @"Szkoła"];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        
        NSRange paragraphRange = range;

        NSString *shortSchool = [[EPConfiguration activeConfiguration].textbookModel shortStringFromEducationLevel:collection.schoolEducationLevel];
        tmpString = [NSString stringWithFormat:@"%@\n", shortSchool];
        
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:range];

        paragraphRange.length += range.length;
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        if (isLast) {
            paragraphStyle.paragraphSpacing = 24.0;
        }
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:paragraphRange];
    }

    if (![NSObject isNullOrEmpty:collection.schoolClass])
    {
        BOOL isLast = (!collection.subjectName);

        tmpString = [NSString stringWithFormat:@"%@ ", @"Klasa"];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        
        NSRange paragraphRange = range;

        tmpString = [NSString stringWithFormat:@"%@\n", collection.schoolClass];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:range];

        paragraphRange.length += range.length;
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        if (isLast) {
            paragraphStyle.paragraphSpacing = 24.0;
        }
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:paragraphRange];
    }

    if (![NSObject isNullOrEmpty:collection.subjectName])
    {
        BOOL isLast = YES;

        tmpString = [NSString stringWithFormat:@"%@ ", @"Przedmiot"];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        
        NSRange paragraphRange = range;

        tmpString = [NSString stringWithFormat:@"%@\n", collection.subjectName];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:range];

        paragraphRange.length += range.length;
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        if (isLast) {
            paragraphStyle.paragraphSpacing = 24.0;
        }
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:paragraphRange];
    }

    if (![NSObject isNullOrEmpty:collection.textbookAbstract])
    {

        tmpString = [NSString stringWithFormat:@"%@\n", @"Streszczenie"];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        paragraphStyle.paragraphSpacing = 8.0;
        
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:range];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];

        tmpString = [NSString stringWithFormat:@"%@\n", collection.textbookAbstract];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        paragraphStyle.paragraphSpacing = 24.0;
        
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }
    
    @try {
        if (![NSObject isNullOrEmpty:collection.authorWithRoles]) {
            for (int r=0; r<collection.authorWithRoles.count; r++) {
                EPCreatorsRole* creatorsRole = collection.authorWithRoles[r];
                tmpString = [NSString stringWithFormat:@"%@\n", creatorsRole.roleName ];
                [[attributedText mutableString] appendString:tmpString];
                range = NSMakeRange(range.location + range.length, tmpString.length);
                
                paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.headIndent = 20.0 * marginSize;
                paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
                paragraphStyle.tailIndent = -20.0 * marginSize;
                paragraphStyle.paragraphSpacing = 8.0;
                
                fontSize = 24.0 * fontScale;
                [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:range];
                [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];

                tmpString = [NSString stringWithFormat:@"%@\n", [creatorsRole.names componentsJoinedByString:@", "]];
                [[attributedText mutableString] appendString:tmpString];
                range = NSMakeRange(range.location + range.length, tmpString.length);
                
                paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.headIndent = 20.0 * marginSize;
                paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
                paragraphStyle.tailIndent = -20.0 * marginSize;
                paragraphStyle.paragraphSpacing = 24.0;
                
                fontSize = 24.0 * fontScale;
                [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
                [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
            }
        }
    }
    @catch (NSException *exception) {

    }

    if (![NSObject isNullOrEmpty:collection.textbookLicense])
    {

        tmpString = [NSString stringWithFormat:@"%@\n", @"Licencja"];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        paragraphStyle.paragraphSpacing = 8.0;
        
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:range];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];

        tmpString = [NSString stringWithFormat:@"%@\n", collection.textbookLicense];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        paragraphStyle.paragraphSpacing = 24.0;
        
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    }

    if (![NSObject isNullOrEmpty:collection.textbookMdVersion])
    {

        tmpString = [NSString stringWithFormat:@"%@ ", @"Wersja podręcznika"];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        
        NSRange paragraphRange = range;

        tmpString = [NSString stringWithFormat:@"%@\n", collection.textbookMdVersion];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:range];

        paragraphRange.length += range.length;
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:paragraphRange];
    }

    if (collection.formatZipSize > 0)
    {

        tmpString = [NSString stringWithFormat:@"%@ ", @"Rozmiar"];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:range];
        
        NSRange paragraphRange = range;

        tmpString = [NSString stringWithFormat:@"%@\n", [self stringWithStorageSize:collection.formatZipSize]];
        [[attributedText mutableString] appendString:tmpString];
        range = NSMakeRange(range.location + range.length, tmpString.length);
        fontSize = 24.0 * fontScale;
        [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:range];

        paragraphRange.length += range.length;
        
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 20.0 * marginSize;
        paragraphStyle.firstLineHeadIndent = 20.0 * marginSize;
        paragraphStyle.tailIndent = -20.0 * marginSize;
        [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:paragraphRange];
    }

    if ([[attributedText mutableString] hasSuffix:@"\n"]) {
        NSRange range = NSMakeRange([attributedText mutableString].length - 1, 1);
        [[attributedText mutableString] deleteCharactersInRange:range];
    }

    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.textView.editable = YES;
    self.textView.selectable = YES;
    
    self.textView.attributedText = nil;
    self.textView.attributedText = attributedText;
    
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.textView.editable = NO;
}

- (NSString *)stringWithStorageSize:(unsigned long long)size {
    unsigned long long totalKb = size/STORAGE_KB;
    unsigned long long mb = totalKb/STORAGE_KB;
    unsigned long long kb = totalKb % STORAGE_KB;
    unsigned long long hundretsOfKb = kb/100;
    return [NSString stringWithFormat:@"%llu.%llu MB", mb, hundretsOfKb];
}

- (void)prepareView {

    EPTextbookStateType state = self.proxy.storeCollection.state;






    self.markImageView.hidden = !(state == EPTextbookStateTypeToUpdate || state == EPTextbookStateTypeUpdating);

    if (state == EPTextbookStateTypeToDownload) {
        self.coverImageView.progress = 0.0f;
    }

    else if (state == EPTextbookStateTypeNormal || state == EPTextbookStateTypeToUpdate) {
        self.coverImageView.progress = 1.0f;
    }

    if (state == EPTextbookStateTypeToDownload) {
        
        self.buttonsView.downloadButton.hidden = NO;
        self.buttonsView.updateButton.hidden = YES;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = NO;
        self.buttonsView.readButton.enabled = NO;
        self.buttonsView.bookmarksButton.enabled = NO;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:NO animated:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateToDownload", nil);
    }

    else if (state == EPTextbookStateTypeDownloading) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = YES;
        self.buttonsView.stopButton.hidden = NO;
        
        self.buttonsView.deleteButton.enabled = NO;
        self.buttonsView.readButton.enabled = NO;
        self.buttonsView.bookmarksButton.enabled = NO;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:YES animated:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateDownloading", nil);
    }

    else if (state == EPTextbookStateTypeNormal) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = NO;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = YES;
        self.buttonsView.readButton.enabled = YES;
        self.buttonsView.bookmarksButton.enabled = YES;
        self.buttonsView.updateButton.enabled = NO;
        
        [self.buttonsView setProgressVisible:NO animated:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateNormal", nil);
    }

    else if (state == EPTextbookStateTypeToUpdate) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = NO;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = YES;
        self.buttonsView.readButton.enabled = YES;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:NO animated:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateToUpdate", nil);
    }

    else if (state == EPTextbookStateTypeUpdating) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = YES;
        self.buttonsView.stopButton.hidden = NO;
        
        self.buttonsView.deleteButton.enabled = NO;
        self.buttonsView.readButton.enabled = NO;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:YES animated:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateUpdating", nil);
    }

    if (self.proxy.isUnpacking) {
        [self willBeginExtractingForDownloadTextbookProxy:self.proxy];
    }

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverTap:)];
    [self.coverAndMarkView addGestureRecognizer:tapGesture];
}

- (void)handleCoverTap:(UIGestureRecognizer *)gestureRecognizer {
    
    EPTextbookStateType state = self.proxy.storeCollection.state;
    if (state == EPTextbookStateTypeNormal || state == EPTextbookStateTypeToUpdate) {

        if ([[EPConfiguration activeConfiguration].textbookUtil textbookRequiresAdvancedReaderWithProxy:self.proxy]) {
            
            [self performSegueWithIdentifier:@"EPTextbookDrawerViewControllerSegue" sender:self];
        }

        else {
            
            [self performSegueWithIdentifier:@"EPTextbookViewControllerSegue" sender:self];
        }
    }
}

- (void)setTextviewAsDimmed:(BOOL)dimmed {
    if (dimmed) {
        self.textView.textColor = [UIColor grayColor];
    }
    else {
        self.textView.textColor = [UIColor blackColor];
    }
}

- (void)debugTransitions {
    static int index = 0;
    
    const int max = 18;
    if (index > max - 1) {
        index = 0;
    }
    
    int from[max] = {
        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeNormal,

        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeNormal,

        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeUpdating,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeUpdating,
        EPTextbookStateTypeNormal,

        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeToUpdate
    };
    int to[max] = {
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeToDownload,
        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToDownload,

        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToUpdate,

        EPTextbookStateTypeUpdating,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeUpdating,
        EPTextbookStateTypeNormal,
        EPTextbookStateTypeToDownload,

        EPTextbookStateTypeDownloading,
        EPTextbookStateTypeToUpdate,
        EPTextbookStateTypeToDownload
    };

    [[NSString stringWithFormat:@"index: %d, from: %@, to: %@", index,
        NSStringFromEPTextbookStateType(from[index]),
        NSStringFromEPTextbookStateType(to[index])] printMe];

    [self downloadTextbookProxy:nil didChangeTextbookStateTo:to[index] fromState:from[index]];

    index++;
}

#pragma mark - EPDetailsButtonsViewDelegate

- (void)didClickDeleteButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView {


    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPTextbooksListViewController_confirmDeleteAlertViewTitle", nil);
    handler.message = NSLocalizedString(@"EPTextbooksListViewController_confirmDeleteAlertViewMessage", nil);
    [handler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmDeleteAlertViewButtonYes", nil) andActionBlock:^{

        BOOL canDelete = (self.proxy.storeCollection.state == EPTextbookStateTypeNormal || self.proxy.storeCollection.state == EPTextbookStateTypeToUpdate);
        if (!canDelete) {
            return;
        }

        UIView *hudParent = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        EPProgressHUD *progressHud = [EPProgressHUD showHUDAddedTo:hudParent animated:YES];
        progressHud.mode = MBProgressHUDModeIndeterminate;
        progressHud.labelText = NSLocalizedString(@"EPTextbooksListViewController_hudRemoveTextbookPending", nil);
        progressHud.removeFromSuperViewOnHide = YES;

        [self.proxy removeWithCompletion:^(BOOL success) {

            if (success) {
                progressHud.labelText = NSLocalizedString(@"EPTextbooksListViewController_hudRemoveTextbookSuccess", nil);
                [progressHud showOkIcon];
            }
            else {
                progressHud.labelText = NSLocalizedString(@"EPTextbooksListViewController_hudRemoveTextbookError", nil);
                [progressHud showErrorIcon];
            }
            [progressHud addCloseHandler];
            [progressHud hide:YES afterDelay:3.0f];
            
            [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
            [[EPConfiguration activeConfiguration].accessibilityUtil playAnnouncement:NSLocalizedString(@"Accessability_announcementDeleted", nil) after:3.0f];
            
        }];
    }];
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmDeleteAlertViewButtonNo", nil) andActionBlock:nil];
    [handler show];
}

- (void)didClickDownloadButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView {

    
    [self didSelectDownloadOrUpdateButtonAtIndex:YES];
}

- (void)didClickUpdateButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView {

    
    [self didSelectDownloadOrUpdateButtonAtIndex:NO];
}

- (void)didSelectDownloadOrUpdateButtonAtIndex:(BOOL)download {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        EPNetworkUtil *networkUtil = [EPConfiguration activeConfiguration].networkUtil;

        if (networkUtil.isNetworkUnreachable) {

            [self downloadOrUpdateItem:download];
        }

        else if (networkUtil.isNetworkReachableAndAllowed) {
            [self downloadOrUpdateItem:download];
        }

        else {
            EPSettingsModel *settingsModel = [EPConfiguration activeConfiguration].settingsModel;
            EPAlertViewHandler *handler = [EPAlertViewHandler new];
            handler.title = NSLocalizedString(@"EPTextbooksListViewController_confirmDownloadAlertViewTitle", nil);
            handler.message = NSLocalizedString(@"EPTextbooksListViewController_confirmDownloadAlertViewMessage", nil);
            [handler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmDownloadAlertViewButtonYes", nil) andActionBlock:^{

                settingsModel.allowUsingCellularNetwork = EPSettingsCellularStateTypeAllowed;
                [self downloadOrUpdateItem:download];
            }];
            [handler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmDownloadAlertViewButtonNo", nil) andActionBlock:^{

                settingsModel.allowUsingCellularNetwork = EPSettingsCellularStateTypeDenied;
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [handler show];
            });
        }
    });
}

- (void)downloadOrUpdateItem:(BOOL)download {

    [self.proxy checkAppVersion:^(BOOL success) {

        if (success) {

            if (download) {
                [self.proxy download];
            }

            else {
                [[EPConfiguration activeConfiguration].windowsUtil showUpdateWindowWithProxy:self.proxy];
            }
        }

        else {
            [[EPConfiguration activeConfiguration].windowsUtil showAppUpdateRequiredWindow];
        }
    }];
}

- (void)didClickReadButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView {

    if ([[EPConfiguration activeConfiguration].textbookUtil textbookRequiresAdvancedReaderWithProxy:self.proxy]) {
        
        [self performSegueWithIdentifier:@"EPTextbookDrawerViewControllerSegue" sender:self];
    }

    else {
        
        [self performSegueWithIdentifier:@"EPTextbookViewControllerSegue" sender:self];
    }
}

- (void)didClickStopButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView {


    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPTextbooksListViewController_confirmCancelAlertViewTitle", nil);
    handler.message = NSLocalizedString(@"EPTextbooksListViewController_confirmCancelAlertViewMessage", nil);
    [handler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmCancelAlertViewButtonYes", nil) andActionBlock:^{

        if (self.proxy.storeCollection.state == EPTextbookStateTypeDownloading || self.proxy.storeCollection.state == EPTextbookStateTypeUpdating) {
            [self.proxy cancel];
        }
    }];
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_confirmCancelAlertViewButtonNo", nil) andActionBlock:nil];
    [handler show];
}

- (void)didClickBookmarksButtonForDetailsButtonsView:(EPDetailsButtonsView *)buttonsView {

    [self performSegueWithIdentifier:@"FromDetailsToNotesListSegue" sender:self];
}

#pragma mark - EPDownloadTextbookProxyDelegate

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didChangeTextbookStateTo:(EPTextbookStateType)toState fromState:(EPTextbookStateType)fromState {

    self.buttonsView.downloadButton.enabled = YES;
    self.buttonsView.updateButton.enabled = YES;
    self.buttonsView.stopButton.enabled = YES;
    self.buttonsView.deleteButton.enabled = YES;
    self.buttonsView.readButton.enabled = YES;
    self.buttonsView.bookmarksButton.enabled = YES;
    self.buttonsView.updateButton.enabled = YES;

    if (fromState == EPTextbookStateTypeToDownload && toState == EPTextbookStateTypeDownloading) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = YES;
        self.buttonsView.stopButton.hidden = NO;
        
        self.buttonsView.deleteButton.enabled = NO;
        self.buttonsView.readButton.enabled = NO;
        self.buttonsView.bookmarksButton.enabled = NO;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:YES animated:YES];
        [self.buttonsView.progressCircleSmallView setNumericProgress:0.0f];
        self.markImageView.hidden = YES;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateDownloading", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeToDownload) {
        
        self.buttonsView.downloadButton.hidden = NO;
        self.buttonsView.updateButton.hidden = YES;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = NO;
        self.buttonsView.readButton.enabled = NO;
        self.buttonsView.bookmarksButton.enabled = NO;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 0.0f;
        self.markImageView.hidden = YES;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateToDownload", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeNormal) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = NO;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = YES;
        self.buttonsView.readButton.enabled = YES;
        self.buttonsView.bookmarksButton.enabled = YES;
        self.buttonsView.updateButton.enabled = NO;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 1.0f;
        self.markImageView.hidden = YES;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateNormal", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
        [[EPConfiguration activeConfiguration].accessibilityUtil playAnnouncement:NSLocalizedString(@"Accessability_announcementDownloaded", nil) after:3.0f];
    }

    else if (fromState == EPTextbookStateTypeDownloading && toState == EPTextbookStateTypeToUpdate) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = NO;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = YES;
        self.buttonsView.readButton.enabled = YES;
        self.buttonsView.bookmarksButton.enabled = YES;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 1.0f;
        self.markImageView.hidden = NO;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateToUpdate", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
    }

    else if (fromState == EPTextbookStateTypeNormal && toState == EPTextbookStateTypeToUpdate) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = NO;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = YES;
        self.buttonsView.readButton.enabled = YES;
        self.buttonsView.bookmarksButton.enabled = YES;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 1.0f;
        self.markImageView.hidden = NO;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateToUpdate", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeNormal) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = NO;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = YES;
        self.buttonsView.readButton.enabled = YES;
        self.buttonsView.bookmarksButton.enabled = YES;
        self.buttonsView.updateButton.enabled = NO;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 1.0f;
        self.markImageView.hidden = YES;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateNormal", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeUpdating) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = YES;
        self.buttonsView.stopButton.hidden = NO;
        
        self.buttonsView.deleteButton.enabled = NO;
        self.buttonsView.readButton.enabled = NO;
        self.buttonsView.bookmarksButton.enabled = NO;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:YES animated:YES];
        [self.buttonsView.progressCircleSmallView setNumericProgress:0.0f];
        self.markImageView.hidden = NO;
        [self setTextviewAsDimmed:YES];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateUpdating", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
    }

    else if (fromState == EPTextbookStateTypeUpdating && toState == EPTextbookStateTypeToUpdate) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = NO;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = YES;
        self.buttonsView.readButton.enabled = YES;
        self.buttonsView.bookmarksButton.enabled = YES;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 1.0f;
        self.markImageView.hidden = NO;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateToUpdate", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
        [[EPConfiguration activeConfiguration].accessibilityUtil playAnnouncement:NSLocalizedString(@"Accessability_announcementUpdated", nil) after:3.0f];
    }

    else if (fromState == EPTextbookStateTypeUpdating && toState == EPTextbookStateTypeNormal) {
        
        self.buttonsView.downloadButton.hidden = YES;
        self.buttonsView.updateButton.hidden = NO;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = YES;
        self.buttonsView.readButton.enabled = YES;
        self.buttonsView.bookmarksButton.enabled = YES;
        self.buttonsView.updateButton.enabled = NO;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 1.0f;
        self.markImageView.hidden = YES;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateNormal", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
        [[EPConfiguration activeConfiguration].accessibilityUtil playAnnouncement:NSLocalizedString(@"Accessability_announcementUpdated", nil) after:3.0f];
    }

    else if (fromState == EPTextbookStateTypeNormal && toState == EPTextbookStateTypeToDownload) {
        
        self.buttonsView.downloadButton.hidden = NO;
        self.buttonsView.updateButton.hidden = YES;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = NO;
        self.buttonsView.readButton.enabled = NO;
        self.buttonsView.bookmarksButton.enabled = NO;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 0.0f;
        self.markImageView.hidden = YES;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateToDownload", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];
    }

    else if (fromState == EPTextbookStateTypeToUpdate && toState == EPTextbookStateTypeToDownload) {
        
        self.buttonsView.downloadButton.hidden = NO;
        self.buttonsView.updateButton.hidden = YES;
        self.buttonsView.stopButton.hidden = YES;
        
        self.buttonsView.deleteButton.enabled = NO;
        self.buttonsView.readButton.enabled = NO;
        self.buttonsView.bookmarksButton.enabled = NO;
        self.buttonsView.updateButton.enabled = YES;
        
        [self.buttonsView setProgressVisible:NO animated:YES];
        self.coverImageView.progress = 0.0f;
        self.markImageView.hidden = YES;
        [self setTextviewAsDimmed:NO];
        self.coverImageView.accessibilityLabel = NSLocalizedString(@"Accessability_stateToDownload", nil);
        
        [[EPConfiguration activeConfiguration].accessibilityUtil focusOnView:self.coverImageView];

        [self downloadTextbookProxy:self.proxy reloadMetadataToContentID:nil];
    }
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateProgressToValue:(float)progress {

    if (ABS(progress - self.coverImageView.progress) > 0.005f || progress == 0.0f || progress == 1.0f) {
        self.coverImageView.progress = progress;
        [self.buttonsView.progressCircleSmallView setNumericProgress:progress];
    }
}

- (void)willBeginExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {
    
    self.buttonsView.stopButton.enabled = NO;
    [self.buttonsView.progressCircleSmallView setFillProgress:-1.0f];
    self.coverImageView.progress = 1.0f;
}

- (void)didFinishExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy {
    
    [self.buttonsView.progressCircleSmallView setFillProgress:1.0f];
    self.coverImageView.progress = 1.0f;
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateUnpackingProgressToValue:(float)progress {
    [self.buttonsView.progressCircleSmallView setFillProgress:progress];
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didRaiseError:(NSError *)error {

    
    [[EPConfiguration activeConfiguration].windowsUtil showTextbookDownloadError:error];
}

- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy reloadMetadataToContentID:(NSString *)contentID {

    EPTextbookModel *textbookModel = EPConfiguration.activeConfiguration.textbookModel;
    EPMetadata *metadata = [textbookModel metadataWithRootID:self.textbookRootID];
    EPCollection *collection = [textbookModel collectionWithContentID:metadata.actualContentID];
    
#if DEBUG_OBJECTS
    [collection printMe];
#endif

    [self loadCoverFromCollection:collection];

    [self loadDetailsFromCollection:collection];
}

@end
