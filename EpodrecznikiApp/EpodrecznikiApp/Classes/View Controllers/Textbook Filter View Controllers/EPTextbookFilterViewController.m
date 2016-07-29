







#import "EPTextbookFilterViewController.h"

typedef NS_ENUM(NSInteger, EPTextbookFilterViewControllerSections) {
    EPTextbookFilterViewControllerSectionsNoFilter                  = 0,
    EPTextbookFilterViewControllerSectionsHeaderEducationLevel      = 1,
    EPTextbookFilterViewControllerSectionsContentEducationLevel     = 2,
    EPTextbookFilterViewControllerSectionsHeaderSubject             = 3,
    EPTextbookFilterViewControllerSectionsContentSubject            = 4
};

@interface EPTextbookFilterViewController ()

@property (nonatomic, strong) NSArray *arrayOfEducationLevels;
@property (nonatomic, strong) NSArray *arrayOfSubjects;
@property (nonatomic, strong) EPFilter *filter;

@end

@implementation EPTextbookFilterViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"EPTextbookFilterViewController_navigationBarTitle", nil);
    
    EPFilterModel *filterModel = [EPConfiguration activeConfiguration].filterModel;
    self.arrayOfEducationLevels = filterModel.arrayOfSchools;
    self.arrayOfSubjects = filterModel.arrayOfSubjects;
    self.filter = [EPConfiguration activeConfiguration].settingsModel.activeFilter;

    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)dealloc {
    self.arrayOfEducationLevels = nil;
    self.arrayOfSubjects = nil;
    self.filter = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;


}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == EPTextbookFilterViewControllerSectionsNoFilter) {
        return 1;
    }
    if (section == EPTextbookFilterViewControllerSectionsHeaderEducationLevel) {
        return 1;
    }
    if (section == EPTextbookFilterViewControllerSectionsContentEducationLevel) {
        return self.arrayOfEducationLevels.count;
    }
    if (section == EPTextbookFilterViewControllerSectionsHeaderSubject) {
        return 1;
    }
    if (section == EPTextbookFilterViewControllerSectionsContentSubject) {
        return self.arrayOfSubjects.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == EPTextbookFilterViewControllerSectionsNoFilter) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoFilterCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = NSLocalizedString(@"EPTextbookFilterViewController_cellTitleNoFilter", nil);;
        
        if (self.filter.filterType == EPFilterTypeNone || self.filter.filterType == EPFilterTypeNotSet) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    if (indexPath.section == EPTextbookFilterViewControllerSectionsHeaderEducationLevel) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilterByCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = NSLocalizedString(@"EPTextbookFilterViewController_cellTitleFilterByEducationLevel", nil);;
    }
    if (indexPath.section == EPTextbookFilterViewControllerSectionsContentEducationLevel) {
        EPSchool *school = self.arrayOfEducationLevels[indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"ClassCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = school.schoolName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Klasa %@", school.schoolClassLevel];
        
        if (self.filter.filterType == EPFilterTypeByEducationLevel) {
            EPSchoolBasic *filterSchool = [[EPSchoolBasic alloc] initWithString:self.filter.filterValue];
            if ([filterSchool.schoolEducationLevel isEqualToString:school.schoolEducationLevel] &&
                [filterSchool.schoolClassLevel isEqualToString:school.schoolClassLevel]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    if (indexPath.section == EPTextbookFilterViewControllerSectionsHeaderSubject) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilterByCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = NSLocalizedString(@"EPTextbookFilterViewController_cellTitleFilterBySubject", nil);;
    }
    if (indexPath.section == EPTextbookFilterViewControllerSectionsContentSubject) {
        EPSubject *subject = self.arrayOfSubjects[indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = subject.subjectName;
        
        if (self.filter.filterType == EPFilterTypeBySubject && [self.filter.filterValue isEqualToString:subject.subjectID]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == EPTextbookFilterViewControllerSectionsNoFilter) {
        
        self.filter.filterType = EPFilterTypeNone;
        self.filter.filterValue = nil;
        [EPConfiguration activeConfiguration].settingsModel.activeFilter = self.filter;
        
        [tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTextbooksListFilterChangedNotification object:nil];
    }
    else if (indexPath.section == EPTextbookFilterViewControllerSectionsContentEducationLevel) {
        EPSchool *school = self.arrayOfEducationLevels[indexPath.row];
        
        self.filter.filterType = EPFilterTypeByEducationLevel;
        self.filter.filterValue = [school stringFromSchoolBasic];
        [EPConfiguration activeConfiguration].settingsModel.activeFilter = self.filter;
        
        [tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTextbooksListFilterChangedNotification object:nil];
    }
    else if (indexPath.section == EPTextbookFilterViewControllerSectionsContentSubject) {
        EPSubject *subject = self.arrayOfSubjects[indexPath.row];
        
        self.filter.filterType = EPFilterTypeBySubject;
        self.filter.filterValue = subject.subjectID;
        [EPConfiguration activeConfiguration].settingsModel.activeFilter = self.filter;
        
        [tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTextbooksListFilterChangedNotification object:nil];
    }
}

@end
