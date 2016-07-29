







#import "EPUserState.h"

@interface EPUserState ()

@property (nonatomic) BOOL askedForPermissionToPlayVideoInThisSession;

@end

@implementation EPUserState

#pragma mark - Lifecycle

- (instancetype)initWithString:(NSString *)aState {
    self = [super init];
    if (self) {
        if (!aState) {
            aState = [EPUserState defaultUserStateString];
        }
        _state = [NSMutableString stringWithString:aState];
    }
    return self;
}

- (void)dealloc {
    _state = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:
        @"EPUserState (\n\tstate: %@,\n\tEPSettingsCanDownloadAndRemoveTextbooksType: %ld,\n\tEPSettingsCanLoginWithoutPasswordType: %ld,\n\tEPSettingsTextbookVariantType: %ld,\n\tEPSettingsVideoPlayerPlaybackType: %ld,\n\tEPSettingsTextbooksListContainerType: %ld,\n\tEPSettingsNavigationButtonsVisibilityType: %ld\n)",
        _state,
        (long)self.canDownloadAndRemoveTextbooksType,
        (long)self.canLoginWithoutPasswordType,
        (long)self.textbookVariantType,
        (long)self.videoPlayerPlaybackType,
        (long)self.textbooksListContainerType,
        (long)self.navigationButtonsVisibilityType
    ];
}

#pragma mark - Public properties

- (EPSettingsCanDownloadAndRemoveTextbooksType)canDownloadAndRemoveTextbooksType {
    NSRange range = NSMakeRange([self indexForEPSettingsCanDownloadAndRemoveTextbooksType], 1);
    NSString *sValue = [_state substringWithRange:range];
    return [sValue intValue];
}

- (void)setCanDownloadAndRemoveTextbooksType:(EPSettingsCanDownloadAndRemoveTextbooksType)canDownloadAndRemoveTextbooksType {
    NSRange range = NSMakeRange([self indexForEPSettingsCanDownloadAndRemoveTextbooksType], 1);
    NSString *sValue = [NSString stringWithFormat:@"%ld", (long)canDownloadAndRemoveTextbooksType];
    [_state replaceCharactersInRange:range withString:sValue];
}

- (EPSettingsCanLoginWithoutPasswordType)canLoginWithoutPasswordType {
    NSRange range = NSMakeRange([self indexForEPSettingsCanLoginWithoutPasswordType], 1);
    NSString *sValue = [_state substringWithRange:range];
    return [sValue intValue];
}

- (void)setCanLoginWithoutPasswordType:(EPSettingsCanLoginWithoutPasswordType)canLoginWithoutPasswordType {
    NSRange range = NSMakeRange([self indexForEPSettingsCanLoginWithoutPasswordType], 1);
    NSString *sValue = [NSString stringWithFormat:@"%ld", (long)canLoginWithoutPasswordType];
    [_state replaceCharactersInRange:range withString:sValue];
}

- (EPSettingsTextbookVariantType)textbookVariantType {
    NSRange range = NSMakeRange([self indexForEPSettingsTextbookVariantType], 1);
    NSString *sValue = [_state substringWithRange:range];
    return [sValue intValue];
}

- (void)setTextbookVariantType:(EPSettingsTextbookVariantType)textbookVariantType {
    NSRange range = NSMakeRange([self indexForEPSettingsTextbookVariantType], 1);
    NSString *sValue = [NSString stringWithFormat:@"%ld", (long)textbookVariantType];
    [_state replaceCharactersInRange:range withString:sValue];
}

- (EPSettingsVideoPlayerPlaybackType)videoPlayerPlaybackType {
    NSRange range = NSMakeRange([self indexForEPSettingsVideoPlayerPlaybackType], 1);
    NSString *sValue = [_state substringWithRange:range];
    return [sValue intValue];
}

- (void)setVideoPlayerPlaybackType:(EPSettingsVideoPlayerPlaybackType)videoPlayerPlaybackType {
    NSRange range = NSMakeRange([self indexForEPSettingsVideoPlayerPlaybackType], 1);
    NSString *sValue = [NSString stringWithFormat:@"%ld", (long)videoPlayerPlaybackType];
    [_state replaceCharactersInRange:range withString:sValue];
}

- (EPSettingsTextbooksListContainerType)textbooksListContainerType {
    NSRange range = NSMakeRange([self indexForEPSettingsTextbooksListContainerType], 1);
    NSString *sValue = [_state substringWithRange:range];
    return [sValue intValue];
}

