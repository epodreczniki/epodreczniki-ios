







#import "EPAlertViewHandler.h"

@interface EPAlertViewHandler ()

@property (nonatomic, strong) NSMutableArray *actionBlocks;
@property (nonatomic, copy) void (^dismissBlock)(void);
@property (nonatomic, strong) EPAlertViewHandler *handler;

@end

@implementation EPAlertViewHandler

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.alertView = [UIAlertView new];
        self.alertView.delegate = self;
        self.actionBlocks = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc {
    self.alertView = nil;
    [self.actionBlocks removeAllObjects];
    self.actionBlocks = nil;
    self.dismissBlock = nil;
}

#pragma mark - Public properties

- (NSString *)title {
    return self.alertView.title;
}

- (void)setTitle:(NSString *)title {
    self.alertView.title = title;
}

- (NSString *)message {
    return self.alertView.message;
}

- (void)setMessage:(NSString *)message {
    self.alertView.message = message;
}

- (UIAlertViewStyle)style {
    return self.alertView.alertViewStyle;
}

- (void)setStyle:(UIAlertViewStyle)style {
    self.alertView.alertViewStyle = style;
}

#pragma mark - Public methods

- (void)addButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock {
    NSAssert(title, @"Title cannot be nil");
    
    [self.alertView addButtonWithTitle:title];
    if (actionBlock) {
        [self.actionBlocks addObject:actionBlock];
    }
    else {
        [self.actionBlocks addObject:^{}];
    }
}

- (void)addCancelButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock {
    NSAssert(title, @"Title cannot be nil");
    
    [self.alertView addButtonWithTitle:title];
    self.alertView.cancelButtonIndex = self.alertView.numberOfButtons - 1;
    if (actionBlock) {
        [self.actionBlocks addObject:actionBlock];
    }
    else {
        [self.actionBlocks addObject:^{}];
    }
}

- (void)addDismissBlock:(void (^)(void))actionBlock {
    if (actionBlock) {
        self.dismissBlock = actionBlock;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex >= 0) {

        void (^actionBlock)(void) = self.actionBlocks[buttonIndex];
        actionBlock();
    }

    if (self.dismissBlock) {
        self.dismissBlock();
    }

    self.handler = nil;
}

@end

@implementation EPAlertViewHandler (Displaying)

- (void)show {
    [self.alertView show];
    self.handler = self;
}

@end
