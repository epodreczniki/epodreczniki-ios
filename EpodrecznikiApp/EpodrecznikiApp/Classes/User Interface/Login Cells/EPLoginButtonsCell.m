







#import "EPLoginButtonsCell.h"

@implementation EPLoginButtonsCell

- (void)awakeFromNib {
    
    [self.loginButton setTitle:NSLocalizedString(@"EPLoginButtonsCell_loginButtonTitle", nil) forState:UIControlStateNormal];
    [self.recoverPasswordButton setTitle:NSLocalizedString(@"EPLoginButtonsCell_recoverPasswordButtonTitle", nil) forState:UIControlStateNormal];
    [self.createAccountButton setTitle:NSLocalizedString(@"EPLoginButtonsCell_createAccountButtonTitle", nil) forState:UIControlStateNormal];
}

#pragma mark - Actions

- (IBAction)loginButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLoginButtonInCell:)]) {
        [self.delegate didTapLoginButtonInCell:self];
    }
}

- (IBAction)recoverPasswordButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapRecoverPasswordButtonInCell:)]) {
        [self.delegate didTapRecoverPasswordButtonInCell:self];
    }
}

- (IBAction)createAccountButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapCreateAccountButtonInCell:)]) {
        [self.delegate didTapCreateAccountButtonInCell:self];
    }
}

@end
