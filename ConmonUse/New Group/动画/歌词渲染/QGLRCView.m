//
//  QGLRCView.m
//  ConmonUse
//
//  Copyright © 2019年 jorgon. All rights reserved.
//
//http://www.cocoachina.com/cms/wap.php?action=article&from=timeline&id=9850&isappinstalled=0
/**
 我们可以知道，mask layer的alpha用来与CALayer的content进行alpha blending，
 如果alpha为1则content显示，反之不显示。受Shimmer的启发，我们可以对mask作动画，
 让它从左到右移动到绿色歌词的layer上，并最终与之重合。
 */

/**mask 的部分是可见部分*/
#import "QGLRCView.h"

@interface GreenLineLabel: UILabel
@end
@implementation GreenLineLabel {
    CALayer *_maskLayer;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _maskLayer = [CALayer layer];
        _maskLayer.backgroundColor = [[UIColor whiteColor] CGColor];    // Any color, only alpha channel matters
        _maskLayer.anchorPoint = CGPointZero;
        _maskLayer.frame = CGRectOffset(self.frame, -CGRectGetWidth(self.frame), 0);
        self.layer.mask = _maskLayer;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)startAnimation {
    // Assume we calculated keyTimes and values
    NSMutableArray * keyTimes = @[@0,@0.3,@0.6,@1];
    NSMutableArray *values = @[[NSValue valueWithCGPoint:CGPointMake(-300, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(-180, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(-90, 0)],
                               [NSValue valueWithCGPoint:CGPointMake(-0, 0)],];
    CGFloat duration = 5;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.keyTimes = keyTimes;
    animation.values = values;
    animation.duration = duration;
    animation.calculationMode = kCAAnimationLinear;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [_maskLayer addAnimation:animation forKey:@"MaskAnimation"];
}
/* Called when the animation begins its active duration. */

- (void)animationDidStart:(CAAnimation *)anim {
    
}

/* Called when the animation either completes its active duration or
 * is removed from the object it is attached to (i.e. the layer). 'flag'
 * is true if the animation reached the end of its active duration
 * without being removed. */

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
}
@end

@interface QGLRCView()
@property (nonatomic, strong) GreenLineLabel * greenLineLabel;
@end

@implementation QGLRCView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.greenLineLabel = [[GreenLineLabel alloc] initWithFrame:self.bounds];
        self.greenLineLabel.text = @"阿克索德将更为哦； 啊；离开家噶上课就饿哦 i 就嘎啊看得见噶；立法；";
        self.greenLineLabel.textColor = [UIColor greenColor];
        [self addSubview:self.greenLineLabel];
    }
    return self;
}

- (void)startAnimation {
    [self.greenLineLabel startAnimation];
}

@end
