







#import "EPWomiModel.h"

@implementation EPWomiModel

- (void)setWomiState:(NSString *)womiState forWomiID:(NSString *)womiID andUserID:(NSNumber *)userID andRootID:(NSString *)rootID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"ep_user_womi_state_delete", userID, rootID, womiID, womiState];
        [self executeNonQueryWithName:@"ep_user_womi_state_set_data", userID, rootID, womiID, womiState];
    }
}

- (NSString *)getWomiStateForWomiID:(NSString *)womiID andUserID:(NSNumber *)userID andRootID:(NSString *)rootID {
    @synchronized (self) {
        NSString *result = @"";
        
        FMResultSet *rs = [self executeQueryWithName:@"ep_user_womi_state_get_data", userID, rootID, womiID];
        if ([rs next]) {
            result = [rs stringForColumn:@"womi_state"];
        }
        [rs close];
        [self closeDatabase];
        
        return result;
    }
}

- (void)removeAllWomiStateByRootID:(NSString *)rootID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"ep_user_womi_state_delete_by_root_id", rootID];
    }
}

- (void)removeAllWomiStateByUserID:(NSNumber *)userID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"ep_user_womi_state_delete_by_user_id", userID];
    }
}


#pragma mark - Open questions

- (NSString *)getOpenQuestionStateForIds:(NSString *)idsArray andUserID:(NSNumber *)userID andRootID:(NSString *)rootID {
    @try {
        NSMutableDictionary* dictOfQuestions = [NSMutableDictionary new];

        NSString *result = @"";
        NSString* ids = [idsArray stringByReplacingOccurrencesOfString:@"[" withString:@""];
        ids = [ids stringByReplacingOccurrencesOfString:@"]" withString:@""];

        NSString* query = [NSString stringWithFormat:@"SELECT womi_id, womi_state FROM ep_user_womi_state WHERE user_id = %@ AND root_id = %@ AND womi_id IN (%@);",
                            userID, rootID, ids];
        @synchronized (self) {
            FMResultSet *rs = [self executeQueryWithString:query];
            while ([rs next]) {
                [dictOfQuestions setValue:[rs stringForColumn:@"womi_state"] forKey:[rs stringForColumn:@"womi_id"]];
            }
            [rs close];
            [self closeDatabase];
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictOfQuestions
                                                   options:NSJSONWritingPrettyPrinted 
                                                     error:&error];
            if (! jsonData) {
                NSLog(@"EPWomiModel - getOpenQuestionState serialization	 error: %@", error);
            } else {
                result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }

        }


        NSData *nsdata = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];

        return base64Encoded;
    }
    @catch (NSException *exception) {

        return @"error";
    }
}


- (void)setOpenQuestionState:(NSString *)openQuestionID state:(NSString *)base64str andUserID:(NSNumber *)userID andRootID:(NSString *)rootID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"ep_user_womi_state_delete", userID, rootID, openQuestionID, base64str];
        [self executeNonQueryWithName:@"ep_user_womi_state_set_data", userID, rootID, openQuestionID, base64str];
    }
}


@end
