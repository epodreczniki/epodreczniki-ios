







#import "EPPrivacyPolicyViewController.h"
#import "EPAlertViewHandler.h"

@implementation EPPrivacyPolicyViewController

#pragma mark - Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

        self.isFirstViewController = YES;
        self.isPolicyAccepted = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"EPPrivacyPolicyViewController_navigationBarTitle", nil);
    self.policyTextView.text = NSLocalizedString(@"EPPrivacyPolicyViewController_policyTextView", nil);
    self.acceptButton.title = NSLocalizedString(@"EPPrivacyPolicyViewController_acceptButtonTitle", nil);
    self.acceptButton.enabled = NO;
    self.navigationController.navigationBar.tintColor = [UIColor epBlueColor];
    self.acceptButton.tintColor = [UIColor epBlueColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.isPolicyAccepted = [EPConfiguration activeConfiguration].settingsModel.userAcceptedPolicy;

    if (self.isFirstViewController && self.isPolicyAccepted) {
        self.navigationController.view.hidden = YES;
    }

    if ([EPConfiguration activeConfiguration].accessibilityUtil.isVoiceOverEnabled) {
        [self voiceOverStatusChanged:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.policyTextView setContentOffset:CGPointMake(0, -self.policyTextView.scrollIndicatorInsets.top) animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.isFirstViewController && self.isPolicyAccepted) {

        [self performSegueWithIdentifier:@"EPLoginUserViewControllerSegue" sender:nil];
    }

    [self scrollViewDidScroll:self.policyTextView];

    [EPConfiguration activeConfiguration].accessibilityUtil.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.isFirstViewController && self.isPolicyAccepted) {
        self.navigationController.view.hidden = NO;
    }
}

- (void)dealloc {
    self.policyTextView.delegate = nil;
    self.policyTextView = nil;
    [[EPConfiguration activeConfiguration].accessibilityUtil removeFromDelegate:self];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Actions

- (IBAction)acceptButtonAction:(id)sender {


    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPPrivacyPolicyViewController_acceptAlertViewTitle", nil);
    handler.message = NSLocalizedString(@"EPPrivacyPolicyViewController_acceptAlertViewMessage", nil);
    [handler addButtonWithTitle:NSLocalizedString(@"EPPrivacyPolicyViewController_acceptAlertViewButtonYes", nil) andActionBlock:^{

        EPConfiguration *configuration = [EPConfiguration activeConfiguration];
        configuration.settingsModel.userAcceptedPolicy = YES;

        [self performSegueWithIdentifier:@"EPLoginUserViewControllerSegue" sender:nil];
    }];
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPPrivacyPolicyViewController_acceptAlertViewButtonNo", nil) andActionBlock:nil];
    [handler show];
}

#pragma mark - Private methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollViewHeight = self.policyTextView.bounds.size.height;
    CGFloat scrollContentSizeHeight = self.policyTextView.contentSize.height;
    CGFloat bottomInset = self.policyTextView.contentInset.bottom;
    CGFloat scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight;
    if (self.policyTextView.contentOffset.y >= scrollViewBottomOffset) {
        self.acceptButton.enabled = YES;
    }
}

#pragma mark - EPAccessibilityUtilDelegate

- (void)voiceOverStatusChanged:(BOOL)enabled {
    if (enabled) {
        self.acceptButton.enabled = YES;
    }
}

@end
