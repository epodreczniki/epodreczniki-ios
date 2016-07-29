







#import <Foundation/Foundation.h>
#import "EPUserState.h"

@interface EPUser : NSObject

@property (nonatomic, copy) NSNumber *userID;
@property (nonatomic, copy) NSString *login;
@property (nonatomic) EPAccountRole role;
@property (nonatomic, strong) EPUserState *state;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSString *spassword;
@property (nonatomic, copy) NSString *hpassword;
@property (nonatomic, copy) NSString *sanswer;
@property (nonatomic, copy) NSString *hanswer;
@property (nonatomic, copy) NSDate *createdDate;
@property (nonatomic, copy) NSDate *lastLoginDate;

- (void)update;

@end
