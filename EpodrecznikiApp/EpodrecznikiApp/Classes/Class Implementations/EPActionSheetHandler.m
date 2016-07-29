







#import "EPActionSheetHandler.h"

@interface EPActionSheetHandler ()

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) NSMutableArray *actionBlocks;
@property (nonatomic, copy) void (^dismissBlock)(void);
@property (nonatomic, strong) EPActionSheetHandler *handler;

@end

@implementation EPActionSheetHandler

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.actionSheet = [UIActionSheet new];
        self.actionSheet.delegate = self;
        self.actionBlocks = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc {
    self.actionSheet = nil;
    [self.actionBlocks removeAllObjects];
    self.actionBlocks = nil;
}

#pragma mark - Public properties

- (NSString *)title {
    return self.actionSheet.title;
}

- (void)setTitle:(NSString *)title {
    self.actionSheet.title = title;
}

#pragma mark - Public methods

- (void)addButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock {
    NSAssert(title, @"Title cannot be nil");
    
    [self.actionSheet addButtonWithTitle:title];
    if (actionBlock) {
        [self.actionBlocks addObject:actionBlock];
    }
    else {
        [self.actionBlocks addObject:^{}];
    }
}

- (void)addDestructiveButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock {
    NSAssert(title, @"Title cannot be nil");
    
    [self.actionSheet addButtonWithTitle:title];
    self.actionSheet.destructiveButtonIndex = self.actionSheet.numberOfButtons - 1;
    if (actionBlock) {
        [self.actionBlocks addObject:actionBlock];
    }
    else {
        [self.actionBlocks addObject:^{}];
    }
}

- (void)addCancelButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock {
    NSAssert(title, @"Title cannot be nil");
    
    [self.actionSheet addButtonWithTitle:title];
    self.actionSheet.cancelButtonIndex = self.actionSheet.numberOfButtons - 1;
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

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

@implementation EPActionSheetHandler (Displaying)

- (void)showInView:(UIView *)view {
    NSAssert(view, @"View cannot be nil");
    
    [self.actionSheet showInView:view];
    self.handler = self;
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    NSAssert(item, @"Item cannot be nil");
    
    [self.actionSheet showFromBarButtonItem:item animated:animated];
    self.handler = self;
}

@end
