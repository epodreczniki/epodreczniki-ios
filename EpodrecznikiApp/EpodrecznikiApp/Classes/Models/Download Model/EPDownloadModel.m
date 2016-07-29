







#import "EPDownloadModel.h"
#import "EPDownloadFileUtil.h"
#import "EPURL.h"

typedef NS_ENUM(NSInteger, EPCollectionStatus) {
    EPCollectionStatusNone              = 0,
    EPCollectionStatusAdded             = 1,
    EPCollectionStatusAddedAndRemoved   = 2,
    EPCollectionStatusRemoved           = 3,
    EPCollectionStatusSkipped           = 4
};

NSString * const kRootIDDictionaryKey    = @"x_rootID";
NSString * const kContentIDDictionaryKey = @"x_contentID";

@implementation EPDownloadModel

@synthesize collectionsMetadataAPI = _collectionsMetadataAPI;

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        _collectionsMetadataAPI = [[EPJsonAPI alloc] initWithApiURL:kCollectionsMetadataAPIResourceURL];
    }
    return self;
}

- (void)dealloc {
    _collectionsMetadataAPI = nil;
}

@end

@implementation EPDownloadModel (DownloadData)

#pragma mark - Public methods

- (BOOL)downloadAndUpdateCollections {
    return [self downloadAndUpdateCollectionsWithHud:nil];
}

- (BOOL)downloadAndUpdateCollectionsWithHud:(EPProgressHUD *)hud {
    @synchronized (self) {
#ifdef DEBUG_HOST_ADDRESS
        _collectionsMetadataAPI = [[EPJsonAPI alloc] initWithApiURL:kCollectionsMetadataAPIResourceURL];
#endif
        
        NSArray *collections = nil;

        int added = 0;
        int removed = 0;
        int skipped = 0;
        int orphaned = 0;



        while (YES) {
            collections = [self.collectionsMetadataAPI objectFromAPI];


            if (!collections) {

                
                return NO;
            }


            [self markAllCollectionsNotInApi];

            if (hud && collections.count > 0) {
                hud.mode = MBProgressHUDModeAnnularDeterminate;
                hud.progress = 0.0f;
            }

            CGFloat i = 0.0f;
            for (id collection in collections) {
                
                NSString *isDummy = [NSString stringWithFormat:@"%@", collection[@"is_dummy"]];
                if (![isDummy isEqualToString:@"0"]) {

                    
                    continue;
                }

                EPCollectionStatus status = [self updateCollection:collection];
                switch (status) {
                    case EPCollectionStatusAdded:
                        added++;
                        break;
                    case EPCollectionStatusAddedAndRemoved:
                        added++;
                        removed++;
                        break;
                    case EPCollectionStatusRemoved:
                        removed++;
                        break;
                    case EPCollectionStatusSkipped:
                        skipped++;
                        break;
                    default:
                        break;
                }

                i++;
                if (hud) {
                    hud.progress = i / collections.count;
                }
            }

            break;
        }

        orphaned = [self removeOrphanedFromDatabase];
        
        orphaned += [self preventUpdatingOrphaned];

        [self closeDatabase];

        
        return YES;
    }
}

- (void)removeCollectionWithContentID:(NSString *)contentID {
    [self executeNonQueryWithName:@"remove_collection", contentID];
    [self executeNonQueryWithName:@"remove_collection_author", contentID];
    [self executeNonQueryWithName:@"remove_collection_format", contentID];
    [self executeNonQueryWithName:@"remove_collection_keyword", contentID];
    [self executeNonQueryWithName:@"remove_collection_school", contentID];
    [self executeNonQueryWithName:@"remove_collection_subject", contentID];

    [self removeCoverForContentID:contentID];
}

#pragma mark - Private methpds

