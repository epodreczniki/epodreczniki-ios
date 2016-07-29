







#import <Foundation/Foundation.h>

@interface EPCollection : NSObject

@property (nonatomic, copy) NSString *rootID;
@property (nonatomic, copy) NSString *contentID;


@property (nonatomic, copy) NSString *textbookTitle;
@property (nonatomic, copy) NSString *textbookAbstract;
@property (nonatomic) BOOL textbookPublished;
@property (nonatomic, copy) NSString *textbookMdVersion;
@property (nonatomic, copy) NSString *textbookEpVersion;
@property (nonatomic, copy) NSString *textbookLanguage;
@property (nonatomic, copy) NSString *textbookLicense;
@property (nonatomic, copy) NSDate *textbookCreated;
@property (nonatomic, copy) NSDate *textbookRevised;
@property (nonatomic, copy) NSString *textbookCoverLink;
@property (nonatomic, copy) NSString *textbookCoverThumbLink;
@property (nonatomic, copy) NSString *textbookLink;
@property (nonatomic) BOOL textbookForTabletsOnly;
@property (nonatomic, copy) NSString *textbookRecipient;
@property (nonatomic, copy) NSString *textbookContentStatus;
@property (nonatomic, copy) NSString *textbookCoverType;
@property (nonatomic, copy) NSString *textbookSubtitle;
@property (nonatomic, copy) NSString *textbookInstitution;
@property (nonatomic, copy) NSString *textbookStylesheet;


@property (nonatomic, copy) NSString *subjectID;
@property (nonatomic, copy) NSString *subjectName;


@property (nonatomic, copy) NSString *schoolClass;
@property (nonatomic, copy) NSString *schoolEducationLevel;


@property (nonatomic, copy) NSString *authorMain;
@property (nonatomic, strong) NSArray *authorAll;
@property (nonatomic, strong) NSArray *authorWithRoles;


@property (nonatomic, copy) NSString *formatZipLink;
@property (nonatomic) unsigned long long formatZipSize;

+ (NSComparisonResult)compareContentID:(NSString *)x toContentID:(NSString *)y;

@end
