







#import "EPPathModel.h"

@implementation EPPathModel

#pragma mark - App paths

- (NSString *)coversDirectory {
    return [self pathInsideDocuments:kCoversDirectoryName];;
}

- (NSString *)textbooksDirectory {
    return [self pathInsideDocuments:kTextbooksDirectoryName];
}

- (NSString *)otherDirectory {
    return [self pathInsideDocuments:kOtherDirectoryName];
}

- (NSString *)pathForDownloadTmp {
    return [[UIApplication sharedApplication].libraryDirectory stringByAppendingPathComponent:@"Caches/com.apple.nsnetworkd"];
}

- (NSString *)pathForResumeFile {
    return [self.otherDirectory stringByAppendingPathComponent:@"resume.file"];
}

- (NSString *)pathForDatabaseFile {
    return [self pathInsideDocuments:@"configuration.db"];
}

- (NSString *)pathInsideDocuments:(NSString *)relativePath {
    return [[UIApplication sharedApplication].documentsDirectory stringByAppendingPathComponent:relativePath];
}

- (NSString *)pathInsideLibrary:(NSString *)relativePath {
    return [[UIApplication sharedApplication].libraryDirectory stringByAppendingPathComponent:relativePath];
}

- (NSString *)relativePathFromDocuments:(NSString *)absolutePath {
    return [absolutePath stringByReplacingOccurrencesOfString:[UIApplication sharedApplication].documentsDirectory withString:@""];
}

- (NSString *)relativePathFromLibrary:(NSString *)absolutePath {
    return [absolutePath stringByReplacingOccurrencesOfString:[UIApplication sharedApplication].libraryDirectory withString:@""];
}

#pragma mark - Covers

- (NSString *)pathForCover:(NSString *)contentID {
    return [self.coversDirectory stringByAppendingPathComponent:contentID];
}

#pragma mark - Textbook

- (NSString *)pathForInstalledTextbookWithTextbookRootID:(NSString *)textbookRootID {
    
    EPDownloadTextbookProxy *proxy = [self.configuration.downloadUtil downloadTextbookProxyForRootID:textbookRootID];
    return [self pathForInstalledTextbookWithProxy:proxy];
}

- (NSString *)pathForInstalledTextbookWithProxy:(EPDownloadTextbookProxy *)proxy {
    return [self pathForInstalledTextbookWithRelativePath:proxy.storeCollection.storePath];
}

- (NSString *)pathForInstalledTextbookWithRelativePath:(NSString *)relativePath {
    if (!relativePath) {
        return nil;
    }
    
    return [self pathInsideDocuments:relativePath];
}

- (NSString *)absolutePathForExtractingNewTextbookWithProxy:(EPDownloadTextbookProxy *)proxy {
    
    NSString *relativePath = [self relativePathForExtractingNewTextbookWithProxy:proxy];
    return [self pathInsideDocuments:relativePath];
}

- (NSString *)relativePathForExtractingNewTextbookWithProxy:(EPDownloadTextbookProxy *)proxy {
    
    NSString *relativePath = [NSString stringWithFormat:@"/%@/%@/%@", kTextbooksDirectoryName, proxy.rootID, proxy.storeCollection.storeTmpID];
    return relativePath;
}

#pragma mark - Package Content

- (NSString *)pathForIosCssSourceWithTextbookPath:(NSString *)textbookPath {
    return [textbookPath stringByAppendingPathComponent:@"content/IOS_mobile_app.css"];
}

- (NSString *)pathForIosCssDestinationWithTextbookPath:(NSString *)textbookPath {
    return [textbookPath stringByAppendingPathComponent:@"content/mobile_app.css"];
}

- (NSString *)pathForIosJsSourceWithTextbookPath:(NSString *)textbookPath {
    return [textbookPath stringByAppendingPathComponent:@"content/js/device/IOS_device.js"];
}

- (NSString *)pathForIosJsDestinationWithTextbookPath:(NSString *)textbookPath {
    return [textbookPath stringByAppendingPathComponent:@"content/js/device/device.js"];
}

- (NSString *)pathForIndexWithProxy:(EPDownloadTextbookProxy *)proxy {
    
    NSString *textbookPath = [self pathForInstalledTextbookWithProxy:proxy];
    return [textbookPath stringByAppendingPathComponent:@"content/index.html"];
}

- (NSString *)pathForTocWithTextbookPath:(NSString *)textbookPath {
    return [textbookPath stringByAppendingPathComponent:@"content/toc.json"];
}

- (NSString *)pathForPagesWithTextbookPath:(NSString *)textbookPath {
    return [textbookPath stringByAppendingPathComponent:@"content/pages.json"];
}

- (NSString *)pathForNavigationWithTextbookPath:(NSString *)textbookPath {
    return [textbookPath stringByAppendingPathComponent:@"content/navigation.file"];
}

- (NSString *)pathInContentForFile:(NSString *)file withTextbookRootID:(NSString *)textbookRootID {
    
    NSString *fileInContent = [@"content" stringByAppendingPathComponent:file];
    return [self pathForFile:fileInContent withTextbookRootID:textbookRootID];
}

- (NSString *)pathForFile:(NSString *)file withTextbookRootID:(NSString *)textbookRootID {
    
#if MODE_DEVELOPER
    NSString *textbookPath = [UIApplication sharedApplication].documentsDirectory;
#else
    NSString *textbookPath = [self pathForInstalledTextbookWithTextbookRootID:textbookRootID];
#endif
    
    return [textbookPath stringByAppendingPathComponent:file];
}

#pragma mark - Local resources

- (NSString *)pathForLocalShortSchoolsFile {
    return [[NSBundle mainBundle] pathForResource:@"schools-short" ofType:@"json"];
}

- (NSString *)pathForLocalSchoolsFile {
    return [[NSBundle mainBundle] pathForResource:@"schools" ofType:@"json"];
}

- (NSString *)pathForLocalSubjectsFile {
    return [[NSBundle mainBundle] pathForResource:@"subjects" ofType:@"json"];
}

@end
