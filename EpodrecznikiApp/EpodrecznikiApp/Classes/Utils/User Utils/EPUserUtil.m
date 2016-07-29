







#import "EPUserUtil.h"

@implementation EPUserUtil

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        _appState = EPAppStateUnknown;
        self.hasDownloadedInitialTextbookList = NO;
    }
    return self;
}

- (void)dealloc {
    _user = nil;
}

#pragma mark - State management

- (void)determineState {


    int numberOfUsers = [self.configuration.userModel numberOfUsers];
    if (numberOfUsers == 1) {
        
        EPUser *admin = self.user;
        if (!admin) {
            admin = [self.configuration.userModel readAdminUser];
        }

        if (admin.role == EPAccountRoleAdmin) {

            if (admin.state.canLoginWithoutPassword) {
                _appState = EPAppStateNoPassAdminAccount;
            }

            else {
                _appState = EPAppStateSecuredAdminAccount;
            }
        }

        else {
            _appState = EPAppStateAnonymousAccount;
        }
    }
    else {
        _appState = EPAppStateMultipleUserAccounts;
    }

}

- (BOOL)appRequiresUsersToLogin {

    
    return (self.appState == EPAppStateMultipleUserAccounts)
        || (self.appState == EPAppStateSecuredAdminAccount);
}

- (BOOL)canLogoutUser {
    return self.appState == EPAppStateSecuredAdminAccount
        || self.appState == EPAppStateMultipleUserAccounts;
}

- (BOOL)canAdministrateApp {
    return self.appState == EPAppStateAnonymousAccount
        || (self.user && self.user.role == EPAccountRoleAdmin);
}

#pragma mark - State management

- (void)logInDefaultUser {
    EPUser *user = [self.configuration.userModel readAdminUser];
    [self logInUser:user];
}

- (void)logInUser:(EPUser *)user {
    if ([NSObject isNullOrEmpty:user]) {
        return;
    }

    user.lastLoginDate = [NSDate new];
    [user update];

    _user = user;

}

- (void)logOutUser {

    _user = nil;

}

- (NSNumber *)userID {
    if (!self.user) {
        return @(kDefaultUserID);
    }
    return self.user.userID;
}

- (NSString *)userIDString {
    return [NSString stringWithFormat:@"%@", self.userID];
}

#pragma mark - Password and recovery

- (BOOL)isPasswordStrongEnough:(NSString *)password {
    if ([NSObject isNullOrEmpty:password]) {
        return NO;
    }
    
    return password.length >= 6;
}

- (BOOL)verifyPassword:(NSString *)password withUser:(EPUser *)user {
    if ([NSObject isNullOrEmpty:password] || [NSObject isNullOrEmpty:user]) {
        return NO;
    }

    return [self.configuration.cryptoUtil matchesHash:user.hpassword withString:password andSalt:user.spassword];
}

- (BOOL)verifyRecoveryAnswer:(NSString *)answer withUser:(EPUser *)user {
    if ([NSObject isNullOrEmpty:answer] || [NSObject isNullOrEmpty:user]) {
        return NO;
    }

    return [self.configuration.cryptoUtil matchesHash:user.hanswer withString:answer andSalt:user.sanswer];
}

@end