- (void)setTextbooksListContainerType:(EPSettingsTextbooksListContainerType)textbooksListContainerType {
    NSRange range = NSMakeRange([self indexForEPSettingsTextbooksListContainerType], 1);
    NSString *sValue = [NSString stringWithFormat:@"%ld", (long)textbooksListContainerType];
    [_state replaceCharactersInRange:range withString:sValue];
}

- (EPSettingsNavigationButtonsVisibilityType)navigationButtonsVisibilityType {
    NSRange range = NSMakeRange([self indexForEPSettingsNavigationButtonsVisibilityType], 1);
    NSString *sValue = [_state substringWithRange:range];
    return [sValue intValue];
}

- (void)setNavigationButtonsVisibilityType:(EPSettingsNavigationButtonsVisibilityType)navigationButtonsVisibilityType {
    NSRange range = NSMakeRange([self indexForEPSettingsNavigationButtonsVisibilityType], 1);
    NSString *sValue = [NSString stringWithFormat:@"%ld", (long)navigationButtonsVisibilityType];
    [_state replaceCharactersInRange:range withString:sValue];
}

#pragma mark - Private methods

- (int)indexForEPSettingsCanDownloadAndRemoveTextbooksType {
    return 0;
}

- (int)indexForEPSettingsCanLoginWithoutPasswordType {
    return 1;
}

- (int)indexForEPSettingsTextbookVariantType {
    return 2;
}

- (int)indexForEPSettingsVideoPlayerPlaybackType {
    return 3;
}

- (int)indexForEPSettingsTextbooksListContainerType {
    return 4;
}

- (int)indexForEPSettingsNavigationButtonsVisibilityType {
    return 5;
}

#pragma mark - Public methods

- (NSString *)stateString {
    return [NSString stringWithFormat:@"%@", _state];
}

#pragma mark - Static methods

+ (EPUserState *)defaultUserState {
    return [[EPUserState alloc] initWithString:nil];
}

+ (NSString *)defaultUserStateString {
    
    EPSettingsTextbooksListContainerType containerType = EPSettingsTextbooksListContainerTypeUnknown;
    if ([UIDevice currentDevice].isIPad) {
        containerType = EPSettingsTextbooksListContainerTypeCollection;
    }
    else {
        containerType = EPSettingsTextbooksListContainerTypeCarousel;
    }
    
    return [NSString stringWithFormat:
        @"%ld%ld%ld%ld%ld"
        @"%ld%ld%ld%ld%ld"
        @"%ld%ld%ld%ld%ld"
        @"%ld%ld%ld%ld%ld",
        (long)EPSettingsCanDownloadAndRemoveTextbooksTypeDenied,
        (long)EPSettingsCanLoginWithoutPasswordTypeDenied,
        (long)EPSettingsTextbookVariantTypeStudent,
        (long)EPSettingsVideoPlayerPlaybackTypeAsk,
        (long)containerType,
        (long)EPSettingsNavigationButtonsVisibilityTypeHidden,
        0l, 0l, 0l, 0l,
        0l, 0l, 0l, 0l, 0l,
        0l, 0l, 0l, 0l, 0l
    ];
}

@end

@implementation EPUserState (Helper)

- (BOOL)canDownloadAndRemoveTextbooks {
    return (self.canDownloadAndRemoveTextbooksType == EPSettingsCanDownloadAndRemoveTextbooksTypeGranted);
}

- (BOOL)canLoginWithoutPassword {
    return (self.canLoginWithoutPasswordType == EPSettingsCanLoginWithoutPasswordTypeGranted);
}

- (BOOL)isTeacher {
    return (self.textbookVariantType == EPSettingsTextbookVariantTypeTeacher);
}

- (BOOL)shouldAskForPermissionToPlayVideo {
    EPSettingsVideoPlayerPlaybackType videoPlayerType = self.videoPlayerPlaybackType;
    
    if (videoPlayerType == EPSettingsVideoPlayerPlaybackTypeAsk) {

        if (self.askedForPermissionToPlayVideoInThisSession) {
            return NO;
        }
        
        return YES;
    }
    
    if (videoPlayerType == EPSettingsVideoPlayerPlaybackTypeAlways) {
        return NO;
    }
    
    return YES;
}

- (BOOL)areNavigationButtonsVisible {
    return (self.navigationButtonsVisibilityType == EPSettingsNavigationButtonsVisibilityTypeVisible);
}

- (void)setAskedForPermissionToPlayVideoInThisSession {
    self.askedForPermissionToPlayVideoInThisSession = YES;
}

@end
