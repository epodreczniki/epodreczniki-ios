







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

@interface EPDatabaseModel : EPConfigurableObject

@property (nonatomic) sqlite_int64 lastInsertedRowId;

- (FMDatabase *)openDatabase;
- (void)closeDatabase;

@end

@interface EPDatabaseModel (ExecutingQueries)

- (FMResultSet *)executeQueryWithString:(NSString *)format, ...;
- (FMResultSet *)executeQueryWithName:(NSString *)name, ...;
- (int)executeNonQueryWithString:(NSString *)format, ...;
- (int)executeNonQueryWithName:(NSString *)name, ...;
- (long long)executeNonQueryWithNameAndGetId:(NSString *)name, ... ;
- (BOOL)boolForName:(NSString *)name, ...;
- (int)intForName:(NSString *)name, ...;
- (double)doubleForName:(NSString *)name, ...;
- (NSString *)stringForName:(NSString *)name, ...;
- (NSString *)getBestFitFormatForCollection:(NSString *)contentID;
- (NSString *)getBestFitFormatForRootId:(NSString *)rootId;

@end

@interface EPDatabaseModel (NamedQueries)

- (NSString *)queryForName:(NSString *)name;

@end
