







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

@interface EPTextbookUtil : EPConfigurableObject

- (void)fetchArrayWithTextbookDataAndCompletion:(void (^)(NSArray *arrayOfData))completion;
- (EPCollection *)collectionForRootID:(NSString *)rootID;
- (BOOL)textbookRequiresAdvancedReaderWithProxy:(EPDownloadTextbookProxy *)proxy;
- (BOOL)textbookRequiresAdvancedReaderWithPath:(NSString *)textbookPath;


- (void)postTextbookDownloadWithProxy:(EPDownloadTextbookProxy *)proxy andDestination:(NSString *)destination;
- (void)postTextbookRemoveWithRootID:(NSString *)rootID andContentID:(NSString *)contentID;


- (NSString *)lastViewedPathForTextbookRootID:(NSString *)rootID;
- (void)setLastViewedPath:(NSString *)path forTextbookRootID:(NSString *)rootID;

- (EPPageItem *)lastViewedPageItemForTextbookRootID:(NSString *)rootID;
- (void)setLastViewedPageItem:(EPPageItem *)pageItem forTextbookRootID:(NSString *)rootID;

@end
