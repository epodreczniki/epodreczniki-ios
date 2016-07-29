







#import "EPCreatorsRole.h"
#import "EPTextbookModel.h"

@interface EPTextbookModel ()

@property (nonatomic, strong) NSDictionary *shortSchools;

@end

@implementation EPTextbookModel

#pragma mark - Lifecycle

- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    if (self) {
        
        NSData *data = [NSData dataWithContentsOfFile:[aConfiguration.pathModel pathForLocalShortSchoolsFile]];
        self.shortSchools = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
    return self;
}

#pragma mark - Public methods

- (NSArray *)arrayOfTextbooksForTablet:(BOOL)tablet {
    @synchronized (self) {
        NSMutableArray *result = [NSMutableArray new];

        FMResultSet *rs = nil;
        if (tablet) {
            rs = [self executeQueryWithName:@"get_textbooks_for_tablets"];
        }
        else {
            rs = [self executeQueryWithName:@"get_textbooks_for_phones"];
        }
        while ([rs next]) {

            EPCollection *collection = [EPCollection new];
            collection.rootID = [rs stringForColumn:@"root_id"];
            collection.contentID = [rs stringForColumn:@"content_id"];
            collection.textbookTitle = [rs stringForColumn:@"title"];
            collection.textbookSubtitle = [rs stringForColumn:@"subtitle"];
            collection.textbookCoverLink = [rs stringForColumn:@"cover"];
            collection.textbookCoverThumbLink = [rs stringForColumn:@"cover_thumb"];
            
            collection.schoolEducationLevel = [rs stringForColumn:@"education_level"];
            collection.schoolClass = [rs stringForColumn:@"class"];
            collection.subjectID = [rs stringForColumn:@"subject_id"];
            collection.subjectName = [rs stringForColumn:@"subject_name"];

            [result addObject:collection];
        }

        [rs close];
        [self closeDatabase];
        
        return result;
    }
}

- (EPCollection *)textbookForContentID:(NSString *)contentID {
    @synchronized (self) {
        EPCollection *collection = nil;

        FMResultSet *rs = [self executeQueryWithName:@"textbook_for_content_id", contentID];
        
        if ([rs next]) {

            collection = [EPCollection new];
            collection.rootID = [rs stringForColumn:@"root_id"];
            collection.contentID = [rs stringForColumn:@"content_id"];
            collection.textbookTitle = [rs stringForColumn:@"title"];
            collection.textbookSubtitle = [rs stringForColumn:@"subtitle"];
            collection.textbookCoverLink = [rs stringForColumn:@"cover"];
            collection.textbookCoverThumbLink = [rs stringForColumn:@"cover_thumb"];
            
            collection.schoolEducationLevel = [rs stringForColumn:@"education_level"];
            collection.schoolClass = [rs stringForColumn:@"class"];
            collection.subjectID = [rs stringForColumn:@"subject_id"];
            collection.subjectName = [rs stringForColumn:@"subject_name"];
        }

        [rs close];
        [self closeDatabase];
        
        return collection;
    }
}

- (EPMetadata *)metadataWithRootID:(NSString *)rootID {
    @synchronized (self) {
        
        EPMetadata *metadata = nil;

        FMResultSet *rs = [self executeQueryWithName:@"get_raw_store_collection", rootID];
        if ([rs next]) {
            
            metadata = [EPMetadata new];
            metadata.rootID = [rs stringForColumn:@"root_id"];
            metadata.storeContentID = [rs stringForColumn:@"store_content_id"];
            metadata.apiContentID = [rs stringForColumn:@"api_content_id"];
        }
        
        [rs close];
        [self closeDatabase];
        
        return metadata;
    }
}

