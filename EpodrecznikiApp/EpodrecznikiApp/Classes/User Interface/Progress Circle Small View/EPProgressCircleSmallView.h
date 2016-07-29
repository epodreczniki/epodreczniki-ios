







#import <UIKit/UIKit.h>
#import "EPInsetLabel.h"

@interface EPProgressCircleSmallView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet EPInsetLabel *progressLabel;

- (void)setNumericProgress:(float)numericProgress;
- (void)setFillProgress:(float)numericProgress;

@end
