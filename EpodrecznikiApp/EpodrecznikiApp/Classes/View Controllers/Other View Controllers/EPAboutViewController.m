







#import "EPAboutViewController.h"

@implementation EPAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"EPAboutViewController_navigationBarTitle", nil);
    self.aboutTextView.text = [NSString stringWithFormat:NSLocalizedString(@"EPAboutViewController_aboutTextView", nil),
        [EPConfiguration activeConfiguration].settingsModel.appVersion
    ];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.aboutTextView setContentOffset:CGPointMake(0, -self.aboutTextView.scrollIndicatorInsets.top) animated:NO];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
