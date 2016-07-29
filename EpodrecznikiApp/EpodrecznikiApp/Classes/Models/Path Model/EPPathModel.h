







#import <Foundation/Foundation.h>
#import "EPConfigurableObject.h"

@interface EPPathModel : EPConfigurableObject


@property (nonatomic, readonly) NSString *coversDirectory;
@property (nonatomic, readonly) NSString *textbooksDirectory;
@property (nonatomic, readonly) NSString *otherDirectory;

- (NSString *)pathForDownloadTmp;
- (NSString *)pathForResumeFile;
- (NSString *)pathForDatabaseFile;
- (NSString *)pathInsideDocuments:(NSString *)relativePath;
- (NSString *)pathInsideLibrary:(NSString *)relativePath;
- (NSString *)relativePathFromDocuments:(NSString *)absolutePath;
- (NSString *)relativePathFromLibrary:(NSString *)absolutePath;


- (NSString *)pathForCover:(NSString *)contentID;


- (NSString *)pathForInstalledTextbookWithTextbookRootID:(NSString *)textbookRootID;
- (NSString *)pathForInstalledTextbookWithProxy:(EPDownloadTextbookProxy *)proxy;
- (NSString *)pathForInstalledTextbookWithRelativePath:(NSString *)relativePath;
- (NSString *)absolutePathForExtractingNewTextbookWithProxy:(EPDownloadTextbookProxy *)proxy;
- (NSString *)relativePathForExtractingNewTextbookWithProxy:(EPDownloadTextbookProxy *)proxy;


- (NSString *)pathForIosCssSourceWithTextbookPath:(NSString *)textbookPath;
- (NSString *)pathForIosCssDestinationWithTextbookPath:(NSString *)textbookPath;
- (NSString *)pathForIosJsSourceWithTextbookPath:(NSString *)textbookPath;
- (NSString *)pathForIosJsDestinationWithTextbookPath:(NSString *)textbookPath;

- (NSString *)pathForIndexWithProxy:(EPDownloadTextbookProxy *)proxy;
- (NSString *)pathForTocWithTextbookPath:(NSString *)textbookPath;
- (NSString *)pathForPagesWithTextbookPath:(NSString *)textbookPath;
- (NSString *)pathForNavigationWithTextbookPath:(NSString *)textbookPath;
- (NSString *)pathInContentForFile:(NSString *)file withTextbookRootID:(NSString *)textbookRootID;
- (NSString *)pathForFile:(NSString *)file withTextbookRootID:(NSString *)textbookRootID;


- (NSString *)pathForLocalShortSchoolsFile;
- (NSString *)pathForLocalSchoolsFile;
- (NSString *)pathForLocalSubjectsFile;

@end
