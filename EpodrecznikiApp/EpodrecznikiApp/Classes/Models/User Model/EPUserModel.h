







#import <Foundation/Foundation.h>
#import "EPDatabaseModel.h"
#import "EPUser.h"

@interface EPUserModel : EPDatabaseModel


- (void)createUser:(EPUser *)user;
- (EPUser *)readUserByID:(NSNumber *)userID;
- (EPUser *)readAdminUser;
- (void)updateUser:(EPUser *)user;
- (void)deleteUser:(NSNumber *)userID;


- (NSArray *)allUsersByName;
- (NSArray *)allUsersByType;
- (int)numberOfUsers;
- (BOOL)isUsernameAvailable:(NSString *)username;

@end
