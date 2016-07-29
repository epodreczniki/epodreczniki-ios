







#import "EPTextbooksListContainer.h"

@implementation EPTextbooksListContainer

#pragma mark - Lifecycle

- (void)dealloc {
    self.dataSource = nil;
    self.delegate = nil;
}

#pragma mark - Public properties

- (EPSettingsTextbooksListContainerType)containerType {
    return EPSettingsTextbooksListContainerTypeUnknown;
}

#pragma mark - Public methods

- (void)reloadData {

}

- (void)reloadCellAtIndex:(int)index {

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {

}

- (void)didRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {

}

- (EPCollection *)collectionForIndex:(int)index {

    EPCollection *collection = nil;

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(itemforIndex:)]) {
        collection = [self.dataSource itemforIndex:(int)index];
    }
    
    return collection;
}

- (EPDownloadTextbookProxy *)proxyForRootID:(NSString *)rootID {
    return [[EPConfiguration activeConfiguration].downloadUtil downloadTextbookProxyForRootID:rootID];
}

- (void)reloadDataSourceItemAtIndex:(int)index withContentID:(NSString *)contentID {

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(reloadItemAtIndex:withContentID:)]) {
        [self.dataSource reloadItemAtIndex:index withContentID:contentID];
    }
}

#pragma mark - EPTextbooksListContainerCellDelegate

- (void)view:(UIView *)view didSelectDownloadButtonAtIndex:(int)index {

    if (self.delegate && [self.delegate respondsToSelector:@selector(container:didSelectDownloadButtonAtIndex:)]) {
        [self.delegate container:self didSelectDownloadButtonAtIndex:index];
    }
}

- (void)view:(UIView *)view didSelectUpdateButtonAtIndex:(int)index {

    if (self.delegate && [self.delegate respondsToSelector:@selector(container:didSelectUpdateButtonAtIndex:)]) {
        [self.delegate container:self didSelectUpdateButtonAtIndex:index];
    }
}

- (void)view:(UIView *)view didSelectDeleteButtonAtIndex:(int)index {

    if (self.delegate && [self.delegate respondsToSelector:@selector(container:didSelectDeleteButtonAtIndex:)]) {
        [self.delegate container:self didSelectDeleteButtonAtIndex:index];
    }
}

- (void)view:(UIView *)view didSelectCancelButtonAtIndex:(int)index {

    if (self.delegate && [self.delegate respondsToSelector:@selector(container:didSelectCancelButtonAtIndex:)]) {
        [self.delegate container:self didSelectCancelButtonAtIndex:index];
    }
}

- (void)view:(UIView *)view didSelectReadButtonAtIndex:(int)index {

    if (self.delegate && [self.delegate respondsToSelector:@selector(container:didSelectReadButtonAtIndex:)]) {
        [self.delegate container:self didSelectReadButtonAtIndex:index];
    }
}

- (void)view:(UIView *)view didSelectDetailsButtonAtIndex:(int)index {

    if (self.delegate && [self.delegate respondsToSelector:@selector(container:didSelectDetailsButtonAtIndex:)]) {
        [self.delegate container:self didSelectDetailsButtonAtIndex:index];
    }
}

- (void)view:(UIView *)view didRaiseError:(NSError *)error atIndex:(int)index {

    if (self.delegate && [self.delegate respondsToSelector:@selector(container:didRaiseError:atIndex:)]) {
        [self.delegate container:self didRaiseError:error atIndex:index];
    }
}

- (void)view:(UIView *)view shouldReloadCellAtIndex:(int)index {

    [self reloadCellAtIndex:index];
}

@end
