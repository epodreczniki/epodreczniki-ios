







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

@protocol EPAccessibilityUtilDelegate <NSObject>

- (void)voiceOverStatusChanged:(BOOL)enabled;

@end

@interface EPAccessibilityUtil : EPConfigurableObject

@property (nonatomic, readonly, getter = isVoiceOverEnabled) BOOL voiceOverEnabled;
@property (nonatomic, assign) id <EPAccessibilityUtilDelegate> delegate;

- (void)removeFromDelegate:(id <EPAccessibilityUtilDelegate>)object;
- (void)playAnnouncement:(NSString *)announcement;
- (void)playAnnouncement:(NSString *)announcement after:(NSTimeInterval)time;
- (void)focusOnView:(UIView *)view;
- (void)postLayoutChangedOnView:(UIView *)view;

@end
