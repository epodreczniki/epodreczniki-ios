







#import "EPFunctions.h"

NSString *NSStringFromEPTextbookStateType(EPTextbookStateType type) {
    NSArray *array = @[
        @"EPTextbookStateTypeUnknown",
        @"EPTextbookStateTypeToDownload",
        @"EPTextbookStateTypeDownloading",
        @"EPTextbookStateTypeNormal",
        @"EPTextbookStateTypeToUpdate",
        @"EPTextbookStateTypeUpdating",
    ];
    return array[type];
}

NSString *NSStringFromEPErrorCode(EPErrorCode code) {
    NSArray *array = @[
        @"EPErrorCodeUnknown",
        @"EPErrorCodeNoFreeSpace",
        @"EPErrorCodeUnzipError",
        @"EPErrorResumePossible"
    ];
    return array[code];
}

NSString *NSStringFromEPAccountRole(EPAccountRole role) {
    NSArray *array = @[
        @"EPAccountRoleUnknown",
        @"EPAccountRoleAdmin",
        @"EPAccountRoleUser"
    ];
    return array[role];
}

NSString *NSStringFromEPAppState(EPAppState state) {
    NSArray *array = @[
        @"EPAppStateUnknown",
        @"EPAppStateAnonymousAccount",
        @"EPAppStateSecuredAdminAccount",
        @"EPAppStateNoPassAdminAccount",
        @"EPAppStateMultipleUserAccounts"
    ];
    return array[state];
}


NSString *NSStringFromEPSettingsCanDownloadAndRemoveTextbooksType(EPSettingsCanDownloadAndRemoveTextbooksType type) {
    NSArray *array = @[
        @"EPSettingsCanDownloadAndRemoveTextbooksTypeUnknown",
        @"EPSettingsCanDownloadAndRemoveTextbooksTypeGranted",
        @"EPSettingsCanDownloadAndRemoveTextbooksTypeDenied"
    ];
    return array[type];
}

NSString *NSStringFromEPSettingsCanLoginWithoutPasswordType(EPSettingsCanLoginWithoutPasswordType type) {
    NSArray *array = @[
        @"EPSettingsCanLoginWithoutPasswordTypeUnknown",
        @"EPSettingsCanLoginWithoutPasswordTypeGranted",
        @"EPSettingsCanLoginWithoutPasswordTypeDenied"
    ];
    return array[type];
}

NSString *NSStringFromEPSettingsTextbookVariantType(EPSettingsTextbookVariantType type) {
    NSArray *array = @[
        @"EPSettingsTextbookVariantTypeUnset",
        @"EPSettingsTextbookVariantTypeStudent",
        @"EPSettingsTextbookVariantTypeTeacher"
    ];
    return array[type];
}

NSString *NSStringFromEPSettingsVideoPlayerPlaybackType(EPSettingsVideoPlayerPlaybackType type) {
    NSArray *array = @[
        @"EPSettingsVideoPlayerPlaybackTypeUnset",
        @"EPSettingsVideoPlayerPlaybackTypeAsk",
        @"EPSettingsVideoPlayerPlaybackTypeAlways"
    ];
    return array[type];
}

NSString *NSStringFromEPSettingsTextbooksListContainerType(EPSettingsTextbooksListContainerType type) {
    NSArray *array = @[
        @"EPSettingsTextbooksListContainerTypeUnknown",
        @"EPSettingsTextbooksListContainerTypeCarousel",
        @"EPSettingsTextbooksListContainerTypeTable",
        @"EPSettingsTextbooksListContainerTypeCollection"
    ];
    return array[type];
}

NSString *NSStringFromEPSettingsNavigationButtonsVisibilityType(EPSettingsNavigationButtonsVisibilityType type) {
    NSArray *array = @[
        @"EPSettingsNavigationButtonsVisibilityTypeUnknown",
        @"EPSettingsNavigationButtonsVisibilityTypeVisible",
        @"EPSettingsNavigationButtonsVisibilityTypeHidden"
    ];
    return array[type];
}


NSString *NSStringFromEPSettingsCellularStateType(EPSettingsCellularStateType type) {
    NSArray *array = @[
        @"EPSettingsCellularStateTypeUnset",
        @"EPSettingsCellularStateTypeAllowed",
        @"EPSettingsCellularStateTypeDenied"
    ];
    return array[type];
}


NSString *createContentID(NSString *rootID, NSString *mdVersion) {
    return [NSString stringWithFormat:@"%@_%@", rootID, mdVersion];
}

NSString *convertContentIDToHandbookID(NSString *contentID) {
    return [contentID stringByReplacingOccurrencesOfString:@"_" withString:@":"];
}

NSString *convertHandbookIDToContentID(NSString *handbookID) {
    return [handbookID stringByReplacingOccurrencesOfString:@":" withString:@"_"];
}
