







#import "EPAdminSettingsViewController.h"
#import "EPUserCreateViewController.h"
#import "EPUserDetailsViewController.h"
#import "EPBackButtonItem.h"

@interface EPAdminSettingsViewController ()

@property (nonatomic) BOOL shouldCreateAdmin;
@property (nonatomic, strong) EPUser *selectedUser;
@property (nonatomic, strong) NSArray *arrayOfUsers;
@property (nonatomic, strong) UIColor *separatorColor;

@end

@implementation EPAdminSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"EPAdminSettingsViewController_navigationBarTitle", nil);
    self.cancelButton.title = NSLocalizedString(@"EPAdminSettingsViewController_cancelButtonTitle", nil);
    self.separatorColor = self.tableView.separatorColor;
    self.navigationItem.backBarButtonItem = [EPBackButtonItem new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self fillUsersList];

    self.selectedUser = nil;
    self.shouldCreateAdmin = NO;
}

- (void)dealloc {
    self.selectedUser = nil;
    self.arrayOfUsers = nil;
    self.separatorColor = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EPUserDetailsViewControllerSegue"]) {
        EPUserDetailsViewController *vc = segue.destinationViewController;
        vc.editedUser = self.selectedUser;
    }
    else if ([segue.identifier isEqualToString:@"EPUserCreateViewControllerSegue"]) {
        EPUserCreateViewController *vc = segue.destinationViewController;
        vc.isCreatingAnAdminAccount = self.shouldCreateAdmin;
        vc.shouldDismissViewController = NO;
        vc.editedUser = self.selectedUser;
    }
    else if ([segue.identifier isEqualToString:@"EPAdminStaticSettingsViewControllerSegue"]) {
        EPAdminStaticSettingsViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark - Private methods

- (void)fillUsersList {
    
    EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
    if (state == EPAppStateAnonymousAccount) {
        self.arrayOfUsers = @[];
        self.tableView.separatorColor = [UIColor clearColor];
    }
    else {
        self.arrayOfUsers = [[EPConfiguration activeConfiguration].userModel allUsersByName];
        self.tableView.separatorColor = self.separatorColor;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    EPUser *user = self.arrayOfUsers[indexPath.row];
    if (user.role == EPAccountRoleAdmin) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    cell.textLabel.text = user.login;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    EPAppState state = [EPConfiguration activeConfiguration].userUtil.appState;
    if (state == EPAppStateAnonymousAccount) {
        return nil;
    }
    return NSLocalizedString(@"EPAdminSettingsViewController_sectionUsers", nil);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedUser = self.arrayOfUsers[indexPath.row];
    self.shouldCreateAdmin = NO;
    
    if (self.selectedUser.role == EPAccountRoleAdmin) {
        [self performSegueWithIdentifier:@"EPUserCreateViewControllerSegue" sender:nil];
    }
    else {
        [self performSegueWithIdentifier:@"EPUserDetailsViewControllerSegue" sender:nil];
    }
}

#pragma mark - Actions

- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EPAdminStaticSettingsViewControllerDelegate

- (void)didSelectCreateAdminAccountInViewController:(EPAdminStaticSettingsViewController *)viewController {
    
    self.shouldCreateAdmin = YES;
    self.selectedUser = nil;
    [self performSegueWithIdentifier:@"EPUserCreateViewControllerSegue" sender:nil];
}

- (void)didSelectCreateUserAccountInViewController:(EPAdminStaticSettingsViewController *)viewController {
    
    self.shouldCreateAdmin = NO;
    self.selectedUser = nil;
    [self performSegueWithIdentifier:@"EPUserCreateViewControllerSegue" sender:nil];
}

@end
