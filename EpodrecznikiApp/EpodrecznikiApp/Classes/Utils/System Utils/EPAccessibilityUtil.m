







#import "EPAccessibilityUtil.h"

@implementation EPAccessibilityUtil

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceOverStatusChangedNotification) name:UIAccessibilityVoiceOverStatusChanged object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public properties

- (BOOL)isVoiceOverEnabled {
    return UIAccessibilityIsVoiceOverRunning();
}

#pragma mark - Public methods

- (void)removeFromDelegate:(id <EPAccessibilityUtilDelegate>)object {
    if (self.delegate == object) {
        self.delegate = nil;
    }
}

- (void)playAnnouncement:(NSString *)announcement {
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement);
}

- (void)playAnnouncement:(NSString *)announcement after:(NSTimeInterval)time {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playAnnouncement:announcement];
    });
}

- (void)focusOnView:(UIView *)view {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, view);
}

- (void)postLayoutChangedOnView:(UIView *)view {
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, view);
}

#pragma mark - Notifications

- (void)voiceOverStatusChangedNotification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceOverStatusChanged:)]) {
        [self.delegate voiceOverStatusChanged:self.isVoiceOverEnabled];
    }
}

@end
