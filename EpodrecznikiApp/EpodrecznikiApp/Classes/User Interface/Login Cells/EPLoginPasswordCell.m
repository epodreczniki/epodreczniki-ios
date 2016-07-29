







#import "EPLoginPasswordCell.h"

@implementation EPLoginPasswordCell

- (void)awakeFromNib {
    self.passwordTextField.placeholder = NSLocalizedString(@"EPLoginPasswordCell_passwordTextFieldPlaceholder", nil);
}

- (void)prepareForReuse {
    self.delegate = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.text = @"";
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangePassword:inCell:)]) {
        [self.delegate didChangePassword:@"" inCell:self];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangePassword:inCell:)]) {
        [self.delegate didChangePassword:password inCell:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Public methods

- (void)dismissKeyboard {
    [self.passwordTextField resignFirstResponder];
}

@end
