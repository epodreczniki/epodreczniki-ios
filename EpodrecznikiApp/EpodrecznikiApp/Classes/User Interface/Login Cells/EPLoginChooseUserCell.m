







#import "EPLoginChooseUserCell.h"

@interface EPLoginChooseUserCell ()

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *users;

@end

@implementation EPLoginChooseUserCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.chooseUserTextField.tintColor = [UIColor clearColor];
    self.chooseUserTextField.placeholder = NSLocalizedString(@"EPLoginChooseUserCell_chooseUserTextFieldPlaceholder", nil);

    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
                                     | UIViewAutoresizingFlexibleRightMargin;

    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EPLoginChooseUserCell_closeButtonTitle", nil)
        style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonAction)];
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.0f)];
    accessoryView.backgroundColor = [UIColor colorWithWhite:0.900 alpha:0.600];
    accessoryView.items = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        dismissButton
    ];

    UIView *inputView = [UIView new];
    inputView.frame = self.pickerView.frame;
    [inputView addSubview:self.pickerView];

    self.chooseUserTextField.inputView = inputView;
    self.chooseUserTextField.inputAccessoryView = accessoryView;
}

- (void)prepareForReuse {
    self.delegate = nil;
}

#pragma mark - Actions

- (void)dismissButtonAction {
    [self.chooseUserTextField resignFirstResponder];
}

#pragma mark - Public methods

- (void)reloadData {

    if (self.delegate && [self.delegate respondsToSelector:@selector(usersArrayForCell:)]) {
        self.users = [self.delegate usersArrayForCell:self];
        [self.pickerView reloadAllComponents];
    }

    self.chooseUserTextField.text = @"";
    self.selectedUser = nil;
    if (self.users.count > 0) {
        [self.pickerView selectRow:0 inComponent:0 animated:NO];
    }
}

- (void)dismissKeyboard {
    [self.chooseUserTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.userInteractionEnabled = NO;
    if (self.users.count > 0 && !self.selectedUser) {
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
    }
    return YES;
}

- (BOOL)z_textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.userInteractionEnabled = YES;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.users.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    EPUser *user = self.users[row];
    return user.login;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    self.selectedUser = self.users[row];

    self.chooseUserTextField.text = self.selectedUser.login;

    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectUser:inCell:)]) {
        [self.delegate didSelectUser:self.selectedUser inCell:self];
    }
}

@end
