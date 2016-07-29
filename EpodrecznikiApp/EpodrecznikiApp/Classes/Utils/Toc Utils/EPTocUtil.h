







#import <Foundation/Foundation.h>

@interface EPTocUtil : EPConfigurableObject


- (EPTocConfiguration *)readTocConfigurationForPath:(NSString *)path;
- (void)writeTocConfiguration:(EPTocConfiguration *)tocConfiguration toPath:(NSString *)path;


- (EPTocItem *)parseTocFromFile:(NSString *)tocFile;
- (NSArray *)parsePagesFromFile:(NSString *)pagesFile;
- (NSArray *)studentArrayFromTeacherArray:(NSArray *)teacherArray;


- (void)loadTocForTextbookRootID:(NSString *)textbookRootID;
- (void)unloadToc;


- (NSArray *)colorsForTocItem:(EPTocItem *)tocItem andTeacher:(BOOL)teacherMode;
- (NSDictionary *)createIndexDictionaryFromArray:(NSArray *)array;

@end
