
#define API_BASE    @"<HERE PASTE URL TO API>"

#define RAM_KB      1024ULL
#define STORAGE_KB  1000ULL

extern NSString * const kApplicationName;


extern NSString * const kCoversDirectoryName;
extern NSString * const kTextbooksDirectoryName;
extern NSString * const kOtherDirectoryName;


extern NSString * kCollectionsAPIResourceURL;
extern NSString * kCollectionsMetadataAPIResourceURL;
extern NSString * kAuthorsAPIResourceURL;
extern NSString * kKeywordsAPIResourceURL;
extern NSString * kSchoolsAPIResourceURL;
extern NSString * kSubjectsAPIResourceURL;


extern NSString * const kApiHeaderVersionKey;
extern NSString * const kApiHeaderVersionValue;


extern NSTimeInterval const kTimeIntervalBetweenUpdatesFromAPI;
extern NSTimeInterval const kTimeIntervalForCallPerAPI;
extern NSTimeInterval const kTimeIntervalForCoverDownload;
extern NSTimeInterval const kTimeIntervalForReminderAboutTextbookListRefresh;
extern NSTimeInterval const kTimeIntervalForDownloadServiceRequest;
extern NSTimeInterval const kTimeIntervalForDownloadServiceResponse;
extern NSTimeInterval const kTimeIntervalForDownloadCover;
extern NSTimeInterval const kTimeIntervalBeforHidingProgressHudInTextbookLoading;


extern unsigned long const kMaxImageSizeInBytesStoredInMemory;


extern float const kMaxLoadTimeForTextbookPage;
extern float const kMaxLoadTimeForGeogebraPage;


extern NSString * const kPreferencesKeyVersion;
extern NSString * const kPreferencesKeyUseCellularNetwork DEPRECATED_ATTRIBUTE;
extern NSString * const kPreferencesKeyTextbookVariant DEPRECATED_ATTRIBUTE;
extern NSString * const kPreferencesKeyVideoPlayerSettings DEPRECATED_ATTRIBUTE;


extern NSString * const kTextbookListCellReattachDelegateNotification;
extern NSString * const kTextbookReaderClearWebviewPointerNotification;
extern NSString * const kTextbookReaderLoadPageByIndexNotification;
extern NSString * const kTextbookReaderUpdateFontSizeNotification;
extern NSString * const kTextbooksListFilterChangedNotification;
extern NSString * const kTextbookReaderDeleteNoteNotification;
extern NSString * const kTextbookReaderUpdateNoteNotification;
extern NSString * const kTextbookUpdateTocLocationNotification;


extern NSString * const kEPAppleDownloadServiceProxyKey;
extern NSString * const kTextbookReaderLoadPageByIndexNotificationPageIndexKey;
extern NSString * const kTextbookUpdateTocLocationNotificationPageItemKey;


extern NSString * const kResumeFileName;
extern NSString * const kStoreUrl;


int const kGlobalUserID;
int const kDefaultUserID;
