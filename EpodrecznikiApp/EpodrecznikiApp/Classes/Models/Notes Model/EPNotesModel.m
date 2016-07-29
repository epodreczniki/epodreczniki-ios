    







#import "EPWebViewJavascriptProxy.h"
#import "EPNotesModel.h"

@implementation EPNotesModel


@synthesize _notes;


- (instancetype)initWithConfiguration:(EPConfiguration *)aConfiguration {
    self = [super initWithConfiguration:aConfiguration];
    _notes = [NSMutableArray new];
    return self;
}


- (void) addNote:(EPNote *)note onWebView:(UIWebView*)webView {
    @synchronized (self) {
        if (!note) {
            return;
        }

        long long dbNoteId = [self executeNonQueryWithNameAndGetId:@"ep_note_create_note",

         note.localUserId,
         note.handbookId,
         note.moduleId,
         note.pageId,
         
         note.noteId,
         note.userId,
         note.location,
         note.subject,
         note.value,
         note.type,
         note.accepted,
         note.referenceTo,
         note.referencedBy,
         note.modifyTime,
         note.json
         ];
        note.localNoteId = [[NSNumber alloc] initWithLongLong:dbNoteId];
    }
    
    [self removeNotesToMerge:note.notesToMerge];
    
    [EPWebViewJavascriptProxy noteCreateCallback:webView
                                      noteAsJson:note.asJsonString
                                    notesToMarge:note.notesToMerge];

}

- (void) updateNote:(EPNote *)note onWebView:(UIWebView*)webView {
    @synchronized (self) {
        if (!note) {
            return;
        }
        
        [self executeNonQueryWithName:@"ep_note_update_note",
                              note.localUserId,
                              note.handbookId,
                              note.moduleId,
                              note.pageId,
                              
                              note.noteId,
                              note.userId,
                              note.location,
                              note.subject,
                              note.value,
                              note.type,
                              note.accepted,
                              note.referenceTo,
                              note.referencedBy,
                              note.modifyTime,
                              note.json,
                              note.localNoteId 
                              ];
    }
    
    [EPWebViewJavascriptProxy noteEditCallback:webView
                                      noteAsJson:note.asJsonString];
}


- (void) deleteNote:(EPNote *)note onWebView:(UIWebView*)webView {
    NSString* strNoteId = [note.localNoteId stringValue];
    @synchronized (self) {
        if (!note) {
            return;
        }
        
        [self executeNonQueryWithName:@"ep_note_delete_note",
            strNoteId
         ];
    }
    
    [EPWebViewJavascriptProxy noteDeleteCallback:webView
                                    noteId:strNoteId];
}

-(NSString*) notesToJson:(NSMutableArray *)arr  {
    @try {
        NSError *error;
        NSMutableArray *arrOfDict = [NSMutableArray new];
        for (int i=0; i < arr.count; i++) {
            [arrOfDict addObject:[arr[i] proxyForJson]];
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrOfDict
                                                           options:0
                                                             error:&error];
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        return result;
    }
    @catch (NSException *exception) {

        return @"error";
    }
}


- (NSMutableArray*) getNotesForPage:(NSString*)pageId {
    NSString *localUserID = [EPConfiguration activeConfiguration].userUtil.userIDString;
    
    @synchronized (self) {
        NSMutableArray *result = [NSMutableArray new];
        
        FMResultSet *rs =[self executeQueryWithName:@"ep_note_get_note_by_page", pageId, localUserID];

        while ([rs next]) {
            EPNote *note = [EPNote new];
            [self noteFromDb:rs note:note];

            [result addObject:note];
        }

        [rs close];
        [self closeDatabase];
        
        return result;
    }
}

- (NSMutableArray*) getNotesForTextbook:(NSString*)textbookRootId {
    EPCollection *collection = [[EPConfiguration activeConfiguration].textbookUtil collectionForRootID:textbookRootId];
    NSString *handbookId = convertContentIDToHandbookID(collection.contentID);
    NSString *localUserID = [EPConfiguration activeConfiguration].userUtil.userIDString;
    
    @synchronized (self) {
        NSMutableArray *result = [NSMutableArray new];
        
        FMResultSet *rs =[self executeQueryWithName:@"ep_note_get_notes_by_handbookId", handbookId, localUserID];
        
        while ([rs next]) {
            EPNote *note = [EPNote new];
            [self noteFromDb:rs note:note];

            [result addObject:note];
        }

        [rs close];
        [self closeDatabase];
        
        return result;
    }
}

