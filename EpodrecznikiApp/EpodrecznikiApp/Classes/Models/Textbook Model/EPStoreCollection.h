







#import <Foundation/Foundation.h>
#import "EPMetadata.h"

@interface EPStoreCollection : EPMetadata

@property (nonatomic) unsigned long long apiSize;
@property (nonatomic, copy) NSString *storeTmpID;
@property (nonatomic) BOOL storeCompleted;
@property (nonatomic, copy) NSString *storeUrl;
@property (nonatomic, copy) NSString *storePath;
@property (nonatomic) EPTextbookStateType state;

@end
