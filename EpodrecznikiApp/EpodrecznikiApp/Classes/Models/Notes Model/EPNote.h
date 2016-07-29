







#import <Foundation/Foundation.h>

@interface EPNote : NSObject




@property (assign) BOOL isBookmarkOnly;



@property (copy, nonatomic) NSNumber*  localNoteId;
@property (copy, nonatomic) NSString*  localUserId;
@property (copy, nonatomic) NSString*  handbookId;
@property (copy, nonatomic) NSString*  moduleId;
@property (copy, nonatomic) NSString*  pageId;

@property (copy, nonatomic) NSString*  noteId;
@property (copy, nonatomic) NSString*  userId;
@property (copy, nonatomic) NSString*  location;
@property (copy, nonatomic) NSString*  subject;
@property (copy, nonatomic) NSString*  value;

@property (copy, nonatomic) NSString*  type;
@property (copy, nonatomic) NSString*  accepted;
@property (copy, nonatomic) NSString*  referenceTo;
@property (copy, nonatomic) NSString*  referencedBy;
@property (copy, nonatomic) NSString*  modifyTime;

@property (copy, nonatomic) NSString* json;



@property (copy, nonatomic) NSString* notesToMerge;


- (NSDictionary *)proxyForJson;
- (NSString *)asJsonString;
- (void)setAllIds:(EPPageItem *)pageItem withRootID:(NSString *)rootID;


- (void) setInJsonField:(NSString*)key withValue:(NSString*)value;
- (NSString*) getFromJsonField:(NSString*)key;

@end