- (NSString *)filterDate:(NSString *)dateString {
    dateString = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    dateString = [dateString stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    return dateString;
}

- (void)markAllCollectionsNotInApi {

    [self executeNonQueryWithName:@"mark_all_store_collection_as_not_in_api"];
}

- (void)markCollectionInApiByRootID:(NSString *)rootID {

    [self executeNonQueryWithName:@"mark_store_collection_as_in_api_by_root_id",
        rootID
    ];
}

- (int)removeOrphanedFromDatabase {
    
    NSMutableArray *arrayOfRootID = [NSMutableArray new];
    NSMutableArray *arrayOfContentID = [NSMutableArray new];

    FMResultSet *rs = [self executeQueryWithName:@"get_orphaned"];
    while ([rs next]) {
        
        NSString *rootID = [rs stringForColumn:@"root_id"];
        NSString *contentID = [rs stringForColumn:@"api_content_id"];
        
        if (rootID) {
            [arrayOfRootID addObject:rootID];
        }
        if (contentID) {
            [arrayOfContentID addObject:contentID];
        }
    }
    [rs close];
    [self closeDatabase];

    for (NSString *contentID in arrayOfContentID) {

        
        [self removeCollectionWithContentID:contentID];
    }

    for (NSString *rootID in arrayOfRootID) {

        
        [self removeStoreCollectionByRootID:rootID];
    }
    
    return (int)arrayOfRootID.count;
}

- (int)preventUpdatingOrphaned {


    NSMutableArray *arrayOfRootID = [NSMutableArray new];
    NSMutableArray *arrayOfContentID = [NSMutableArray new];

    FMResultSet *rs = [self executeQueryWithName:@"get_orphaned_stored"];
    while ([rs next]) {
        
        NSString *rootID = [rs stringForColumn:@"root_id"];
        NSString *contentID = [rs stringForColumn:@"api_content_id"];
        
        if (rootID) {
            [arrayOfRootID addObject:rootID];
        }
        if (contentID) {
            [arrayOfContentID addObject:contentID];
        }
    }
    [rs close];
    [self closeDatabase];

    for (NSString *contentID in arrayOfContentID) {

        
        [self removeCollectionWithContentID:contentID];
    }

    for (NSString *rootID in arrayOfRootID) {

        
        [self executeNonQueryWithName:@"prevent_updating_removed_collections", rootID];
    }
    
    return (int)arrayOfRootID.count;
}

- (EPCollectionStatus)updateCollection:(id)collection {
    if (!collection || ![collection isKindOfClass:[NSDictionary class]]) {
        return EPCollectionStatusNone;
    }

    NSString *c_rootID = collection[@"md_content_id"];
    NSString *c_contentID = createContentID(c_rootID, collection[@"md_version"]);
    collection[kRootIDDictionaryKey] = c_rootID;
    collection[kContentIDDictionaryKey] = c_contentID;

    EPCollectionStatus status = EPCollectionStatusNone;

    if (![self storeCollectionExistsObjectWithRootID:c_rootID]) {

        [self storeCollectionAddRootID:c_rootID];

        [self addCollection:collection];

        [self storeCollectionSetApiContentID:c_contentID forRootID:c_rootID];

        [self markCollectionInApiByRootID:c_rootID];

        status = EPCollectionStatusAdded;
    }

    else {

        [self markCollectionInApiByRootID:c_rootID];

        NSDictionary *storeCollection = [self storeCollectionForRootID:c_rootID];

        id x_apiContentID = storeCollection[@"api_content_id"];
        NSString *x_apiContentID_str = [NSString stringWithFormat:@"%@", x_apiContentID];

        if (x_apiContentID == [NSNull null] || [EPCollection compareContentID:c_contentID toContentID:x_apiContentID_str] == NSOrderedDescending) {

            [self addCollection:collection];

            [self storeCollectionSetApiContentID:c_contentID forRootID:c_rootID];

            NSString *x_storeContentID    = [NSString stringWithFormat:@"%@", storeCollection[@"store_content_id"]];
            NSString *x_tmpStoreContentID = [NSString stringWithFormat:@"%@", storeCollection[@"tmp_store_id"]];

            if (![x_apiContentID_str isEqualToString:x_storeContentID] && ![x_apiContentID_str isEqualToString:x_tmpStoreContentID]) {

                [self removeCollectionWithContentID:x_apiContentID_str];
                
                status = EPCollectionStatusAddedAndRemoved;
            }

            else {
                status = EPCollectionStatusAdded;
            }
        }
        else {

            status = EPCollectionStatusSkipped;

            @try {
                
                NSString *coverUrl = @"";
                if (![NSObject isNullOrEmpty:collection[@"covers"]]) {
                    NSArray *covers = collection[@"covers"];
                    coverUrl = [self chooseBestFitCover:covers];
                    
                    NSURL *coverURL = [EPURL URLWithHost:API_BASE andResource:coverUrl];
                    [self downloadCoverForContentID:collection[kContentIDDictionaryKey] fromURL:coverURL];
                }
            }
            @catch (NSException *exception) {

            }

            @try {
                
                if (![NSObject isNullOrEmpty:collection[@"app_version_ios"]]) {
                    NSString *app_version = collection[@"app_version_ios"];
                    [self addAppVersion:app_version andContentID:collection[kContentIDDictionaryKey]];
                }
            }
            @catch (NSException *exception) {

            }
        }
    }
    
    return status;
}

- (void)removeStoreCollectionByRootID:(NSString *)rootID {
    [self executeNonQueryWithName:@"remove_store_collection", rootID];
}

- (NSDictionary *)storeCollectionForRootID:(NSString *)rootID {
    NSDictionary *result = nil;
    FMResultSet *rs = [self executeQueryWithName:@"get_raw_store_collection",
        rootID
    ];
    if ([rs next]) {
        result = [rs resultDictionary];
    }
    [rs close];
    [self closeDatabase];
    
    return result;
}

- (BOOL)storeCollectionExistsObjectWithRootID:(NSString *)rootID {
    NSString *x_rootID = [self stringForName:@"get_root_id_from_store_collections", rootID];
    return x_rootID != nil;
}

- (void)storeCollectionAddRootID:(NSString *)rootID {
    [self executeNonQueryWithName:@"add_root_id_to_store_collection", rootID];
}

- (void)storeCollectionSetApiContentID:(NSString *)contentID forRootID:(NSString *)rootID {
    [self executeNonQueryWithName:@"set_api_content_id_in_store_collection", contentID, rootID];
}

- (NSString *)chooseBestFitCover:(NSArray *)covers {
    NSString *coverUrl = @"";
    for (id cover in covers) {
        NSString *format = cover[@"format"];
        if ([NSObject isNull:format]) {
            continue;
        }
        format = [format uppercaseString];
        
        NSString *url = cover[@"url"];


        coverUrl = url;

        if ([UIDevice currentDevice].isIPad) {
            if ([format isEqualToString:@"PNG-480"] || [format isEqualToString:@"JPG-480"] ) {
                break;
            }
        }
        else {
            if ([format isEqualToString:@"PNG-480"] || [format isEqualToString:@"JPG-480"] ) {
                break;
            }
        }
    }
    return coverUrl;
}

- (void)addCollection:(id)collection {
    @try {
        
        if (!collection || ![collection isKindOfClass:[NSDictionary class]]) {
            return;
        }

        NSArray *keys = @[
            @"formats"




        ];
        
        for (NSString *key in keys) {
            if ([NSObject isNullOrEmpty:collection[key]]) {

                
                return;
            }
        }
        
        keys = @[
            @"md_content_id",
            @"md_version",
            @"md_title"
        ];
        
        for (NSString *key in keys) {
            if ([NSObject isNullOrEmpty:collection[key]]) {

                
                return;
            }
        }

        NSString *school_id = @"0";
        if (![NSObject isNullOrEmpty:collection[@"md_school"]]) {
            id school = collection[@"md_school"];
            school[kContentIDDictionaryKey] = collection[kContentIDDictionaryKey];
            [self addSchool:school];
            school_id = school[@"id"];
        }

        NSString* subtitleText  = @"";
        if (![NSObject isNullOrEmpty:collection[@"md_subtitle"]]) {
            subtitleText = collection[@"md_subtitle"];
        }

        NSString *subject_id = @"0";
        if (![NSObject isNullOrEmpty:collection[@"md_subject"]]) {
            id subject= collection[@"md_subject"];
            subject[kContentIDDictionaryKey] = collection[kContentIDDictionaryKey];
            [self addSubject:subject];
            subject_id = subject[@"id"];
            if (subtitleText.length == 0) {
                if ([subject isKindOfClass:[NSDictionary class]]) {
                    subtitleText = subject[@"md_name"];
                }
            }
        }

        NSString *coverUrl = @"";
        if (![NSObject isNullOrEmpty:collection[@"covers"]]) {
            NSArray *covers = collection[@"covers"];
            coverUrl = [self chooseBestFitCover:covers];
        }

        [self executeNonQueryWithName:@"insert_collection",
            collection[kRootIDDictionaryKey],
            collection[kContentIDDictionaryKey],
            collection[@"md_title"],
            collection[@"md_abstract"],
            school_id,
            subject_id,
            collection[@"md_published"],
            collection[@"md_version"],
            collection[@"ep_version"],
            collection[@"md_language"],
            collection[@"md_license"],
            collection[@"md_created"],
            collection[@"md_revised"],
            coverUrl,
            coverUrl,
            collection[@"link"],
            @NO,
            collection[@"ep_recipient"],
            collection[@"ep_content_status"],
            collection[@"ep_cover_type"],
            collection[@"md_institution"],
            subtitleText,
            collection[@"ep_stylesheet"]
        ];

        if (![NSObject isNullOrEmpty:collection[@"md_authors"]]) {
            NSArray *authors = collection[@"md_authors"];
            for (id author in authors) {
                author[kContentIDDictionaryKey] = collection[kContentIDDictionaryKey];
                [self addAuthor:author];
            }
        }

        NSArray *formats = collection[@"formats"];
        for (id format in formats) {
            format[kContentIDDictionaryKey] = collection[kContentIDDictionaryKey];
            [self addFormat:format];
        }

        if (![NSObject isNullOrEmpty:collection[@"app_version_ios"]]) {
            NSString *app_version = collection[@"app_version_ios"];
            [self addAppVersion:app_version andContentID:collection[kContentIDDictionaryKey]];
        }

        @try {
            NSURL *coverURL = [EPURL URLWithHost:API_BASE andResource:coverUrl];
            [self downloadCoverForContentID:collection[kContentIDDictionaryKey] fromURL:coverURL];
        }
        @catch (NSException *exception) {

        }
    }
    @catch (NSException *exception) {



        return;
    }
}

- (void)addAuthor:(id)author {
    if (!author || ![author isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString* fullName = author[@"md_full_name"];
    if ([fullName length] ==0) {
        fullName = author[@"full_name"];
    }
    
    if ([author objectForKey:@"role_type"]) {
        [self executeNonQueryWithName:@"insert_collection_author",
             author[kContentIDDictionaryKey],
             author[@"id"],
             author[@"role_type"],
             author[@"md_surname"],
             author[@"md_institution"],
             author[@"order"],
             fullName
         ];
    }
    else {
        [self executeNonQueryWithName:@"insert_collection_author",
            author[kContentIDDictionaryKey],
            author[@"id"],
            @"Autorzy",
            author[@"md_surname"],
            author[@"md_institution"],
            @"",
            author[@"md_full_name"]
        ];
    }
}

- (void)addFormat:(id)format {
    if (!format || ![format isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self executeNonQueryWithName:@"insert_collection_format",
        format[kContentIDDictionaryKey],
        format[@"url"],
        format[@"format"],
        format[@"size"]
    ];
}

- (void)addKeyword:(id)keyword {
    if (!keyword || ![keyword isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self executeNonQueryWithName:@"insert_collection_keyword",
        keyword[kContentIDDictionaryKey],
        keyword[@"name"]
    ];
}

- (void)addSchool:(id)school {
    if (!school || ![school isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *education_level = [NSString stringWithFormat:@"%@", school[@"md_education_level"]];
    int class = [[NSString stringWithFormat:@"%@", school[@"ep_class"]] intValue];

    NSNumber *education_order = @1000000;
    if ([education_level isEqualToString:@"I"] || [education_level isEqualToString:@"II"]) {
        if (class == 1) {
            education_order = @1;
        }
        else if (class == 2) {
            education_order = @2;
        }
        else if (class == 3) {
            education_order = @3;
        }
        else if (class == 4) {
            education_order = @4;
        }
        else if (class == 5) {
            education_order = @5;
        }
        else if (class == 6) {
            education_order = @6;
        }
    }
    else if ([education_level isEqualToString:@"III"]) {
        if (class == 1) {
            education_order = @7;
        }
        else if (class == 2) {
            education_order = @8;
        }
        else if (class == 3) {
            education_order = @9;
        }
    }
    else if ([education_level isEqualToString:@"IV"]) {
        if (class == 1) {
            education_order = @10;
        }
        else if (class == 2) {
            education_order = @11;
        }
        else if (class == 3) {
            education_order = @12;
        }
        else if (class == 4) {
            education_order = @13;
        }
    }

    [self executeNonQueryWithName:@"insert_collection_school",
        school[kContentIDDictionaryKey],
        school[@"id"],
        education_level,
        @(class),
        education_order
    ];
}

- (void)addSubject:(id)subject {
    if (!subject || ![subject isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSString* orderingInsideJsonField = @"1000";
    if (subject[@"ordering"]) {
        orderingInsideJsonField = subject[@"ordering"];
    }

    [self executeNonQueryWithName:@"insert_collection_subject",
        subject[kContentIDDictionaryKey],
        subject[@"id"],
        subject[@"md_name"],
        orderingInsideJsonField
    ];
}

- (void)addAppVersion:(NSString *)appVersion andContentID:(NSString *)contentID {
    double dAppVersion = [appVersion doubleValue];
    if (dAppVersion > 0) {
        [self.configuration.collectionStateModel setAppVersion:appVersion forContentID:contentID];
    }
}

- (void)downloadCoverForContentID:(NSString *)contentID fromURL:(NSURL *)url {
#if DEBUG_NO_NETWORK

    return;
#endif
    
#ifdef DEBUG_BAD_NETWORK_LAG

    [NSThread sleepForTimeInterval:DEBUG_BAD_NETWORK_LAG];

#endif

    NSString *imagePath = [self.configuration.pathModel pathForCover:[NSString stringWithFormat:@"%@", contentID]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {

        
        return;
    }

    EPDownloadFileUtil *downloader = [EPDownloadFileUtil new];
    downloader.requestTimeout = kTimeIntervalForCoverDownload;
    BOOL loaded = [downloader syncDownloadFileWithURL:url storeToPath:imagePath];
    if (loaded) {

    }
    else {

    }
}

- (void)removeCoverForContentID:(NSString *)contentID {

    NSString *imagePath = [self.configuration.pathModel pathForCover:[NSString stringWithFormat:@"%@", contentID]];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error]) {

        }
    }
}

@end

@implementation EPDownloadModel (DownloadTextbook)

- (EPStoreCollection *)storeCollectionWithRootID:(NSString *)rootID {
    @synchronized (self) {
        
        
        NSString* formatName = [self getBestFitFormatForRootId:rootID];
        
        EPStoreCollection *storeCollection = nil;

        FMResultSet *rs = [self executeQueryWithName:@"get_store_textbook", rootID, formatName];
        
        if ([rs next]) {
            storeCollection = [EPStoreCollection new];

            storeCollection.rootID = [rs stringForColumn:@"root_id"];

            id apiContentID = [rs objectForColumnName:@"api_content_id"];
            if (apiContentID == [NSNull null]) {
                storeCollection.apiContentID = nil;
            }
            else {
                storeCollection.apiContentID = [rs stringForColumn:@"api_content_id"];
            }

            storeCollection.apiSize = [rs longLongIntForColumn:@"api_size"];

            id storeContentID = [rs objectForColumnName:@"store_content_id"];
            id storeTmpID = [rs objectForColumnName:@"store_tmp_id"];

            if (storeContentID == [NSNull null] && storeTmpID == [NSNull null]) {

                storeCollection.storeUrl = [rs stringForColumn:@"store_url"];
                storeCollection.state = EPTextbookStateTypeToDownload;
            }
            else {

                storeCollection.storeCompleted = [rs boolForColumn:@"store_completed"];

                if (storeCollection.storeCompleted == NO) {

                    storeCollection.storeTmpID = [rs stringForColumn:@"store_tmp_id"];
                    storeCollection.storeUrl = [rs stringForColumn:@"store_url"];

                    if (storeContentID == [NSNull null]) {
                        
                        storeCollection.state = EPTextbookStateTypeDownloading;
                    }

                    else {

                        storeCollection.storeContentID = [rs stringForColumn:@"store_content_id"];

                        storeCollection.storePath = [rs stringForColumn:@"store_path"];
                        storeCollection.state = EPTextbookStateTypeUpdating;
                    }
                }

                else {

                    storeCollection.storeContentID = [rs stringForColumn:@"store_content_id"];
                    
                    NSString *api_id = [storeCollection.apiContentID copy];
                    NSString *store_id = [storeCollection.storeContentID copy];
                    
                    if (!api_id) {
                        api_id = @"0";
                    }
                    if (!store_id) {
                        store_id = @"0";
                    }
                    
#if DEBUG_TURN_OFF_UPDATES
                    api_id = @"0";
                    store_id = @"0";
#endif

                    if ([EPCollection compareContentID:api_id toContentID:store_id] == NSOrderedDescending) {


                        storeCollection.storePath = [rs stringForColumn:@"store_path"];

                        storeCollection.storeUrl = [rs stringForColumn:@"store_url"];
                        storeCollection.state = EPTextbookStateTypeToUpdate;
                    }

                    else {

                        storeCollection.storePath = [rs stringForColumn:@"store_path"];
                        storeCollection.state = EPTextbookStateTypeNormal;
                    }
                }
            }
        }

        [rs close];
        [self closeDatabase];
        
#if DEBUG_OBJECTS

#endif
        
        return storeCollection;
    }
}

- (void)setTextbookAsToDownloadWithRootID:(NSString *)rootID {
    @synchronized (self) {

        NSDictionary *storeCollection = nil;

        FMResultSet *rs = [self executeQueryWithName:@"get_raw_store_collection",
            rootID
        ];
        if ([rs next]) {
            storeCollection = [rs resultDictionary];
        }

        [rs close];
        [self closeDatabase];

        NSString *x_apiContentID = nil;
        NSString *x_storeContentID = nil;
        NSString *x_storeTmpID = nil;
        
        if (storeCollection[@"api_content_id"] != [NSNull null]) {
            x_apiContentID = storeCollection[@"api_content_id"];
        }
        if (storeCollection[@"store_content_id"] != [NSNull null]) {
            x_storeContentID = storeCollection[@"store_content_id"];
        }
        if (storeCollection[@"tmp_content_id"] != [NSNull null]) {
            x_storeTmpID = storeCollection[@"tmp_content_id"];
        }

        if (x_apiContentID) {
            if (x_storeContentID && ![x_storeContentID isEqualToString:x_apiContentID]) {
                [self.configuration.downloadModel removeCollectionWithContentID:x_storeContentID];
            }
            if (x_storeTmpID && ![x_storeTmpID isEqualToString:x_apiContentID]) {
                [self.configuration.downloadModel removeCollectionWithContentID:x_storeTmpID];
            }
        }

        [self executeNonQueryWithName:@"store_remove_textbook_by_id",
            rootID
        ];
        
    }
}

- (void)setTextbookAsDownloadingWithRootID:(NSString *)rootID andStoreTmpID:(NSString *)storeTmpID andStoreURL:(NSString *)storeURL {
    @synchronized (self) {

        [self executeNonQueryWithName:@"store_set_textbook_downloading",
            storeTmpID, @NO, storeURL, rootID
        ];
    }
}

- (void)setTextbookAsNormalWithRootID:(NSString *)rootID andStoreContentID:(NSString *)storeContentID andStorePath:(NSString *)storePath {
    @synchronized (self) {

        NSDictionary *storeCollection = nil;

        FMResultSet *rs = [self executeQueryWithName:@"get_raw_store_collection",
            rootID
        ];
        if ([rs next]) {
            storeCollection = [rs resultDictionary];
        }

        [rs close];
        [self closeDatabase];

        NSString *x_apiContentID = nil;

        NSString *x_storeTmpID = nil;
        
        if (storeCollection[@"api_content_id"] != [NSNull null]) {
            x_apiContentID = storeCollection[@"api_content_id"];
        }
        if (storeCollection[@"store_content_id"] != [NSNull null]) {

        }
        if (storeCollection[@"tmp_content_id"] != [NSNull null]) {
            x_storeTmpID = storeCollection[@"tmp_content_id"];
        }

        if (x_apiContentID) {
            if (x_storeTmpID && ![x_storeTmpID isEqualToString:x_apiContentID]) {
                [self.configuration.downloadModel removeCollectionWithContentID:x_storeTmpID];
            }
        }

        [self executeNonQueryWithName:@"store_set_textbook_normal",
            storeContentID, @YES, storePath, rootID
        ];
        
    }
}

- (void)setTextbookAsUpdatingWithRootID:(NSString *)rootID andStoreTmpID:(NSString *)storeTmpID andStoreURL:(NSString *)storeURL {
    @synchronized (self) {

        [self executeNonQueryWithName:@"store_set_textbook_updating",
            storeTmpID, @NO, storeURL, rootID
        ];
    }
}

- (EPDownloadTextbookProxy *)nextProxyFromDownloadQueue {
    @synchronized (self) {

        EPDownloadTextbookProxy *proxy = nil;
        NSString *rootID = nil;

        FMResultSet *rs = [self executeQueryWithName:@"get_first_store_textbook_root_id_for_download"];
        if ([rs next]) {
            rootID = [rs stringForColumn:@"root_id"];
        }

        [rs close];
        [self closeDatabase];

        if (rootID) {
            proxy = [self.configuration.downloadUtil downloadTextbookProxyForRootID:rootID];
        }
        
        return proxy;
    }
}

@end
