







#import "EPConstants.h"


NSString * const kApplicationName               = @"E-podręczniki LITE";


NSString * const kCoversDirectoryName           = @"covers";
NSString * const kTextbooksDirectoryName        = @"texbooks";
NSString * const kOtherDirectoryName            = @"other";

NSString * kCollectionsMetadataAPIResourceURL   = API_BASE @"/collection/metadata3";

NSString * const kApiHeaderVersionKey           = @"Accept";
NSString * const kApiHeaderVersionValue         = @"application/json; application/psnc.epo.api-v1.0";



NSTimeInterval const kTimeIntervalBetweenUpdatesFromAPI                     = 5.0f;

NSTimeInterval const kTimeIntervalForCallPerAPI                             = 30.0f;

NSTimeInterval const kTimeIntervalForCoverDownload                          = 30.0f;

NSTimeInterval const kTimeIntervalForReminderAboutTextbookListRefresh       = 60.0f * 60.0f * 24.0f * 32.0f;

NSTimeInterval const kTimeIntervalForDownloadServiceRequest                 = 30.0f;

NSTimeInterval const kTimeIntervalForDownloadServiceResponse                = 60.0f * 60.0f * 24.0f * 2.0f;

NSTimeInterval const kTimeIntervalForDownloadCover                          = 60.0f * 5;

NSTimeInterval const kTimeIntervalBeforHidingProgressHudInTextbookLoading   = 10.0f;


unsigned long const kMaxImageSizeInBytesStoredInMemory                      = 24 * RAM_KB * RAM_KB;


float const kMaxLoadTimeForTextbookPage                                     = 10.0f;
float const kMaxLoadTimeForGeogebraPage                                     = 30.0f;


NSString * const kPreferencesKeyVersion                                     = @"kPreferencesKeyVersion";
NSString * const kPreferencesKeyUseCellularNetwork                          = @"kPreferencesKeyUseCellularNetwork";
NSString * const kPreferencesKeyTextbookVariant                             = @"kPreferencesKeyTextbookVariant";
NSString * const kPreferencesKeyVideoPlayerSettings                         = @"kPreferencesKeyVideoPlayerSettings";


NSString * const kTextbookListCellReattachDelegateNotification              = @"kTextbookListCellReattachDelegate";
NSString * const kTextbookReaderClearWebviewPointerNotification             = @"kTextbookReaderClearWebviewPointerNotification";
NSString * const kTextbookReaderLoadPageByIndexNotification                 = @"kTextbookReaderLoadPageByIndexNotification";
NSString * const kTextbookReaderUpdateFontSizeNotification                  = @"kTextbookReaderUpdateFontSizeNotification";
NSString * const kTextbooksListFilterChangedNotification                    = @"kTextbooksListFilterChangedNotification";
NSString * const kTextbookReaderDeleteNoteNotification                      = @"kTextbookReaderDeleteNote";
NSString * const kTextbookReaderUpdateNoteNotification                      = @"kTextbookReaderUpdateNoteNotification";
NSString * const kTextbookUpdateTocLocationNotification                     = @"kTextbookUpdateTocLocationNotification";


NSString * const kEPAppleDownloadServiceProxyKey                            = @"kEPAppleDownloadServiceProxyKey";
NSString * const kTextbookReaderLoadPageByIndexNotificationPageIndexKey     = @"kTextbookReaderLoadPageByIndexNotificationPageIndexKey";
NSString * const kTextbookUpdateTocLocationNotificationPageItemKey          = @"kTextbookUpdateTocLocationNotificationPageItemKey";


NSString * const kResumeFileName                                            = @"resume.file";
NSString * const kStoreUrl                                                  = @"itms-apps://itunes.apple.com/app/id878974304?mt=8";


int const kGlobalUserID                                                     = 0;
int const kDefaultUserID                                                    = 1;
