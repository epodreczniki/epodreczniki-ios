







#import "EPUser.h"

@implementation EPUser

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.login = @"defaultUser";
        self.role = EPAccountRoleUnknown;
        self.state = [EPUserState defaultUserState];
        self.createdDate = [NSDate new];
    }
    return self;
}

- (void)dealloc {
    self.userID = nil;
    self.login = nil;
    self.state = nil;
    self.avatar = nil;
    self.question = nil;
    self.spassword = nil;
    self.hpassword = nil;
    self.sanswer = nil;
    self.hanswer = nil;
    self.createdDate = nil;
    self.lastLoginDate = nil;
}

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithString:@""];
    [string appendString:@"<EPUser> {\n"];
    [string appendFormat:@"\tuserID: %@,\n", self.userID];
    [string appendFormat:@"\tlogin: %@,\n", self.login];
    [string appendFormat:@"\trole: %d,\n", (int)self.role];
    [string appendFormat:@"\tstate: %@,\n", self.state];
    [string appendFormat:@"\tavatar: %@,\n", self.avatar];
    [string appendFormat:@"\tquestion: %@,\n", self.question];
    [string appendFormat:@"\tspassword: %@,\n", self.spassword];
    [string appendFormat:@"\thpassword: %@,\n", self.hpassword];
    [string appendFormat:@"\tsanswer: %@,\n", self.sanswer];
    [string appendFormat:@"\thanswer: %@,\n", self.hanswer];
    [string appendFormat:@"\tcreatedDate: %@,\n", self.createdDate];
    [string appendFormat:@"\tlastLoginDate: %@\n", self.lastLoginDate];
    [string appendString:@"}"];
    
    return string;
}

#pragma mark - Public methods

- (void)update {
    [[EPConfiguration activeConfiguration].userModel updateUser:self];
}

@end
