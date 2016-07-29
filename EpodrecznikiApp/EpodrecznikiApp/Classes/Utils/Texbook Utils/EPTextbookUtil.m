







#import "EPTextbookUtil.h"

@interface EPTextbookUtil ()

@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

@end

@implementation EPTextbookUtil

@synthesize backgroundQueue = _backgroundQueue;

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        _backgroundQueue = dispatch_queue_create("pl.psnc.textbook-util", NULL);
    }
    return self;
}

- (void)dealloc {
    self.backgroundQueue = nil;
}

#pragma mark - Public methods

- (void)fetchArrayWithTextbookDataAndCompletion:(void (^)(NSArray *))completion {
    
    BOOL isTablet = [UIDevice currentDevice].isIPad;

    dispatch_barrier_async(self.backgroundQueue, ^{


        [self.configuration.downloadUtil waitForDownloadDataFromAPI];


        NSArray *arrayOfAllCollections = [self.configuration.textbookModel arrayOfTextbooksForTablet:isTablet];

        EPFilter *filter = self.configuration.settingsModel.activeFilter;
        NSArray *arrayOfFilteredCollections = [self.configuration.filterUtil filterCollections:arrayOfAllCollections withFilter:filter];

        BOOL success = arrayOfFilteredCollections.count > 0;
        if (success) {

        }

        else {

        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(arrayOfFilteredCollections);
            }
        });
    });
}

- (EPCollection *)collectionForRootID:(NSString *)rootID {
    
    EPMetadata *metadata = [self.configuration.textbookModel metadataWithRootID:rootID];
    EPCollection *collection = [self.configuration.textbookModel collectionWithContentID:metadata.storeContentID];
    
    return collection;
}

- (BOOL)textbookRequiresAdvancedReaderWithProxy:(EPDownloadTextbookProxy *)proxy {
    if (!proxy) {
        return NO;
    }

    NSString *textbookPath = [self.configuration.pathModel pathForInstalledTextbookWithProxy:proxy];
    NSString *tocFile = [self.configuration.pathModel pathForTocWithTextbookPath:textbookPath];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:tocFile];
    
    return exists;
}

- (BOOL)textbookRequiresAdvancedReaderWithPath:(NSString *)textbookPath {
    if ([NSObject isNullOrEmpty:textbookPath]) {
        return NO;
    }

    NSString *tocFile = [self.configuration.pathModel pathForTocWithTextbookPath:textbookPath];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:tocFile];
    
    return exists;
}

#pragma mark - Hooks

- (void)postTextbookDownloadWithProxy:(EPDownloadTextbookProxy *)proxy andDestination:(NSString *)destination {
    if (!proxy) {
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;

    NSString *cssFileIOS         = [self.configuration.pathModel pathForIosCssSourceWithTextbookPath:destination];
    NSString *cssFileDestination = [self.configuration.pathModel pathForIosCssDestinationWithTextbookPath:destination];
    NSString *jsFileIOS          = [self.configuration.pathModel pathForIosJsSourceWithTextbookPath:destination];
    NSString *jsFileDestination  = [self.configuration.pathModel pathForIosJsDestinationWithTextbookPath:destination];

    if ([fm fileExistsAtPath:cssFileIOS]) {

        if ([fm fileExistsAtPath:cssFileDestination]) {
            [fm removeItemAtPath:cssFileDestination error:&error];
        }

        [fm moveItemAtPath:cssFileIOS toPath:cssFileDestination error:&error];
    }

    if ([fm fileExistsAtPath:jsFileIOS]) {

        if ([fm fileExistsAtPath:jsFileDestination]) {
            [fm removeItemAtPath:jsFileDestination error:&error];
        }

        [fm moveItemAtPath:jsFileIOS toPath:jsFileDestination error:&error];
    }

    if (proxy.storeCollection.state == EPTextbookStateTypeUpdating) {

        NSString *textbookPath = [self.configuration.pathModel pathForInstalledTextbookWithProxy:proxy];
        if ([fm removeItemAtPath:textbookPath error:&error]) {

        }
        else {

        }

        [self.configuration.downloadModel removeCollectionWithContentID:proxy.storeCollection.storeContentID];
    }

    if ([self textbookRequiresAdvancedReaderWithPath:destination]) {
        
        NSString *tocFile = [self.configuration.pathModel pathForTocWithTextbookPath:destination];
        NSString *pagesFile = [self.configuration.pathModel pathForPagesWithTextbookPath:destination];
        NSString *navigationFile = [self.configuration.pathModel pathForNavigationWithTextbookPath:destination];
        
        EPTocItem *tocRoot = [self.configuration.tocUtil parseTocFromFile:tocFile];
        NSArray *pagesArray = [self.configuration.tocUtil parsePagesFromFile:pagesFile];
        
        if (tocRoot && pagesArray) {
            
            EPTocConfiguration *tocConfig = [EPTocConfiguration new];
            tocConfig.tocRoot = tocRoot;
            tocConfig.pagesTeacherArray = pagesArray;
            tocConfig.pagesStudentArray = [self.configuration.tocUtil studentArrayFromTeacherArray:pagesArray];
            tocConfig.pathToIndexStudent = [self.configuration.tocUtil createIndexDictionaryFromArray:tocConfig.pagesStudentArray];
            tocConfig.pathToIndexTeacher = [self.configuration.tocUtil createIndexDictionaryFromArray:tocConfig.pagesTeacherArray];

            [self.configuration.tocUtil writeTocConfiguration:tocConfig toPath:navigationFile];
        }
    }
}

- (void)postTextbookRemoveWithRootID:(NSString *)rootID andContentID:(NSString *)contentID {

    [self.configuration.collectionStateModel setLastPageLocation:nil forRootID:rootID];
    [self.configuration.collectionStateModel removeAllPageItemsForRootID:rootID];
    [self.configuration.notesModel removeAllNotesForHandbookID:convertContentIDToHandbookID(contentID)];
    [self.configuration.womiModel removeAllWomiStateByRootID:rootID];
}

#pragma mark - Remember state

- (NSString *)lastViewedPathForTextbookRootID:(NSString *)rootID {
    NSString *fullPath = nil;
    NSString *lastPage = [self.configuration.collectionStateModel lastPageLocationForRootID:rootID];
    if (lastPage) {
        lastPage = [self.configuration.pathModel pathInsideDocuments:lastPage];
    }

    if (lastPage && [[NSFileManager defaultManager] fileExistsAtPath:lastPage]) {
        
        fullPath = lastPage;
    }

    else {

        EPDownloadTextbookProxy *proxy = [self.configuration.downloadUtil downloadTextbookProxyForRootID:rootID];
        fullPath = [self.configuration.pathModel pathForIndexWithProxy:proxy];
    }
    
    return fullPath;
}

- (void)setLastViewedPath:(NSString *)path forTextbookRootID:(NSString *)rootID {
    
    NSString *lastPath = [self.configuration.pathModel relativePathFromDocuments:path];
    [self.configuration.collectionStateModel setLastPageLocation:lastPath forRootID:rootID];
}

- (EPPageItem *)lastViewedPageItemForTextbookRootID:(NSString *)rootID {
    
    EPPageItem *pageItem = [self.configuration.collectionStateModel lastPageItemForRootID:rootID];
    return pageItem;
}

- (void)setLastViewedPageItem:(EPPageItem *)pageItem forTextbookRootID:(NSString *)rootID {
    [self.configuration.collectionStateModel setLastPageItem:pageItem forRootID:rootID];
}

@end
