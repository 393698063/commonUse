//
//  QGMenuLayout.m
//  Quartz动画知识
//
//  Created by jorgon on 18/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//


#import "QGMenuLayout.h"

typedef NS_ENUM(NSInteger, DragScrollDirction) {
    DragScrollDirctionNone,
    DragScrollDirctionUp, //往上滚动
    DragScrollDirctionDown //往下滚动
};


@interface QGFakeView : UIView
@property (nonatomic, strong) UIImageView * imageView;
@end

@implementation QGFakeView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
@end

@interface QGMenuLayout()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) QGFakeView * fakeView;
@property (nonatomic, assign) CGPoint fakeViewCenter;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSIndexPath *reorderingCellIndexPath;
@property (nonatomic, assign) DragScrollDirction dragScrollDirection;
@property (nonatomic, assign) CGPoint panTranslation;
@property (nonatomic, assign) BOOL setUped;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) NSMutableArray *indexPathsToAnimate;
@property (nonatomic, assign) NSInteger fakeViewOldyoffset;
@property (nonatomic, assign) NSInteger fakeViewOldxoffset;
@property (nonatomic, assign) CGRect fakeViewFrame;//记录原始的fakeviewFrame，不会因为动画改编
@end

@implementation QGMenuLayout
/*
 自定义瀑布流需要重写父类的4个方法：
 1.- (void)prepareLayout;
 2.- (CGSize)collectionViewContentSize;
 3.- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect; // return an array layout attributes instances for all the views in the given rect
 4.- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
 */


// The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
// The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
// Subclasses should always call super if they override.
- (void)prepareLayout{
    [super prepareLayout];
    [self setUpCollectionViewGesture];
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return [super layoutAttributesForElementsInRect:rect];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes * attr = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    return attr;
}

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems{
    [super prepareForCollectionViewUpdates:updateItems];
    
}
- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
}

- (void)setUpCollectionViewGesture
{
    if (!_setUped) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _longPressGesture.delegate = self;
        _panGesture.delegate = self;
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGesture]; }}
        [self.collectionView addGestureRecognizer:_longPressGesture];
        [self.collectionView addGestureRecognizer:_panGesture];
        _setUped = YES;
    }
}
- (void)setUpDisplayLink
{
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoScroll)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
-  (void)stopScroll
{
    [_displayLink invalidate];
    _displayLink = nil;
}
- (void)autoScroll{
    CGPoint contentOffset = self.collectionView.contentOffset;
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGFloat increment = 0;
    if (self.dragScrollDirection == DragScrollDirctionUp) {
        increment = -10.0f;
    } else if (self.dragScrollDirection == DragScrollDirctionDown) {
        increment = 10.0f;
    }
    CGFloat yoffset = [self getMaxmumy];
    if (CGRectGetMidY(_fakeView.frame) >= yoffset){//拖到了最大值
        _fakeViewCenter = CGPointMake(_fakeViewCenter.x, _fakeViewCenter.y);
        _fakeView.center = CGPointMake(_fakeViewCenter.x + _panTranslation.x, _fakeViewCenter.y + _panTranslation.y);
        [self stopScroll];
        return;
    }
    
    if (contentOffset.y + increment <= -contentInset.top) {//到达最顶端时
        [UIView animateWithDuration:0.3f animations:^{
             CGFloat diff = -contentInset.top - contentOffset.y;
            _fakeViewCenter = CGPointMake(_fakeViewCenter.x, _fakeViewCenter.y + diff);
            self.collectionView.contentOffset = CGPointMake(contentOffset.x, -contentInset.top);
            _fakeView.center = CGPointMake(_fakeViewCenter.x + _panTranslation.x, _fakeViewCenter.y + _panTranslation.y);
        } completion:^(BOOL finished) {
        }];
        [self stopScroll];
        return;
    }
    
    [self.collectionView performBatchUpdates:^{
        _fakeViewCenter = CGPointMake(_fakeViewCenter.x, _fakeViewCenter.y + increment);
        _fakeView.center = CGPointMake(_fakeViewCenter.x + _panTranslation.x, _fakeViewCenter.y + _panTranslation.y + increment);
        self.collectionView.contentOffset = CGPointMake(contentOffset.x, contentOffset.y + increment);
    } completion:nil];
    [self moveItemIfNeeded];
    
}

