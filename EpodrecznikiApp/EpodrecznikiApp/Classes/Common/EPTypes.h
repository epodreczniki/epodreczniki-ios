







#ifndef EpodrecznikiApp_EPTypes_h
#define EpodrecznikiApp_EPTypes_h


typedef NS_ENUM(NSInteger, EPTextbookStateType) {
    EPTextbookStateTypeUnknown                                  = 0,
    EPTextbookStateTypeToDownload                               = 1,
    EPTextbookStateTypeDownloading                              = 2,
    EPTextbookStateTypeNormal                                   = 3,
    EPTextbookStateTypeToUpdate                                 = 4,
    EPTextbookStateTypeUpdating                                 = 5
};


typedef NS_ENUM(NSInteger, EPErrorCode) {
    EPErrorCodeUnknown                                          = 8000,
    EPErrorCodeNoFreeSpace                                      = 8001,
    EPErrorCodeUnzipError                                       = 8002,
    EPErrorResumePossible                                       = 8003
};


typedef NS_ENUM(NSInteger, EPAccountRole) {
    EPAccountRoleUnknown                                        = 0,
    EPAccountRoleAdmin                                          = 1,
    EPAccountRoleUser                                           = 2
};


typedef NS_ENUM(NSInteger, EPAppState) {
    EPAppStateUnknown                                           = 0,
    EPAppStateAnonymousAccount                                  = 1,
    EPAppStateSecuredAdminAccount                               = 2,
    EPAppStateNoPassAdminAccount                                = 3,
    EPAppStateMultipleUserAccounts                              = 4
};


typedef NS_ENUM(NSInteger, EPFilterType) {
    EPFilterTypeNotSet                                          = 0,
    EPFilterTypeNone                                            = 1,
    EPFilterTypeByEducationLevel                                = 2,
    EPFilterTypeBySubject                                       = 3
};






typedef NS_ENUM(NSInteger, EPSettingsCanDownloadAndRemoveTextbooksType) {
    EPSettingsCanDownloadAndRemoveTextbooksTypeUnknown          = 0,
    EPSettingsCanDownloadAndRemoveTextbooksTypeGranted          = 1,
    EPSettingsCanDownloadAndRemoveTextbooksTypeDenied           = 2
};


typedef NS_ENUM(NSInteger, EPSettingsCanLoginWithoutPasswordType) {
    EPSettingsCanLoginWithoutPasswordTypeUnknown                = 0,
    EPSettingsCanLoginWithoutPasswordTypeGranted                = 1,
    EPSettingsCanLoginWithoutPasswordTypeDenied                 = 2
};


typedef NS_ENUM(NSInteger, EPSettingsTextbookVariantType) {
    EPSettingsTextbookVariantTypeUnset                          = 0,
    EPSettingsTextbookVariantTypeStudent                        = 1,
    EPSettingsTextbookVariantTypeTeacher                        = 2
};


typedef NS_ENUM(NSInteger, EPSettingsVideoPlayerPlaybackType) {
    EPSettingsVideoPlayerPlaybackTypeUnset                      = 0,
    EPSettingsVideoPlayerPlaybackTypeAsk                        = 1,
    EPSettingsVideoPlayerPlaybackTypeAlways                     = 2
};


typedef NS_ENUM(NSInteger, EPSettingsTextbooksListContainerType) {
    EPSettingsTextbooksListContainerTypeUnknown                 = 0,
    EPSettingsTextbooksListContainerTypeCarousel                = 1,
    EPSettingsTextbooksListContainerTypeTable                   = 2,
    EPSettingsTextbooksListContainerTypeCollection              = 3
};


typedef NS_ENUM(NSInteger, EPSettingsNavigationButtonsVisibilityType) {
    EPSettingsNavigationButtonsVisibilityTypeUnknown            = 0,
    EPSettingsNavigationButtonsVisibilityTypeVisible            = 1,
    EPSettingsNavigationButtonsVisibilityTypeHidden             = 2
};






typedef NS_ENUM(NSInteger, EPSettingsCellularStateType) {
    EPSettingsCellularStateTypeUnknown                          = 0,
    EPSettingsCellularStateTypeAllowed                          = 1,
    EPSettingsCellularStateTypeDenied                           = 2
};


typedef NS_ENUM(NSInteger, EPSettingsCanUserCreateAccountType) {
    EPSettingsCanUserCreateAccountTypeUnknown                     = 0,
    EPSettingsCanUserCreateAccountTypeGranted                     = 1,
    EPSettingsCanUserCreateAccountTypeDenied                      = 2
};

#endif