- (NSMutableArray*) getBookmarksForTextbook:(NSString*)textbookRootId {
    EPCollection *collection = [[EPConfiguration activeConfiguration].textbookUtil collectionForRootID:textbookRootId];
    NSString *handbookId = convertContentIDToHandbookID(collection.contentID);
    NSString *localUserID = [EPConfiguration activeConfiguration].userUtil.userIDString;
    
    @synchronized (self) {
        NSMutableArray *result = [NSMutableArray new];
        
        FMResultSet *rs =[self executeQueryWithName:@"ep_note_get_bookmarks_by_handbookId", handbookId, localUserID];
        
        while ([rs next]) {
            EPNote *note = [EPNote new];
            [self noteFromDb:rs note:note];

            [result addObject:note];
        }

        [rs close];
        [self closeDatabase];
        
        return result;
    }
}


- (void)noteFromDb:(FMResultSet *)rs note:(EPNote *)note {
    note.localNoteId             = [[NSNumber alloc] initWithLongLong:[rs longLongIntForColumn:@"localNoteId"]];
    note.localUserId     = [rs stringForColumn:@"localUserId"];
    note.handbookId     = [rs stringForColumn:@"handbookId"];
    note.moduleId      = [rs stringForColumn:@"moduleId"];
    note.pageId      = [rs stringForColumn:@"pageId"];
    
    note.noteId     = [rs stringForColumn:@"noteId"];
    note.userId      = [rs stringForColumn:@"userId"];
    note.location     = [rs stringForColumn:@"location"];
    note.subject    = [rs stringForColumn:@"subject"];
    note.value      = [rs stringForColumn:@"value"];
    note.type      = [rs stringForColumn:@"type"];
    note.accepted     = [rs stringForColumn:@"accepted"];
    note.referenceTo     = [rs stringForColumn:@"referenceTo"];
    note.referencedBy     = [rs stringForColumn:@"referencedBy"];
    note.modifyTime     = [rs stringForColumn:@"modifyTime"];
    
    note.json   = [rs stringForColumn:@"json"];
}

- (EPNote*) getNoteById:(NSString*)noteId {
    @synchronized (self) {
        EPNote *note = [EPNote new];
        
        FMResultSet *rs =[self executeQueryWithName:@"ep_note_get_note_by_localId", noteId];
        
        if ([rs next]) {
            [self noteFromDb:rs note:note];
        }

        [rs close];
        [self closeDatabase];
        
        return note;
    }
}


- (NSString*) mergeContentTextOfNotes:(NSString*)notesToMergeIds {
    NSString* res = @"";
    NSString* ids = [notesToMergeIds stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    ids = [ids stringByReplacingOccurrencesOfString:@"[" withString:@""];
    ids = [ids stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSString* query = [NSString stringWithFormat:@"SELECT value FROM ep_user_notes WHERE localNoteId IN ( %@ )", ids];
    @synchronized (self) {
        FMResultSet *rs =[self executeQueryWithString:query];
        
        while([rs next]) {
            NSString* tmp = [NSString stringWithFormat:@"%@ \n\n", [rs stringForColumn:@"value"]];
            res = [res stringByAppendingString:tmp];
        }

        [rs close];
        [self closeDatabase];
    }
    
    return res;
}

- (void) removeNotesToMerge:(NSString*)notesIds {
    NSString* ids = [notesIds stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    ids = [ids stringByReplacingOccurrencesOfString:@"[" withString:@""];
    ids = [ids stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSString* query = [NSString stringWithFormat:@"DELETE FROM ep_user_notes WHERE localNoteId IN ( %@ )", ids];
    @synchronized (self) {
        [self executeNonQueryWithString:query];
    }
}

- (void)removeAllNotesForHandbookID:(NSString *)handbookID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"ep_note_delete_by_handbook_id", handbookID];
    }
}

- (void)removeAllNotesForUserID:(NSNumber *)userID {
    @synchronized (self) {
        [self executeNonQueryWithName:@"ep_note_delete_by_user_id", userID];
    }
}

@end
