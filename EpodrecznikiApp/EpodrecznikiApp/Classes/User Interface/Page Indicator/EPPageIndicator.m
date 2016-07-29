







#import "EPPageIndicator.h"

#define INDICATOR_HEIGHT      5.0f
#define MIN_INDICATOR_WIDTH   40.0f

@interface EPPageIndicator ()

@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

- (void)handleTap:(UITapGestureRecognizer *)gesture;
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
- (int)indexForPosition:(int)position;
- (void)setSelecedIndex:(int)selecedIndex notify:(bool)notify animated:(BOOL)animated;
- (void)notifyIndexChanged:(int)index;

@end

@implementation EPPageIndicator

@synthesize selecedIndex = _selecedIndex;
@synthesize numberOfItems = _numberOfItems;

#pragma mark - Lifecycle

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    [self reloadData];
}

- (void)dealloc {
    [self removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer.delegate = nil;
    self.tapGestureRecognizer = nil;
    [self.indicatorView removeGestureRecognizer:self.panGestureRecognizer];
    self.indicatorView = nil;
    self.panGestureRecognizer.delegate = nil;
    self.panGestureRecognizer = nil;
    self.dataSource = nil;
    self.delegate = nil;
}

#pragma mark - Public properties

- (int)selecedIndex {
    return _selecedIndex;
}

- (void)setSelecedIndex:(int)selecedIndex {
    [self setSelecedIndex:selecedIndex notify:YES animated:YES];
}

#pragma mark - Public methods

- (void)reloadData {

    _numberOfItems = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsForPageIndicator:)]) {
        _numberOfItems = [self.dataSource numberOfItemsForPageIndicator:self];
    }

    if (_numberOfItems > 0) {

        CGFloat itemWidth = self.frame.size.width / self.numberOfItems;
        if (itemWidth < MIN_INDICATOR_WIDTH) {
            itemWidth = MIN_INDICATOR_WIDTH;
        }

        if (self.indicatorView) {
            [self.indicatorView removeFromSuperview];
            self.indicatorView = nil;
        }
        self.indicatorView = [UIView new];
        self.indicatorView.frame = CGRectMake(self.selecedIndex * itemWidth, 0, itemWidth, self.frame.size.height);
        [self moveIndicatorToIndex:self.selecedIndex animated:NO];
        
        UIView *barView = [UIView new];
        barView.frame = CGRectMake(1, (self.frame.size.height / 2.0f - INDICATOR_HEIGHT / 2.0f), itemWidth - 2, INDICATOR_HEIGHT);
        barView.layer.cornerRadius = 2;
        barView.layer.backgroundColor = [UIColor epBlueColor].CGColor;
        
        if (_numberOfItems == 1) {
            barView.alpha = 0.0f;
        }
        
        [self.indicatorView addSubview:barView];
        [self addSubview:self.indicatorView];

        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.tapGestureRecognizer.delaysTouchesBegan = NO;
        self.tapGestureRecognizer.delaysTouchesEnded = NO;
        self.tapGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.tapGestureRecognizer];

        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGestureRecognizer.delaysTouchesBegan = NO;
        self.panGestureRecognizer.delaysTouchesEnded = NO;
        self.panGestureRecognizer.cancelsTouchesInView = NO;
        self.panGestureRecognizer.minimumNumberOfTouches = 1;
        self.panGestureRecognizer.maximumNumberOfTouches = 1;
        [self.indicatorView addGestureRecognizer:self.panGestureRecognizer];
    }
    else {

        if (self.indicatorView) {
            [self.indicatorView removeFromSuperview];
            self.indicatorView = nil;
        }
    }
}

- (void)moveIndicatorToIndex:(int)index {
    [self moveIndicatorToIndex:index animated:YES];
}

- (void)moveIndicatorToIndex:(int)index animated:(BOOL)animated {
    [self setSelecedIndex:index notify:NO animated:animated];
}

#pragma mark - Private properties

- (int)numberOfItems {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsForPageIndicator:)]) {
        return [self.dataSource numberOfItemsForPageIndicator:self];
    }
    
    return 0;
}

#pragma mark - Private methods

- (int)indexForPosition:(int)position {

    CGFloat offset = self.indicatorView.frame.size.width / 2.0f;

    if (position < offset) {
        return 0;
    }

    else if (position > (self.frame.size.width - offset)) {
        return self.numberOfItems - 1;
    }

    else {

        int index = (int)floor((position - offset) / ((self.frame.size.width - 2 * offset) / self.numberOfItems));
        return index;
    }
}

- (void)setSelecedIndex:(int)selecedIndex notify:(bool)notify animated:(BOOL)animated {

    if (self.numberOfItems == 0) {
        return;
    }

    if (selecedIndex < 0) {
        selecedIndex = 0;
    }
    else if (selecedIndex >= self.numberOfItems) {
        selecedIndex = self.numberOfItems - 1;
    }

    _selecedIndex = selecedIndex;
    
    CGFloat workingWidth = self.frame.size.width - self.indicatorView.frame.size.width;
    CGFloat itemWidth = 0;
    if (self.numberOfItems == 1) {
        itemWidth = workingWidth;
    }
    else {
        itemWidth = workingWidth / (self.numberOfItems - 1);
    }

    void (^animatedBlock)(void) = ^{
        
        CGRect frame = self.indicatorView.frame;
        frame.origin.x = selecedIndex * itemWidth;
        self.indicatorView.frame = frame;
    };

    if (animated) {
        [UIView animateWithDuration:0.2f animations:animatedBlock];
    }
    else {
        animatedBlock();
    }

    if (notify) {
        [self notifyIndexChanged:selecedIndex];
    }
}

- (void)notifyIndexChanged:(int)index {

    if (self.delegate && [self.delegate respondsToSelector:@selector(pageIndicator:didChangeIndex:)]) {
        [self.delegate pageIndicator:self didChangeIndex:index];
    }
}

#pragma mark - Gestures

- (void)handleTap:(UITapGestureRecognizer *)recognizer {

    if (self.numberOfItems == 0) {
        return;
    }

    CGPoint point = [recognizer locationInView:self];
    self.selecedIndex = [self indexForPosition:point.x];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

    if (self.numberOfItems == 0) {
        return;
    }

    if (recognizer.state == UIGestureRecognizerStateBegan) {

        CGPoint point = [recognizer locationInView:self];
        point.y = self.indicatorView.frame.size.height / 2;
        self.indicatorView.center = point;
    }

    else if (recognizer.state == UIGestureRecognizerStateChanged) {

        CGPoint translation = [recognizer translationInView:self.indicatorView];
        self.indicatorView.center = CGPointMake(recognizer.view.center.x + translation.x, self.indicatorView.center.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.indicatorView];

        CGPoint point = self.indicatorView.center;
        int index = [self indexForPosition:point.x];
        [self notifyIndexChanged:index];
    }

    else if (recognizer.state == UIGestureRecognizerStateEnded) {

        CGPoint point = self.indicatorView.center;
        int index = [self indexForPosition:point.x];

        [UIView animateWithDuration:0.2f animations:^{
            self.selecedIndex = index;
        }];
    }
}

@end
