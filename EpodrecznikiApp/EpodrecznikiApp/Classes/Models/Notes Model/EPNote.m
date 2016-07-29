







#import "EPNote.h"

@implementation EPNote 

- (NSDictionary*) proxyForJson
{
    return @{
             @"localNoteId" : [self.localNoteId stringValue],
             @"localUserId" : self.localUserId,
             @"handbookId" : self.handbookId,
             @"moduleId" : self.moduleId,
             @"pageId" : self.pageId,


             @"location" : [self jsonToDictionary:self.location],


             @"type" : self.type,





             };
}


- (NSDictionary*) jsonToDictionary:(NSString*)jsonString {
    
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    return jsonDict;
}

- (NSString*) asJsonString {
    @try {
        NSError *error;
        NSDictionary* dict = [self proxyForJson];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        return result;
    }
    @catch (NSException *exception) {

        return @"error";
    }
}

- (void)setAllIds:(EPPageItem *)pageItem withRootID:(NSString *)rootID {
    @try {
        self.pageId = pageItem.pageId;
        self.moduleId = pageItem.moduleId;
        
        EPCollection *collection = [[EPConfiguration activeConfiguration].textbookUtil collectionForRootID:rootID];
        if (!collection) {
            self.handbookId = @"1:1";
        }
        else {
            self.handbookId = convertContentIDToHandbookID(collection.contentID);
        }
        
        EPUserUtil *userUtil = [EPConfiguration activeConfiguration].userUtil;
        self.localUserId = [userUtil.user.userID stringValue];
        
        [self setInJsonField:@"pageItem" withValue:pageItem.stringFromPageItem];
    }
    @catch (NSException *exception) {

    }
}

- (void) setInJsonField:(NSString*)key withValue:(NSString*)value {
    NSError * error=nil;
    NSData * jsonData = [self.json dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary * parsedDataDict;
    if (jsonData == nil) {
        parsedDataDict = [NSMutableDictionary new];
    }
    else {
        parsedDataDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if (!parsedDataDict && error) {

        }
    }
    [parsedDataDict setValue:value forKey:key];
    
    NSData *changedJsonData = [NSJSONSerialization dataWithJSONObject:parsedDataDict options:0 error:&error];
    if (!changedJsonData && error) {

    }
    self.json = [[NSString alloc] initWithData:changedJsonData encoding:NSUTF8StringEncoding];
}

- (NSString*) getFromJsonField:(NSString*)key {
    NSString* res = @"";
    NSError * error=nil;
    NSData * jsonData = [self.json dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary * parsedDataDict;
    if (jsonData != nil) {
        parsedDataDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if (!parsedDataDict && error) {

        }
        res = [parsedDataDict valueForKey:key];
    }
    
    
    return res;
}

@end
