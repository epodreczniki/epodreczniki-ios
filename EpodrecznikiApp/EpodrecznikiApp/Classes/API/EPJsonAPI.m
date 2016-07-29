







#import "EPJsonAPI.h"

@implementation EPJsonAPI

@synthesize apiURL = _apiURL;

- (instancetype)initWithApiURL:(NSString *)anApiURL {
    NSAssert(anApiURL, @"API URL Cannot be empty");
    self = [super init];
    if (self) {
        _apiURL = anApiURL;
    }
    return self;
}

- (void)dealloc {
    _apiURL = nil;
}

- (id)objectFromAPI {
    return [self objectFromAPIWithUriString:nil];
}

- (id)objectFromAPIWithUriString:(NSString *)uri {

    NSString *requestString = nil;
    if (uri) {
        requestString = [self.apiURL stringByAppendingFormat:@"?%@", uri];
    }
    else {
        requestString = self.apiURL;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.URL = [NSURL URLWithString:requestString];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = kTimeIntervalForCallPerAPI;
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [request addValue:kApiHeaderVersionValue forHTTPHeaderField:kApiHeaderVersionKey];
    
#if DEBUG_HTTP

#endif

    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
#if DEBUG_HTTP

#endif
#if DEBUG_SERVER_503
    NSString *html = @"<html><body><h1>503</h1><p>Server error</p></body></html>";
    responseData = [html dataUsingEncoding:NSUTF8StringEncoding];
#endif

    if (!responseData && error) {

    }

    else {

        NSJSONReadingOptions options = (NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments);
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:options error:&error];

        if (!jsonObject && error) {

        }
        
        return jsonObject;
    }
    
    return nil;
}

- (id)objectFromAPIForPage:(int)page andLimit:(int)limit {
    
    NSString *uriString = [NSString stringWithFormat:@"page=%d&limit=%d", page, limit];
    
    return [self objectFromAPIWithUriString:uriString];
}

@end
