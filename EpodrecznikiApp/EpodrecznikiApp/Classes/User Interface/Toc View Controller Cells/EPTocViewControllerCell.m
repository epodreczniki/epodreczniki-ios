







#import "EPTocViewControllerCell.h"

@implementation EPTocViewControllerCell

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorView.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:199.0f/255.0f blue:204.0f/255.0f alpha:1.0f].CGColor;
    self.separatorView.layer.borderWidth = 0.5f;
    
    UIView *topSeparatorView = [UIView new];
    topSeparatorView.frame = CGRectMake(0, 0, self.frame.size.width, 0.5f);
    topSeparatorView.layer.borderWidth = 0.5f;
    topSeparatorView.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:199.0f/255.0f blue:204.0f/255.0f alpha:1.0f].CGColor;
    [self.contentView addSubview:topSeparatorView];
    self.topSeparatorView = topSeparatorView;
    
    if (self.leftButton) {
        
        UIImage *image = [[self.leftButton imageForState:UIControlStateNormal] imageWithColor:self.tintColor];
        UIImage *imageHigh = [[self.leftButton imageForState:UIControlStateNormal] imageWithColor:[UIColor lightGrayColor]];
        
        [self.leftButton setImage:image forState:UIControlStateNormal];
        [self.leftButton setImage:imageHigh forState:UIControlStateHighlighted];
    }
    
    if (self.rightButton) {
        
        UIImage *image = [[self.rightButton imageForState:UIControlStateNormal] imageWithColor:self.tintColor];
        UIImage *imageHigh = [[self.rightButton imageForState:UIControlStateNormal] imageWithColor:[UIColor lightGrayColor]];
        
        [self.rightButton setImage:image forState:UIControlStateNormal];
        [self.rightButton setImage:imageHigh forState:UIControlStateHighlighted];
    }
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat cellHeight = self.frame.size.height;
    CGFloat cellWidth = self.frame.size.width;
    CGFloat margin = 5.0f;

    if (cellHeight < 1.0f) {
        
        self.leftButton.hidden = YES;
        self.rightButton.hidden = YES;
        self.tocTitleLabel.hidden = YES;
        self.separatorView.hidden = YES;
        
        return;
    }

    self.leftButton.hidden = NO;
    self.rightButton.hidden = NO;
    self.tocTitleLabel.hidden = NO;
    self.separatorView.hidden = NO;
    
    if (self.cellType == EPTocViewControllerCellLeft) {
        
        CGRect buttonFrame = self.leftButton.frame;
        CGRect labelFrame = self.tocTitleLabel.frame;
        CGRect separatorFrame = self.separatorView.frame;

        buttonFrame.size.width = 35.0f;
        buttonFrame.size.height = cellHeight;
        buttonFrame.origin.y = 0;
        buttonFrame.origin.x = 0;

        labelFrame.origin.y = margin;
        labelFrame.origin.x = buttonFrame.origin.x + buttonFrame.size.width + margin + (margin / 2.0f);
        labelFrame.size.height = cellHeight - 2 * margin;
        labelFrame.size.width = cellWidth - labelFrame.origin.x - 2 * margin;

        separatorFrame.size.height = cellHeight - 2 * margin;
        separatorFrame.size.width = 0.5f;
        separatorFrame.origin.y = margin;
        separatorFrame.origin.x = buttonFrame.origin.x + buttonFrame.size.width + (margin / 2.0f);
        
        self.leftButton.frame = buttonFrame;
        self.tocTitleLabel.frame = labelFrame;
        self.separatorView.frame = separatorFrame;
    }
    else if (self.cellType == EPTocViewControllerCellRight) {
        
        CGRect buttonFrame = self.rightButton.frame;
        CGRect labelFrame = self.tocTitleLabel.frame;
        CGRect separatorFrame = self.separatorView.frame;

        buttonFrame.size.width = 35.0f;
        buttonFrame.size.height = cellHeight;
        buttonFrame.origin.y = 0;
        buttonFrame.origin.x = cellWidth - buttonFrame.size.width;

        labelFrame.origin.y = margin;
        labelFrame.origin.x = 2 * margin;
        labelFrame.size.height = cellHeight - 2 * margin;
        labelFrame.size.width = cellWidth - buttonFrame.size.width - 4 * margin - margin;

        separatorFrame.size.height = cellHeight - 2 * margin;
        separatorFrame.size.width = 0.5f;
        separatorFrame.origin.y = margin;
        separatorFrame.origin.x = buttonFrame.origin.x - (margin / 2.0f);
        
        self.rightButton.frame = buttonFrame;
        self.tocTitleLabel.frame = labelFrame;
        self.separatorView.frame = separatorFrame;
    }
    else if (self.cellType == EPTocViewControllerCellNone) {
        
        CGRect labelFrame = self.tocTitleLabel.frame;

        labelFrame.origin.x = 2 * margin;
        labelFrame.origin.y = margin;
        labelFrame.size.width = cellWidth - 4 * margin;
        labelFrame.size.height = cellHeight - 2 * margin;
        
        self.tocTitleLabel.frame = labelFrame;
    }

    self.topSeparatorView.frame = CGRectMake(0, 0, self.frame.size.width, 0.5f);
}

#pragma mark - Actions

- (IBAction)leftButtonAction {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tocViewControllerCell:didSelectLeftButtonForIndex:)]) {
        [self.delegate tocViewControllerCell:self didSelectLeftButtonForIndex:self.tag];
    }
}

- (IBAction)rightButtonAction {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tocViewControllerCell:didSelectRightButtonForIndex:)]) {
        [self.delegate tocViewControllerCell:self didSelectRightButtonForIndex:self.tag];
    }
}

@end
