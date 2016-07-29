







#import <Foundation/Foundation.h>

typedef void (^EPCanAccessAdminSettingsBlock_t)(void);
typedef void (^EPAskForPermissionToPlaybackBlock_t)(void);

@interface EPWindowsUtil : EPConfigurableObject

- (void)showUpdateWindowWithProxy:(EPDownloadTextbookProxy *)proxy;
- (void)showTextbookDownloadError:(NSError *)error;
- (void)showAppUpdateRequiredWindow;
- (void)showNoInternetWindow;
- (void)showInvalidPasswordWindow;
- (BOOL)askForPermissionToPlaybackVideo:(EPAskForPermissionToPlaybackBlock_t)callback;
- (void)askForPasswordToAccessAdminSettings:(EPCanAccessAdminSettingsBlock_t)block;

- (void)showErrorMessage:(NSString *)message withAction:(void (^)(void))actionBlock;
- (void)showInfoMessage:(NSString *)message withAction:(void (^)(void))actionBlock;

@end
