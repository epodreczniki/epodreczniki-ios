







#import "EPUserModel.h"

@implementation EPUserModel

#pragma mark - User CRUD

- (void)createUser:(EPUser *)user {
    @synchronized (self) {
        if (!user) {
            return;
        }
        EPDateUtil *dateUtil = [EPConfiguration activeConfiguration].dateUtil;

        [self executeNonQueryWithName:@"ep_user_create_user",
            user.login,
            @(user.role),
            [user.state stateString],
            user.avatar,
            user.question,
            user.spassword,
            user.hpassword,
            user.sanswer,
            user.hanswer,
            [dateUtil dateTimeFromDate:user.createdDate],
            [dateUtil dateTimeFromDate:user.lastLoginDate]
        ];

        user.userID = @([self lastInsertedRowId]);
    }
}

- (EPUser *)readUserByID:(NSNumber *)userID {
    @synchronized (self) {
        if (!userID) {
            return nil;
        }

        EPUser *user = nil;

        FMResultSet *rs = [self executeQueryWithName:@"ep_user_read_user", userID];
        if ([rs next]) {
            user = [self userFromResultSet:rs];
        }
        [rs close];
        [self closeDatabase];
        
        return user;
    }
}

- (EPUser *)readAdminUser {
    return [self readUserByID:@(kDefaultUserID)];
}

- (void)updateUser:(EPUser *)user {
    @synchronized (self) {
        if (!user) {
            return;
        }
        EPDateUtil *dateUtil = [EPConfiguration activeConfiguration].dateUtil;

        [self executeNonQueryWithName:@"ep_user_update_user",
            user.login,
            @(user.role),
            [user.state stateString],
            user.avatar,
            user.question,
            user.spassword,
            user.hpassword,
            user.sanswer,
            user.hanswer,
            [dateUtil dateTimeFromDate:user.createdDate],
            [dateUtil dateTimeFromDate:user.lastLoginDate],
            user.userID
        ];
    }
}

- (void)deleteUser:(NSNumber *)userID {
    @synchronized (self) {
        if (!userID) {
            return;
        }

        [self executeNonQueryWithName:@"ep_user_delete_user", userID];

        [self postDeleteUserWithUserID:userID];
    }
}

#pragma mark - User management

- (NSArray *)allUsersByName {
    @synchronized (self) {

        NSMutableArray *result = [NSMutableArray new];
        
        FMResultSet *rs = [self executeQueryWithName:@"ep_user_get_all_users_by_name"];
        while ([rs next]) {
            EPUser *user = [self userFromResultSet:rs];
            [result addObject:user];
        }
        [rs close];
        [self closeDatabase];

        if (result.count > 0) {
            return [NSArray arrayWithArray:result];
        }
        
        return nil;
    }
}

- (NSArray *)allUsersByType {
    @synchronized (self) {

        NSMutableArray *result = [NSMutableArray new];
        
        FMResultSet *rs = [self executeQueryWithName:@"ep_user_get_all_users_by_type"];
        while ([rs next]) {
            EPUser *user = [self userFromResultSet:rs];
            [result addObject:user];
        }
        [rs close];
        [self closeDatabase];

        if (result.count > 0) {
            return [NSArray arrayWithArray:result];
        }
        
        return nil;
    }
}

- (int)numberOfUsers {
    @synchronized (self) {
        return [self intForName:@"ep_user_users_count"];
    }
}

- (BOOL)isUsernameAvailable:(NSString *)username {
    if ([NSObject isNullOrEmpty:username]) {
        return NO;
    }
    
    @synchronized (self) {
        return ![self boolForName:@"ep_user_name_available", username.lowercaseString];
    }
}

#pragma mark - Private user

- (EPUser *)userFromResultSet:(FMResultSet *)rs {
    EPUser *user = [EPUser new];
    user.userID = [rs numberForColumn:@"id"];
    user.login = [rs stringForColumn:@"login"];
    user.role = [rs intForColumn:@"role"];
    NSString *state = [rs stringForColumn:@"state"];
    user.state = [[EPUserState alloc] initWithString:state];
    user.avatar = [rs stringForColumn:@"avatar"];
    user.question = [rs stringForColumn:@"question"];
    user.spassword = [rs stringForColumn:@"spassword"];
    user.hpassword = [rs stringForColumn:@"hpassword"];
    user.sanswer = [rs stringForColumn:@"sanswer"];
    user.hanswer = [rs stringForColumn:@"hanswer"];
    
    EPDateUtil *dateUtil = [EPConfiguration activeConfiguration].dateUtil;
    user.createdDate = [dateUtil dateFromDateTimeString:[rs stringForColumn:@"created_date"]];
    user.lastLoginDate = [dateUtil dateFromDateTimeString:[rs stringForColumn:@"last_login_date"] ];
    
    return user;
}

- (void)postDeleteUserWithUserID:(NSNumber *)userID {
    [self.configuration.collectionStateModel removeAllPageItemsForUserID:userID];
    [self.configuration.notesModel removeAllNotesForUserID:userID];
    [self.configuration.womiModel removeAllWomiStateByUserID:userID];
}

@end
