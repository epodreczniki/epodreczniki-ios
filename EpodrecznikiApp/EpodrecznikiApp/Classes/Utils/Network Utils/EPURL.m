







#import "EPURL.h"

@implementation EPURL

+ (NSURL *)URLWithHost:(NSString *)host andResource:(NSString *)resource {
    NSString *string = @"";
    
    BOOL useHttps = NO;
    if ([resource rangeOfString:@"://"].location == 0) {
        string = [(useHttps ? @"https" : @"http") stringByAppendingString:resource];
    }
    else if ([resource rangeOfString:@"//"].location == 0) {
        string = [(useHttps ? @"https:" : @"http:") stringByAppendingString:resource];
    }
    else if ([resource rangeOfString:@"/"].location == 0) {
        string = [host stringByAppendingString:resource];
    }
    else {
        string = resource;
    }

    NSURL *url = [NSURL URLWithString:string];
    
    return url;
}

@end
