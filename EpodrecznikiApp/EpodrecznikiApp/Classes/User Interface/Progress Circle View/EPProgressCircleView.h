







#import <UIKit/UIKit.h>
#import "EPInsetLabel.h"

@interface EPProgressCircleView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet EPInsetLabel *progressLabel;
@property (nonatomic, weak) IBOutlet UILabel *percentageLabel;

- (void)setNumericProgress:(float)numericProgress;
- (void)setFillProgress:(float)numericProgress;

@end
