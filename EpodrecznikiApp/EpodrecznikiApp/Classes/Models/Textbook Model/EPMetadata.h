







#import <Foundation/Foundation.h>
#import "EPCollection.h"

@interface EPMetadata : NSObject

@property (nonatomic, copy) NSString *rootID;
@property (nonatomic, copy) NSString *storeContentID;
@property (nonatomic, copy) NSString *apiContentID;


@property (nonatomic, readonly) NSString *actualContentID;

@end
