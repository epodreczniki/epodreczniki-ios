







#import "EPTextbookDrawerViewController.h"

@implementation EPTextbookDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if MODE_DEVELOPER
    self.textbookRootID = @"123";
#endif

    self.animationVelocity = 2 * 840.0f;
    [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    
    if ([UIDevice currentDevice].isIPad) {
        [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView
                                          | MMCloseDrawerGestureModePanningNavigationBar
                                          | MMCloseDrawerGestureModeTapCenterView
                                          | MMCloseDrawerGestureModeTapNavigationBar];
    }
    else {
        [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningCenterView
                                          | MMCloseDrawerGestureModePanningNavigationBar];
    }
    
    [self setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        MMDrawerControllerDrawerVisualStateBlock block;
        block = [[MMExampleDrawerVisualStateManager sharedManager] drawerVisualStateBlockForDrawerSide:drawerSide];
        if (block) {
            block(drawerController, drawerSide, percentVisible);
        }
    }];
    [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeNone];
    [[MMExampleDrawerVisualStateManager sharedManager] setRightDrawerAnimationType:MMDrawerAnimationTypeNone];

    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.isBeingPresented) {

        [[EPConfiguration activeConfiguration].tocUtil loadTocForTextbookRootID:self.textbookRootID];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.isBeingDismissed) {

        [[EPConfiguration activeConfiguration].tocUtil unloadToc];

        [[NSNotificationCenter defaultCenter] postNotificationName:kTextbookReaderClearWebviewPointerNotification object:nil];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];


}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if ([UIDevice currentDevice].isIPad) {
        
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            CGFloat width = [UIScreen mainScreen].portraitScreenSize.width / 2.0f;
            [self setMaximumLeftDrawerWidth:width];
        }
        else {
            CGFloat width = [UIScreen mainScreen].landscapeScreenSize.width / 2.0f;
            [self setMaximumLeftDrawerWidth:width];
        }
    }
    else {
        
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            CGFloat width = [UIScreen mainScreen].portraitScreenSize.width - 20.0f;
            [self setMaximumLeftDrawerWidth:width];
        }
        else {
            CGFloat width = [UIScreen mainScreen].landscapeScreenSize.width - 20.0f;
            [self setMaximumLeftDrawerWidth:width];
        }
    }
}

@end
