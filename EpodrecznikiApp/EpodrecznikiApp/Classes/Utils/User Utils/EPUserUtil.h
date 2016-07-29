







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

@interface EPUserUtil : EPConfigurableObject

@property (nonatomic, readonly) NSNumber *userID;
@property (nonatomic, readonly) NSString *userIDString;
@property (nonatomic, readonly) EPUser *user;
@property (nonatomic) EPAppState appState;
@property (nonatomic) BOOL hasDownloadedInitialTextbookList;


- (void)determineState;
- (BOOL)appRequiresUsersToLogin;
- (BOOL)canLogoutUser;
- (BOOL)canAdministrateApp;


- (void)logInUser:(EPUser *)user;
- (void)logInDefaultUser;
- (void)logOutUser;


- (BOOL)isPasswordStrongEnough:(NSString *)password;
- (BOOL)verifyPassword:(NSString *)password withUser:(EPUser *)user;
- (BOOL)verifyRecoveryAnswer:(NSString *)answer withUser:(EPUser *)user;

@end