- (CGFloat)getMaxmumy{
    //获取到最后一排cell的y轴值
    UIEdgeInsets contentInset = self.sectionInset;
    NSInteger commonCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger rows = 0;
    if (commonCount % self.columnNumber == 0) {
        rows = commonCount / self.columnNumber;
    } else {
        rows = commonCount / self.columnNumber + 1;
    }
    CGFloat headerHeight = 0;
    if ([self.delegate respondsToSelector:@selector(headerHeightAtSection:)]) {
        headerHeight = [self.delegate headerHeightAtSection:0];
    }
    CGFloat yoffset = headerHeight + contentInset.top + CGRectGetHeight(self.fakeViewFrame) * (rows - 1) + self.minimumLineSpacing * (rows - 1);
    return yoffset;
}

- (void)moveItemIfNeeded{
    NSIndexPath * atIndexPath = _reorderingCellIndexPath;
    NSIndexPath * toIndexPath = [self.collectionView indexPathForItemAtPoint:_fakeView.center];
    if (toIndexPath.section == 1) {
        
    }
    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:atIndexPath];
    cell.alpha = 0.3;
    
    if (!toIndexPath || [atIndexPath isEqual:toIndexPath]) {
        return;
    }
    
    //移动
    [self.collectionView performBatchUpdates:^{
        _reorderingCellIndexPath = toIndexPath;
        [self.collectionView moveItemAtIndexPath:atIndexPath toIndexPath:toIndexPath];
        //更新外部数据源
        if ([self.delegate respondsToSelector:@selector(moveItemAtIndexPath:toIndexPath:)]) {
            [self.delegate moveFromIndexPath:atIndexPath toIndexPath:toIndexPath];
        }
    } completion:nil];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture{
//    NSLog(@"long state %ld", gesture.state);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan://1
        {
            NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:[gesture locationInView:gesture.view]];
            _reorderingCellIndexPath = indexPath;
            if ([self.delegate respondsToSelector:@selector(canMoveCollectionItemAtindexPath:)]) {
                if (![self.delegate canMoveCollectionItemAtindexPath:indexPath]) {
                    return;
                }
            }
            //滚到顶部关闭
            self.collectionView.scrollsToTop = NO;
            //cell的TempView
            UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            cell.alpha = 0.3;
            self.fakeViewOldyoffset = CGRectGetMinY(cell.frame);
            self.fakeViewOldxoffset = CGRectGetMinX(cell.frame);
            _fakeView = _fakeView ?: [[QGFakeView alloc] initWithFrame:cell.frame];
            _fakeView.frame = cell.frame;
            _fakeViewFrame = cell.frame;
            _fakeViewCenter = _fakeView.center;
            _fakeView.hidden = NO;
            _fakeView.layer.shadowColor = [UIColor blackColor].CGColor;
            _fakeView.layer.shadowOffset = CGSizeMake(0, 0);
            _fakeView.layer.shadowOpacity = .5f;
            _fakeView.layer.shadowRadius = 3.f;
            if (!_fakeView.superview) {
                [self.collectionView addSubview:_fakeView];
            }
            NSLog(@"cell frame %@", NSStringFromCGRect(cell.frame));
            NSLog(@"fakeview frame %@", NSStringFromCGRect(_fakeView.frame));
            _fakeView.imageView.image = [self getImageFromView:cell];
            
            [UIView animateWithDuration:0.5f animations:^{
                _fakeView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            }];
            break;
        }
        case UIGestureRecognizerStateChanged://2
        {
            break;
        }
        case UIGestureRecognizerStateEnded://3
        case UIGestureRecognizerStateCancelled://4
        {
            NSIndexPath * currentCellIndexPath = _reorderingCellIndexPath;

            //当前选择的cell
            UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:currentCellIndexPath];
            if ([self.delegate respondsToSelector:@selector(canMoveCollectionItemAtindexPath:)]) {
                if (![self.delegate canMoveCollectionItemAtindexPath:currentCellIndexPath]) {
                    cell.alpha = 1.0f;
                    return;
                }
            }

             //滚动到顶部打开
            self.collectionView.scrollsToTop = YES;
            //禁用滚动
            [self stopScroll];
             UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:currentCellIndexPath];
            [UIView animateWithDuration:.3f animations:^{
                _fakeView.transform = CGAffineTransformIdentity;
                _fakeView.frame = attributes.frame;
            } completion:^(BOOL finished) {
                _fakeView.hidden = YES;
                _reorderingCellIndexPath = nil;
                _fakeViewCenter = CGPointZero;
                cell.alpha = 1.0f;
            }];
            break;
        }
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture{
//    NSLog(@"pan state %ld",(long)gesture.state);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            _panTranslation = [gesture translationInView:gesture.view];
            if ([self.delegate respondsToSelector:@selector(canMoveCollectionItemAtindexPath:)]) {
                if (![self.delegate canMoveCollectionItemAtindexPath:_reorderingCellIndexPath]) {
                    return;
                }
            }

            CGFloat yoffset = [self getMaxmumy];
            if (CGRectGetMidY(_fakeView.frame) >= yoffset) { //如果刚好拖动到最后一排cell的y轴位置
                NSLog(@"_fakeView.center.y: %f",CGRectGetMinY(_fakeView.frame));
                NSLog(@"_panTranslation.y + yoffset:%f",_panTranslation.y + yoffset);
                if ((yoffset - self.fakeViewOldyoffset) > _panTranslation.y) { //当到达最后一个cell后在往上拖动时
                    _fakeView.center = CGPointMake(_fakeViewCenter.x + _panTranslation.x, _fakeViewCenter.y + _panTranslation.y);
                }else{ //不让其越过最后一排cell的y轴位置
                    _fakeView.frame = CGRectMake(_fakeViewOldxoffset + _panTranslation.x, yoffset, CGRectGetWidth(self.fakeViewFrame), CGRectGetHeight(self.fakeViewFrame));
                    [self moveItemIfNeeded];
                    [self stopScroll];
                    return;
                }
            }else{ //还没有拖动到最后一排cell位置时
                _fakeView.center = CGPointMake(_fakeViewCenter.x + _panTranslation.x, _fakeViewCenter.y + _panTranslation.y);
            }
            //移动的布局
            [self moveItemIfNeeded];

            //自动滚动collectionView
            if (CGRectGetMaxY(_fakeView.frame) >= self.collectionView.contentOffset.y + self.collectionView.bounds.size.height) {
                if (ceilf(self.collectionView.contentOffset.y) < self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
                    self.dragScrollDirection = DragScrollDirctionDown;
                    [self setUpDisplayLink]; //往下滚动
                }
            }
            else if (CGRectGetMinY(_fakeView.frame) <= (self.collectionView.contentOffset.y + self.collectionView.contentInset.top )){
                if (self.collectionView.contentOffset.y > (-self.collectionView.contentInset.top )) {
                    self.dragScrollDirection = DragScrollDirctionUp;
                    [self setUpDisplayLink]; //往上滚动
                }
            }
            else {
                self.dragScrollDirection = DragScrollDirctionNone;
                [self stopScroll];
            }

            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            [self stopScroll];
            break;
        }
        default:
            break;
    }
}

