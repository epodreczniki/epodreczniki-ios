







#import "EPWindowsUtil.h"
#import "EPAlertViewHandler.h"

@implementation EPWindowsUtil

- (void)showUpdateWindowWithProxy:(EPDownloadTextbookProxy *)proxy {

    EPTextbookModel *model = self.configuration.textbookModel;
    EPMetadata *metadata = [model metadataWithRootID:proxy.rootID];
    EPCollection *newCollection = [model collectionWithContentID:metadata.apiContentID];

    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"EPWindowsUtil_showUpdateWindowWithProxyMessage", nil),
        newCollection.textbookTitle,
        ((double)newCollection.formatZipSize / STORAGE_KB / STORAGE_KB),
        newCollection.textbookMdVersion,
        newCollection.textbookLicense
    ];

    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPWindowsUtil_showUpdateWindowWithProxyTitle", nil);
    handler.message = message;
    [handler addButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_showUpdateWindowWithProxyButtonYES", nil) andActionBlock:^{
        [proxy update];
    }];
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_showUpdateWindowWithProxyButtonNO", nil) andActionBlock:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        [handler show];
    });
}

- (void)showTextbookDownloadError:(NSError *)error {

    if (!error) {
        return;
    }

    if (error.code == EPErrorResumePossible) {

        EPDownloadTextbookProxy *proxy = error.userInfo[kEPAppleDownloadServiceProxyKey];
        
        EPAlertViewHandler *handler = [EPAlertViewHandler new];
        handler.title = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewButtonTitle", nil);
        handler.message = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageResume", nil);
        [handler addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageResumeYES", nil) andActionBlock:^{

            [proxy resume];
        }];
        [handler addCancelButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageResumeNO", nil) andActionBlock:^{

            NSString *resumeFilePath = [self.configuration.pathModel pathForResumeFile];
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:resumeFilePath]) {
                [fm removeItemAtPath:resumeFilePath error:nil];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [handler show];
        });
        
        return;
    }

    UIAlertView *alertView = [UIAlertView new];
    alertView.title = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewButtonTitle", nil);
    if (error.code == NSURLErrorNotConnectedToInternet) {
        alertView.message = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageNotConnected", nil);
    }
    else if (error.code == NSURLErrorFileDoesNotExist) {
        alertView.message = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageFileDoesNotExist", nil);
    }
    else if (error.code == NSURLErrorTimedOut) {
        alertView.message = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageTimedOut", nil);
    }
    else if (error.code == EPErrorCodeNoFreeSpace) {
        alertView.message = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageNoFreeSpace", nil);
    }
    else if (error.code == EPErrorCodeUnzipError) {
        alertView.message = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageUnzipError", nil);
    }
    else {
        alertView.message = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageUnknownError", nil);
    }
    [alertView addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewButtonOk", nil)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

- (void)showAppUpdateRequiredWindow {
    
    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPWindowsUtil_showAppUpdateRequiredWindowTitle", nil);
    handler.message = NSLocalizedString(@"EPWindowsUtil_showAppUpdateRequiredWindowMessage", nil);
    [handler addButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_showAppUpdateRequiredWindowOK", nil) andActionBlock:nil];
    [handler addButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_showAppUpdateRequiredWindowGoToStore", nil) andActionBlock:^{
        
        NSURL *url = [NSURL URLWithString:kStoreUrl];
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler show];
    });
}

- (void)showNoInternetWindow {
    
    UIAlertView *alertView = [UIAlertView new];
    alertView.title = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewButtonTitle", nil);
    alertView.message = NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewMessageNotConnected", nil);
    [alertView addButtonWithTitle:NSLocalizedString(@"EPTextbooksListViewController_downloadErrorAlertViewButtonOk", nil)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

- (void)showInvalidPasswordWindow {
    
    UIAlertView *alertView = [UIAlertView new];
    alertView.title = NSLocalizedString(@"EPWindowsUtil_showInvalidPasswordWindowTitle", nil);
    alertView.message = NSLocalizedString(@"EPWindowsUtil_showInvalidPasswordWindowMessage", nil);
    [alertView addButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_showInvalidPasswordWindowButtonOk", nil)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

- (BOOL)askForPermissionToPlaybackVideo:(EPAskForPermissionToPlaybackBlock_t)callback {
    
    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPWindowsUtil_askForPermissionToPlaybackVideoTitle", nil);
    handler.message = NSLocalizedString(@"EPWindowsUtil_askForPermissionToPlaybackVideoMessage", nil);
    [handler addButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_askForPermissionToPlaybackVideoCancel", nil) andActionBlock:nil];
    [handler addButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_askForPermissionToPlaybackVideoPlay", nil) andActionBlock:^{
        if (callback) {
            callback();
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler show];
    });
    
    return NO;
}

- (void)askForPasswordToAccessAdminSettings:(EPCanAccessAdminSettingsBlock_t)block {
#if DEBUG_ADMIN_NO_PASS
    if (block) {
        block();
    }
    return;
#endif
    
    EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;
    if (userUtil.user.role == EPAccountRoleAdmin) {
        
        EPAlertViewHandler *handler = [EPAlertViewHandler new];
        __weak EPAlertViewHandler *whandler = handler;
        handler.title = NSLocalizedString(@"EPWindowsUtil_askForPasswordToAccessAdminSettingsTitle", nil);
        handler.alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [handler addButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_askForPasswordToAccessAdminSettingsOk", nil) andActionBlock:^{
            
            UITextField *textField = [whandler.alertView textFieldAtIndex:0];
            if ([userUtil verifyPassword:textField.text withUser:userUtil.user]) {
                if (block) {
                    block();
                }
            }
            else {
                [self showInvalidPasswordWindow];
            }
        }];
        [handler addCancelButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_askForPasswordToAccessAdminSettingsCancel", nil) andActionBlock:nil];
        [handler show];
    }
    else if (userUtil.user.role == EPAccountRoleUnknown) {
        if (block) {
            block();
        }
    }
}

- (void)showErrorMessage:(NSString *)message withAction:(void (^)(void))actionBlock {
    
    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPWindowsUtil_showErrorMessageWithActionTitle", nil);
    handler.message = message;
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_showErrorMessageWithActionCancel", nil) andActionBlock:actionBlock];
    [handler show];
}

- (void)showInfoMessage:(NSString *)message withAction:(void (^)(void))actionBlock {
    
    EPAlertViewHandler *handler = [EPAlertViewHandler new];
    handler.title = NSLocalizedString(@"EPWindowsUtil_showInfoMessageWithActionTitle", nil);
    handler.message = message;
    [handler addCancelButtonWithTitle:NSLocalizedString(@"EPWindowsUtil_showInfoMessageWithActionCancel", nil) andActionBlock:actionBlock];
    [handler show];
}

@end
