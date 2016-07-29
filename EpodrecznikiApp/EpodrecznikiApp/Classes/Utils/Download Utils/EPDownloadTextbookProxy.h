







#import <Foundation/Foundation.h>

@protocol EPDownloadTextbookProxyDelegate;

@interface EPDownloadTextbookProxy : NSObject {
    EPStoreCollection *_storeCollection;
}


@property (nonatomic, readonly) NSString *rootID;


@property (nonatomic, readonly) EPStoreCollection *storeCollection;


@property (nonatomic, readonly) NSString *downloadID;


@property (nonatomic, readonly, getter = isUnpacking) BOOL unpaking;


@property (nonatomic, assign) id <EPDownloadTextbookProxyDelegate> delegate;

- (instancetype)initWithRootID:(NSString *)aRootID;


- (void)download;
- (void)update;
- (void)cancel;
- (void)removeWithCompletion:(void (^)(BOOL success))completion;
- (void)resume;


- (BOOL)updateState;


- (void)commit;

- (void)rollback;

- (void)raiseError:(NSError *)error;


- (void)updateProgress:(float)progress;


- (void)beginUnpacking;
- (void)endUnpacking;
- (void)updateUnpackingProgress:(float)progress;


- (void)reloadMetadata;


- (void)checkAppVersion:(void (^) (BOOL))block;

@end

@protocol EPDownloadTextbookProxyDelegate <NSObject>


- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didChangeTextbookStateTo:(EPTextbookStateType)toState fromState:(EPTextbookStateType)fromState;
- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateProgressToValue:(float)progress;


- (void)willBeginExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy;
- (void)didFinishExtractingForDownloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy;
- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didUpdateUnpackingProgressToValue:(float)progress;


- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy didRaiseError:(NSError *)error;


- (void)downloadTextbookProxy:(EPDownloadTextbookProxy *)downloadTextbookProxy reloadMetadataToContentID:(NSString *)contentID;

@end
