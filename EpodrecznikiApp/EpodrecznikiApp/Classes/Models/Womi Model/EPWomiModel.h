







#import <Foundation/Foundation.h>
#import "EPDatabaseModel.h"

@interface EPWomiModel : EPDatabaseModel

- (void)setWomiState:(NSString *)state forWomiID:(NSString *)womiID andUserID:(NSNumber *)userID andRootID:(NSString *)rootID;
- (NSString *)getWomiStateForWomiID:(NSString *)womiID andUserID:(NSNumber *)userID andRootID:(NSString *)rootID;

- (void)removeAllWomiStateByRootID:(NSString *)rootID;
- (void)removeAllWomiStateByUserID:(NSNumber *)userID;


- (void)setOpenQuestionState:(NSString *)openQuestionID state:(NSString *)base64str andUserID:(NSNumber *)userID andRootID:(NSString *)rootID;
- (NSString *)getOpenQuestionStateForIds:(NSString *)idsArray andUserID:(NSNumber *)userID andRootID:(NSString *)rootID;



@end
