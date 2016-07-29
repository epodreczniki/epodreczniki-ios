







#import "EPNetworkUtil.h"

@interface EPNetworkUtil ()

@property (nonatomic, strong) Reachability *reachability;

@end

@implementation EPNetworkUtil

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        self.reachability = [Reachability reachabilityForInternetConnection];
    }
    return self;
}

- (void)dealloc {
    self.reachability = nil;
}

#pragma mark - Public properties

- (BOOL)showActivityIndicator {
    return [UIApplication sharedApplication].networkActivityIndicatorVisible;
}

- (void)setShowActivityIndicator:(BOOL)showActivityIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = showActivityIndicator;
}

- (BOOL)isNetworkReachableAndAllowed {
#if DEBUG_NO_NETWORK
    return NO;
#endif

    if (self.isWifiReachable) {
        return YES;
    }

    BOOL cellularAllowed = (self.configuration.settingsModel.allowUsingCellularNetwork == EPSettingsCellularStateTypeAllowed);
    if (cellularAllowed && self.isCellularReachable) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isWifiReachable {
#if DEBUG_NO_NETWORK
    return NO;
#endif
    
    Reachability *reachability = [Reachability reachabilityForLocalWiFi];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if (remoteHostStatus == NotReachable) {
        return NO;
    }
    return YES;
}

- (BOOL)isCellularReachable {
#if DEBUG_NO_NETWORK
    return NO;
#endif
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if (remoteHostStatus == NotReachable) {
        return NO;
    }
    return ![self isWifiReachable];
}

- (BOOL)isNetworkUnreachable {
#if DEBUG_NO_NETWORK
    return YES;
#endif

    if (self.isWifiReachable) {
        return NO;
    }

    BOOL cellularNotDenied = (self.configuration.settingsModel.allowUsingCellularNetwork != EPSettingsCellularStateTypeDenied);
    if (self.isCellularReachable && cellularNotDenied) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Public methods

- (void)startNotifications {
    [self.reachability startNotifier];
}

- (void)stopNotifications {
    [self.reachability stopNotifier];
}

@end
