







#import <Foundation/Foundation.h>

@interface EPActionSheetHandler : NSObject <UIActionSheetDelegate>

@property (nonatomic) NSString *title;

- (void)addButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock;
- (void)addDestructiveButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock;
- (void)addCancelButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock;
- (void)addDismissBlock:(void (^)(void))actionBlock;

@end

@interface EPActionSheetHandler (Displaying)

- (void)showInView:(UIView *)view;
- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;

@end
