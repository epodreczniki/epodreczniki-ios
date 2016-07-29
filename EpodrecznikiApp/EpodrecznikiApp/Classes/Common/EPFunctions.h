







NSString *NSStringFromEPTextbookStateType(EPTextbookStateType type);
NSString *NSStringFromEPErrorCode(EPErrorCode code);
NSString *NSStringFromEPAccountRole(EPAccountRole role);
NSString *NSStringFromEPAppState(EPAppState state);


NSString *NSStringFromEPSettingsCanDownloadAndRemoveTextbooksType(EPSettingsCanDownloadAndRemoveTextbooksType type);
NSString *NSStringFromEPSettingsCanLoginWithoutPasswordType(EPSettingsCanLoginWithoutPasswordType type);
NSString *NSStringFromEPSettingsTextbookVariantType(EPSettingsTextbookVariantType type);
NSString *NSStringFromEPSettingsVideoPlayerPlaybackType(EPSettingsVideoPlayerPlaybackType type);
NSString *NSStringFromEPSettingsTextbooksListContainerType(EPSettingsTextbooksListContainerType type);
NSString *NSStringFromEPSettingsNavigationButtonsVisibilityType(EPSettingsNavigationButtonsVisibilityType type);


NSString *NSStringFromEPSettingsCellularStateType(EPSettingsCellularStateType type);


NSString *createContentID(NSString *rootID, NSString *mdVersion);
NSString *convertContentIDToHandbookID(NSString *contentID);
NSString *convertHandbookIDToContentID(NSString *handbookID);
