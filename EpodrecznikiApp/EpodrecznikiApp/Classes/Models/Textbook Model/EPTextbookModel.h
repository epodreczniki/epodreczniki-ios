







#import <Foundation/Foundation.h>
#import "EPDatabaseModel.h"
#import "EPMetadata.h"

@interface EPTextbookModel : EPDatabaseModel

- (NSArray *)arrayOfTextbooksForTablet:(BOOL)tablet;
- (EPCollection *)textbookForContentID:(NSString *)contentID;
- (EPMetadata *)metadataWithRootID:(NSString *)rootID;
- (EPCollection *)collectionWithContentID:(NSString *)contentID;
- (NSString *)shortStringFromEducationLevel:(NSString *)educationLevel;

@end
