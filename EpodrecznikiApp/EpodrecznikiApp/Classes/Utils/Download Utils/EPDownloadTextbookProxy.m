







#import "EPDownloadTextbookProxy.h"

@implementation EPDownloadTextbookProxy : NSObject

@synthesize rootID = _rootID;
@synthesize unpaking = _unpaking;
@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (instancetype)initWithRootID:(NSString *)aRootID {
    self = [super init];
    if (self) {
        _rootID = aRootID;
        _unpaking = NO;
    }
    return self;
}

- (void)dealloc {
    _rootID = nil;
    _delegate = nil;
    _storeCollection = nil;

}

- (NSString *)description {
    
    NSMutableString *string = [NSMutableString stringWithString:@""];
    [string appendString:@"<EPStoreCollection> {\n"];
    [string appendFormat:@"\trootID: %@,\n", self.rootID];
    [string appendFormat:@"\tstoreCollection: %@,\n", self.storeCollection];
    [string appendFormat:@"\tunpacking: %d,\n", self.unpaking];
    [string appendString:@"}"];
    
    return string;
}

#pragma mark - Public properties

- (NSString *)downloadID {
    return [NSString stringWithFormat:@"%@", self.rootID];
}

- (id <EPDownloadTextbookProxyDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id <EPDownloadTextbookProxyDelegate>)delegate {
    _delegate = delegate;
}

#pragma mark - Public methods

- (EPStoreCollection *)storeCollection {
    return _storeCollection;
}

- (void)download {
    if (self.storeCollection.state == EPTextbookStateTypeToDownload) {
        [[EPConfiguration activeConfiguration].downloadUtil downloadTextbookWithProxy:self];
    }
    else {

    }
}

- (void)update {
    if (self.storeCollection.state == EPTextbookStateTypeToUpdate) {
        [[EPConfiguration activeConfiguration].downloadUtil updateTextbookWithProxy:self];
    }
    else {

    }
}

- (void)cancel {
    if (self.storeCollection.state == EPTextbookStateTypeDownloading || self.storeCollection.state == EPTextbookStateTypeUpdating) {
        [[EPConfiguration activeConfiguration].downloadUtil cancelTextbookWithProxy:self];
    }
    else {

    }
}

- (void)removeWithCompletion:(void (^)(BOOL success))completion {
    if (self.storeCollection.state == EPTextbookStateTypeNormal || self.storeCollection.state == EPTextbookStateTypeToUpdate) {
        [[EPConfiguration activeConfiguration].downloadUtil removeTextbookWithProxy:self completion:completion];
    }
    else {

    }
}

- (void)resume {
    
    if (self.storeCollection.state == EPTextbookStateTypeToDownload || self.storeCollection.state == EPTextbookStateTypeToUpdate) {
        [[EPConfiguration activeConfiguration].downloadUtil resumeTextbookWithProxy:self];
    }
    else {

    }
}

- (BOOL)updateState {

    EPStoreCollection *newStoreCollection = [[EPConfiguration activeConfiguration].downloadModel storeCollectionWithRootID:self.rootID];

    if (!newStoreCollection) {
        return NO;
    }

    if (!_storeCollection) {
        _storeCollection = newStoreCollection;
    }

    else {

        EPTextbookStateType oldState = _storeCollection.state;
        BOOL shouldNotify = (oldState != newStoreCollection.state);

        _storeCollection = newStoreCollection;

        if (shouldNotify) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTextbookProxy:didChangeTextbookStateTo:fromState:)]) {
                    [self.delegate downloadTextbookProxy:self didChangeTextbookStateTo:_storeCollection.state fromState:oldState];
                }
            });
        }

        if (oldState == EPTextbookStateTypeUpdating && (newStoreCollection.state == EPTextbookStateTypeNormal || newStoreCollection.state == EPTextbookStateTypeToUpdate)) {
            [self reloadMetadata];
        }
    }
    
    return YES;
}

- (void)commit {

    
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    if (self.storeCollection.state == EPTextbookStateTypeDownloading || self.storeCollection.state == EPTextbookStateTypeUpdating) {
        [configuration.downloadModel setTextbookAsNormalWithRootID:self.rootID andStoreContentID:self.storeCollection.storeTmpID andStorePath:self.storeCollection.storePath];
        [self updateState];
    }
    else {
        NSAssert(YES, @"Invalid state");
    }
}

- (void)rollback {

    
    EPConfiguration *configuration = [EPConfiguration activeConfiguration];
    if (self.storeCollection.state == EPTextbookStateTypeDownloading) {
        [configuration.downloadModel setTextbookAsToDownloadWithRootID:self.rootID];
        [self updateState];
    }
    else if (self.storeCollection.state == EPTextbookStateTypeUpdating) {
        [configuration.downloadModel setTextbookAsNormalWithRootID:self.rootID andStoreContentID:self.storeCollection.storeContentID andStorePath:self.storeCollection.storePath];
        [self updateState];
    }
    else {
        NSAssert(YES, @"Invalid state");
    }
}

- (void)raiseError:(NSError *)error {

    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTextbookProxy:didRaiseError:)]) {
            [self.delegate downloadTextbookProxy:self didRaiseError:error];
        }
    });
}

- (void)updateProgress:(float)progress {
    
#if DEBUG_PROGRESS_HIDDEN

#else

#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTextbookProxy:didUpdateProgressToValue:)]) {
            [self.delegate downloadTextbookProxy:nil didUpdateProgressToValue:progress];
        };
    });
}

- (void)beginUnpacking {

    
    _unpaking = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(willBeginExtractingForDownloadTextbookProxy:)]) {
            [self.delegate willBeginExtractingForDownloadTextbookProxy:self];
        };
    });
}

- (void)endUnpacking {

    
    _unpaking = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishExtractingForDownloadTextbookProxy:)]) {
            [self.delegate didFinishExtractingForDownloadTextbookProxy:self];
        };
    });
}

- (void)updateUnpackingProgress:(float)progress {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTextbookProxy:didUpdateUnpackingProgressToValue:)]) {
            [self.delegate downloadTextbookProxy:self didUpdateUnpackingProgressToValue:progress];
        };
    });
}

- (void)reloadMetadata {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTextbookProxy:reloadMetadataToContentID:)]) {
            [self.delegate downloadTextbookProxy:self reloadMetadataToContentID:self.storeCollection.storeContentID];
        }
    });
}

- (void)checkAppVersion:(void (^)(BOOL))block {
    [[EPConfiguration activeConfiguration].downloadUtil checkVersionForProxy:self completion:block];
}

@end
