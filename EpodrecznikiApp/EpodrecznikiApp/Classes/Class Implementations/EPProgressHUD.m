







#import "EPProgressHUD.h"

@implementation EPProgressHUD

- (void)dealloc {

}

- (void)showOkIcon {
    
    UIImage *image = [UIImage imageNamed:@"IconMsgOk"];
    image = [image imageWithColor:[UIColor whiteColor]];
    self.customView = [[UIImageView alloc] initWithImage:image];
    self.mode = MBProgressHUDModeCustomView;
}

- (void)showErrorIcon {
    
    UIImage *image = [UIImage imageNamed:@"IconMsgError"];
    image = [image imageWithColor:[UIColor whiteColor]];
    self.customView = [[UIImageView alloc] initWithImage:image];
    self.mode = MBProgressHUDModeCustomView;
}

- (void)addCloseHandler {
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeHud:)];
    [self addGestureRecognizer:gesture];
}

- (void)closeHud:(UITapGestureRecognizer *)recognizer {
    [self hide:YES];
    [self removeGestureRecognizer:recognizer];
}

@end
