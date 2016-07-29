







#import "FMResultSet+FMResultSet_Epodreczniki.h"

@implementation FMResultSet (FMResultSet_Epodreczniki)

- (NSNumber *)numberForColumn:(NSString *)columnName {
    NSString *str = [self stringForColumn:columnName];
    return [NSNumber numberWithInt:[str intValue]];
}

- (NSNumber *)numberForColumnIndex:(int)columnIdx {
    NSString *str = [self stringForColumnIndex:columnIdx];
    return [NSNumber numberWithFloat:[str floatValue]];
}

@end