- (void)setAuthors:(NSString *)contentID collection:(EPCollection *)collection {
    @try {

        FMResultSet *rs;
        rs = [self executeQueryWithName:@"get_collection_authors_with_roles", contentID];
        
        NSMutableArray *addedRoles = [NSMutableArray new];
        NSMutableArray *rolesWithAuthors = [NSMutableArray new];
        while ([rs next]) {
            NSString* roleName = @"Autorzy";
            NSString* ordering = [rs stringForColumn:@"email"];
            if(ordering && ordering.length > 0) {
                roleName = [rs stringForColumn:@"role_type"];
            }
            NSString* personName = [rs stringForColumn:@"full_name"];
            EPCreatorsRole* creatorsRole;
            if ([addedRoles containsObject:roleName] == NO) {
                [addedRoles addObject:roleName];
                creatorsRole = [EPCreatorsRole new];
                creatorsRole.roleName = roleName;
                creatorsRole.names = [NSMutableArray new];
                [rolesWithAuthors addObject:creatorsRole];
            }
            else {
                NSUInteger indexOfTheRole = [addedRoles indexOfObject:roleName];
                creatorsRole = rolesWithAuthors[indexOfTheRole];
            }
            [creatorsRole.names addObject:personName];
        }
        collection.authorWithRoles = [NSArray arrayWithArray:rolesWithAuthors];

        [rs close];
        [self closeDatabase];
    }
    @catch (NSException *exception) {

    }
}

- (EPCollection *)collectionWithContentID:(NSString *)contentID {
    @synchronized (self) {
        
        EPCollection *collection = nil;
        
        NSString* formatName = [self getBestFitFormatForCollection:contentID];

        FMResultSet *rs = [self executeQueryWithName:@"get_collection", contentID, formatName];
        
        if ([rs next]) {
            collection = [EPCollection new];
            collection.rootID = [rs stringForColumn:@"root_id"];
            collection.contentID = [rs stringForColumn:@"content_id"];
            
            collection.textbookTitle = [rs stringForColumn:@"title"];
            collection.textbookAbstract = [rs stringForColumn:@"abstract"];
            collection.textbookPublished = [rs boolForColumn:@"published"];
            collection.textbookMdVersion = [rs stringForColumn:@"md_version"];
            collection.textbookEpVersion = [rs stringForColumn:@"ep_version"];
            collection.textbookLanguage = [rs stringForColumn:@"language"];
            collection.textbookLicense = [rs stringForColumn:@"license"];


            collection.textbookCoverLink = [rs stringForColumn:@"cover"];
            collection.textbookCoverThumbLink = [rs stringForColumn:@"cover_thumb"];
            collection.textbookLink = [rs stringForColumn:@"link"];
            collection.textbookForTabletsOnly = [rs boolForColumn:@"for_tablets_only"];
            collection.textbookRecipient = [rs stringForColumn:@"recipient"];
            collection.textbookContentStatus = [rs stringForColumn:@"content_status"];
            collection.textbookCoverType = [rs stringForColumn:@"cover_type"];
            collection.textbookSubtitle = [rs stringForColumn:@"subtitle"];
            collection.textbookInstitution = [rs stringForColumn:@"institution"];
            collection.textbookStylesheet = [rs stringForColumn:@"stylesheet"];
            
            collection.subjectID = [rs stringForColumn:@"subject_id"];
            collection.subjectName = [rs stringForColumn:@"subject_name"];
            collection.schoolClass = [rs stringForColumn:@"class"];
            collection.schoolEducationLevel = [rs stringForColumn:@"education_level"];
            collection.formatZipLink = [rs stringForColumn:@"format_zip_link"];
            collection.formatZipSize = [rs longLongIntForColumn:@"format_zip_size"];
        }

        [rs close];
        [self closeDatabase];
        
        [self setAuthors:contentID collection:collection];
        
        return collection;
    }
}

- (NSString *)shortStringFromEducationLevel:(NSString *)educationLevel {
    if ([NSObject isNullOrEmpty:educationLevel]) {
        return @"Nieznana";
    }
    
    NSString *shortString = self.shortSchools[educationLevel];
    return shortString;
}

#pragma mark - Private methods

- (NSDate *)dateFromString:(NSString *)string {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [df dateFromString:string];
    
    return date;
}

@end