/*
 typedef NS_ENUM(NSInteger, UIGestureRecognizerState) {
 UIGestureRecognizerStatePossible,   // the recognizer has not yet recognized its gesture, but may be evaluating touch events. this is the default state
 
 UIGestureRecognizerStateBegan,      // the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
 UIGestureRecognizerStateChanged,    // the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
 UIGestureRecognizerStateEnded,      // the recognizer has received touches recognized as the end of the gesture. the action method will be called at the next turn of the run loop and the recognizer will be reset to UIGestureRecognizerStatePossible
 UIGestureRecognizerStateCancelled,  // the recognizer has received touches resulting in the cancellation of the gesture. the action method will be called at the next turn of the run loop. the recognizer will be reset to UIGestureRecognizerStatePossible
 
 UIGestureRecognizerStateFailed,     // the recognizer has received a touch sequence that can not be recognized as the gesture. the action method will not be called and the recognizer will be reset to UIGestureRecognizerStatePossible
 
 // Discrete Gestures – gesture recognizers that recognize a discrete event but do not report changes (for example, a tap) do not transition through the Began and Changed states and can not fail or be cancelled
 UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded // the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop and the recognizer will be reset to UIGestureRecognizerStatePossible
 };*/
#pragma mark - UIGestureRecognizerDelegate
// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if (self.collectionView.panGestureRecognizer.state != 0 && self.collectionView.panGestureRecognizer.state != 5) {
            return NO;
        }
    }
    return YES;
}
//是否允许同时识别
// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state != 0 && _longPressGesture.state != 5) {
            if ([_longPressGesture isEqual:otherGestureRecognizer]) {
                return YES;
            }
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if ([_panGesture isEqual:otherGestureRecognizer]) {
            return YES;
        }
    }else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }
    return YES;
}

- (UIImage *)getImageFromView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, 0, [UIScreen mainScreen].scale);
   
    //renderInContext呈现接受者及其子范围到指定的上下文
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //返回一个基于当前图形上下文的图片
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //移除栈顶的基于当前位图的图形上下文
    UIGraphicsEndImageContext();
    
    return viewImage;
}


@end
