







#import <Foundation/Foundation.h>

@interface EPUserState : NSObject {
    NSMutableString *_state;
}


@property (nonatomic) EPSettingsCanDownloadAndRemoveTextbooksType canDownloadAndRemoveTextbooksType;
@property (nonatomic) EPSettingsCanLoginWithoutPasswordType canLoginWithoutPasswordType;
@property (nonatomic) EPSettingsTextbookVariantType textbookVariantType;
@property (nonatomic) EPSettingsVideoPlayerPlaybackType videoPlayerPlaybackType;
@property (nonatomic) EPSettingsTextbooksListContainerType textbooksListContainerType;
@property (nonatomic) EPSettingsNavigationButtonsVisibilityType navigationButtonsVisibilityType;


- (instancetype)initWithString:(NSString *)state;
- (NSString *)stateString;


+ (EPUserState *)defaultUserState;
+ (NSString *)defaultUserStateString;

@end

@interface EPUserState (Helper)

@property (nonatomic, readonly) BOOL canDownloadAndRemoveTextbooks;
@property (nonatomic, readonly) BOOL canLoginWithoutPassword;
@property (nonatomic, readonly) BOOL isTeacher;
@property (nonatomic, readonly) BOOL shouldAskForPermissionToPlayVideo;
@property (nonatomic, readonly) BOOL areNavigationButtonsVisible;

- (void)setAskedForPermissionToPlayVideoInThisSession;

@end
