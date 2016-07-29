







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"
#import "Reachability.h"

@interface EPNetworkUtil : EPConfigurableObject

@property (nonatomic, assign) BOOL showActivityIndicator;
@property (nonatomic, readonly, getter = isNetworkReachableAndAllowed) BOOL networkReachableAndAllowed;
@property (nonatomic, readonly, getter = isWifiReachable) BOOL wifiReachable;
@property (nonatomic, readonly, getter = isCellularReachable) BOOL cellularReachable;
@property (nonatomic, readonly, getter = isNetworkUnreachable) BOOL networkUnreachable;

- (void)startNotifications;
- (void)stopNotifications;

@end
