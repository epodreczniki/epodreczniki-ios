







#import <Foundation/Foundation.h>
#import "EPNote.h"

@interface EPNotesModel : EPDatabaseModel 

@property (nonatomic, strong) NSMutableArray* _notes;


- (void) addNote:(EPNote *)note onWebView:(UIWebView*)webView ;
- (void) updateNote:(EPNote *)note onWebView:(UIWebView*)webView ;
- (void) deleteNote:(EPNote *)note onWebView:(UIWebView*)webView ;

- (NSString*) notesToJson:(NSMutableArray *)arr ;
- (NSMutableArray*) getNotesForPage:(NSString*)pageId;
- (NSMutableArray*) getNotesForTextbook:(NSString*)textbookRootId;
- (NSMutableArray*) getBookmarksForTextbook:(NSString*)textbookRootId;
- (EPNote*) getNoteById:(NSString*)noteId;
- (NSString*) mergeContentTextOfNotes:(NSString*)notesToMergeIds;

- (void)removeAllNotesForHandbookID:(NSString *)handbookID;
- (void)removeAllNotesForUserID:(NSNumber *)userID;

@end
