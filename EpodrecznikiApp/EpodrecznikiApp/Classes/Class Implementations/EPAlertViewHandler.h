







#import <Foundation/Foundation.h>

@interface EPAlertViewHandler : NSObject <UIAlertViewDelegate>

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
@property (nonatomic, strong) UIAlertView *alertView;

- (void)addButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock;
- (void)addCancelButtonWithTitle:(NSString *)title andActionBlock:(void (^)(void))actionBlock;
- (void)addDismissBlock:(void (^)(void))actionBlock;

@end

@interface EPAlertViewHandler (Displaying)

- (void)show;

@end
