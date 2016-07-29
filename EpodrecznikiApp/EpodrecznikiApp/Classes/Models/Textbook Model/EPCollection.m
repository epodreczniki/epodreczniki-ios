







#import "EPCollection.h"

@implementation EPCollection

- (void)dealloc {
    self.rootID = nil;
    self.contentID = nil;
    
    self.textbookTitle = nil;
    self.textbookAbstract = nil;
    self.textbookMdVersion = nil;
    self.textbookEpVersion = nil;
    self.textbookLanguage = nil;
    self.textbookLicense = nil;
    self.textbookCreated = nil;
    self.textbookRevised = nil;
    self.textbookCoverLink = nil;
    self.textbookCoverThumbLink = nil;
    self.textbookLink = nil;
    self.textbookRecipient = nil;
    self.textbookContentStatus = nil;
    self.textbookCoverType = nil;
    self.textbookSubtitle = nil;
    self.textbookInstitution = nil;
    self.textbookStylesheet = nil;
    
    self.subjectID = nil;
    self.subjectName = nil;
    self.schoolClass = nil;
    self.schoolEducationLevel = nil;
    self.authorMain = nil;
    self.authorAll = nil;
    self.formatZipLink = nil;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@""];
    [string appendString:@"<EPCollection> {\n"];
    [string appendFormat:@"\trootID: %@,\n", self.rootID];
    [string appendFormat:@"\tcontentID: %@,\n", self.contentID];
    
    [string appendFormat:@"\ttextbookTitle: %@,\n", self.textbookTitle];
    [string appendFormat:@"\ttextbookAbstract: %@,\n", self.textbookAbstract];
    [string appendFormat:@"\ttextbookPublished: %d,\n", self.textbookPublished];
    [string appendFormat:@"\ttextbookMdVersion: %@,\n", self.textbookMdVersion];
    [string appendFormat:@"\ttextbookEpVersion: %@,\n", self.textbookEpVersion];
    [string appendFormat:@"\ttextbookLanguage: %@,\n", self.textbookLanguage];
    [string appendFormat:@"\ttextbookLicense: %@,\n", self.textbookLicense];
    [string appendFormat:@"\ttextbookCreated: %@,\n", self.textbookCreated];
    [string appendFormat:@"\ttextbookRevised: %@,\n", self.textbookRevised];
    [string appendFormat:@"\ttextbookCoverLink: %@,\n", self.textbookCoverLink];
    [string appendFormat:@"\ttextbookCoverThumbLink: %@,\n", self.textbookCoverThumbLink];
    [string appendFormat:@"\ttextbookLink: %@,\n", self.textbookLink];
    [string appendFormat:@"\ttextbookForTabletsOnly: %d,\n", self.textbookForTabletsOnly];
    [string appendFormat:@"\ttextbookRecipient: %@,\n", self.textbookRecipient];
    [string appendFormat:@"\ttextbookContentStatus: %@,\n", self.textbookContentStatus];
    [string appendFormat:@"\ttextbookCoverType: %@,\n", self.textbookCoverType];
    [string appendFormat:@"\ttextbookSubtitle: %@,\n", self.textbookSubtitle];
    [string appendFormat:@"\ttextbookInstitution: %@,\n", self.textbookInstitution];
    [string appendFormat:@"\ttextbookStylesheet: %@,\n", self.textbookStylesheet];
    
    [string appendFormat:@"\tsubjectID: %@,\n", self.subjectID];
    [string appendFormat:@"\tsubjectName: %@,\n", self.subjectName];
    [string appendFormat:@"\tschoolClass: %@,\n", self.schoolClass];
    [string appendFormat:@"\tschoolEducationLevel: %@,\n", self.schoolEducationLevel];
    [string appendFormat:@"\tauthorMain: %@,\n", self.authorMain];
    [string appendFormat:@"\tauthorAll: %@,\n", [self.authorAll componentsJoinedByString:@", "]];
    [string appendFormat:@"\tformatZipLink: %@,\n", self.formatZipLink];
    [string appendFormat:@"\tformatZipSize: %lld,\n", self.formatZipSize];
    [string appendString:@"}"];
    
    return string;
}

#pragma mark - Class methods

+ (NSComparisonResult)compareContentID:(NSString *)x toContentID:(NSString *)y {
    if (!x && !y) {
        return NSOrderedSame;
    }
    if (!x) {
        return NSOrderedAscending;
    }
    if (!y) {
        return NSOrderedDescending;
    }

    NSArray *xArray = [x componentsSeparatedByString:@"_"];
    NSArray *yArray = [y componentsSeparatedByString:@"_"];
    
    if (xArray.count != 2 && yArray.count != 2) {
        return NSOrderedSame;
    }
    if (xArray.count != 2) {
        return NSOrderedAscending;
    }
    if (yArray.count != 2) {
        return NSOrderedDescending;
    }

    CGFloat xFloat = [[xArray objectAtIndex:1] floatValue];
    CGFloat yFloat = [[yArray objectAtIndex:1] floatValue];

    NSNumber *xNumber = @(xFloat);
    NSNumber *yNumber = @(yFloat);
    
    return [xNumber compare:yNumber];
}

@end
