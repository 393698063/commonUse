//
//  KeyanimationViewController.m
//  Quartz动画知识
//
//  Created by jorgon on 09/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//
#define kToDegress(angle) ((angle)*M_PI/180)
#import "KeyanimationViewController.h"

@interface KeyanimationViewController ()
{
    UIView * _keyAnimationView;
    NSString * _name;
}
@end

@implementation KeyanimationViewController
//@synthesize name = _name;

- (void)setName:(NSString *)name{
    _name = name;
}

- (NSString *)name{
    return _name;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self keyAnimation];
    
    [self keyAnimationWithPath];
    
    [self directionShake];
    [self angleShake];
    
    UIView * view =[[UIView alloc] initWithFrame:CGRectMake(50, 450, 30, 30)];
    view.backgroundColor = [UIColor darkGrayColor];
    UITapGestureRecognizer * t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tell)];
//        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(@"tell")];
        [view addGestureRecognizer:t];
    [self.view addSubview:view];
    view.layer.transform =  CATransform3DIdentity;
    [UIView animateWithDuration:4.0f animations:^{
        view.layer.transform = CATransform3DMakeTranslation(111, 111, 110);
    }];
    
    
    
}
- (void)tell{
    NSLog(@"tell");
}

- (void)keyAnimation{
    _keyAnimationView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 50, 50)];
    _keyAnimationView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_keyAnimationView];
    
    /**
     关键帧动画
     */
    CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //设置时间
    keyframeAnimation.duration = 2;
    //自动反转(原路返回)
    keyframeAnimation.autoreverses = YES;
    
    keyframeAnimation.repeatCount = MAXFLOAT;
    /* A timing function defining the pacing of the animation. Defaults to
     * nil indicating linear pacing. */
    /*定义动画节奏的计时函数。默认为
     0表示线性起搏。*/
    keyframeAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //移动的关键点
    keyframeAnimation.values = @[
                                 [NSValue valueWithCGPoint:CGPointMake(20, 80)],
                                 [NSValue valueWithCGPoint:CGPointMake(200, 400)],
                                 [NSValue valueWithCGPoint:CGPointMake(200, 100)],
                                 [NSValue valueWithCGPoint:CGPointMake(100, 100)],
                                 [NSValue valueWithCGPoint:CGPointMake(0, 160)]
                                 ];
    /* An optional array of `NSNumber' objects defining the pacing of the
     * animation. Each time corresponds to one value in the `values' array,
     * and defines when the value should be used in the animation function.
     * Each value in the array is a floating point number in the range
     * [0,1]. */
    /*
     该 属性是一个数组，用以指定每个子路径(AB,BC,CD)的时间。
     如果你没有显式地对keyTimes进行设置，
     则系统会默认每条子路径的时间
     为：ti=duration/(5-1)，即每条子路径的duration相等，
     都为duration的1\4。当然，我们也可以传个数组让物体快慢结 合。
     例如，你可以传入{0.0, 0.1,0.6,0.7,1.0}，其中首尾必须分别是0和1，
     因此tAB=0.1-0, tCB=0.6-0.1, tDC=0.7-0.6, tED=1-0.7.....
     */
    keyframeAnimation.keyTimes = @[[NSNumber numberWithFloat:0.0],
                                   [NSNumber numberWithFloat:0.2],
                                   [NSNumber numberWithFloat:0.5],
                                   [NSNumber numberWithFloat:0.9],
                                   [NSNumber numberWithFloat:1]
                                   ];
    /* An optional array of CAMediaTimingFunction objects. If the `values' array
     * defines n keyframes, there should be n-1 objects in the
     * `timingFunctions' array. Each function describes the pacing of one
     * keyframe to keyframe segment. */
    /*
     用过UIKit层动画的同学应该对这个属性不陌生，
     这个属性用以指定时间函数，类似于运动的加速度，
     有以下几种类型。上例子的AB段就是用了淡入淡出效果。记住，
     这是一个数组，你有几个子路径就应该传入几个元素
     */
    keyframeAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],//淡入淡出
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],//淡入
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],//淡出
                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];//线性
//                                          [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];//默认
    //添加动画
    [_keyAnimationView.layer addAnimation:keyframeAnimation forKey:nil];
}

/*
 *是一个 CGPathRef 对象，默认是空的，
 当我们创建好CAKeyframeAnimation的实例的时候，
 可以通过制定一个自己定义的path来让 某一个物体按照这个路径进行动画。
 这个值默认是nil 当其被设定的时候 values 这个属性就被覆盖
 */
- (void)keyAnimationWithPath{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //创建一个CGPathRef对象，就是动画的路线
    CGMutablePathRef path = CGPathCreateMutable();
    
    //自动沿着弧度移动
    CGPathAddEllipseInRect(path, NULL, CGRectMake(150, 200, 200, 200));
    // 沿着直线移动
    CGPathAddLineToPoint(path, NULL, 200, 100);
    CGPathAddLineToPoint(path,NULL, 200, 200);
    
    CGPathAddLineToPoint(path,NULL, 100, 200);
    
    CGPathAddLineToPoint(path,NULL, 100, 300);
    
    CGPathAddLineToPoint(path,NULL, 200, 400);
    
    
    //沿着曲线移动
    
    CGPathAddCurveToPoint(path,NULL,50.0,275.0,150.0,275.0,70.0,120.0);
    
    CGPathAddCurveToPoint(path,NULL,150.0,275.0,250.0,275.0,90.0,120.0);
    
    CGPathAddCurveToPoint(path,NULL,250.0,275.0,350.0,275.0,110.0,120.0);
    
    CGPathAddCurveToPoint(path,NULL,350.0,275.0,450.0,275.0,130.0,120.0);
    
    animation.path = path;
    
    CGPathRelease(path);
    /* When true, the object plays backwards after playing forwards. Defaults
    * to NO. */
    animation.autoreverses = YES;
    
    animation.repeatCount=MAXFLOAT;
    /* When true, the animation is removed from the render tree once its
     * active duration has passed. Defaults to YES. */
    animation.removedOnCompletion = NO;
    /* Defines how the timed object behaves outside its active duration.
     * Local time may be clamped to either end of the active duration, or
     * the element may be removed from the presentation. The legal values
     * are `backwards', `forwards', `both' and `removed'. Defaults to
     * `removed'. */
    animation.fillMode = kCAFillModeBoth;
    
    animation.duration = 4.0f;
    /* A timing function defining the pacing of the animation. Defaults to
     * nil indicating linear pacing. */
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    UIView * pathView = [[UIView alloc] initWithFrame:CGRectMake(100, 300, 30, 30)];
    pathView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:pathView];
    [pathView.layer addAnimation:animation forKey:nil];

}

- (void)directionShake{
    UIView * shakeView = [[UIView alloc] initWithFrame:CGRectMake(100, 300, 50, 50)];
    shakeView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:shakeView];
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    animation.values = @[@0,@-10,@10,@0];
    animation.duration = 0.2;
    /* When true the value specified by the animation will be "added" to
     * the current presentation value of the property to produce the new
     * presentation value. The addition function is type-dependent, e.g.
     * for affine transforms the two matrices are concatenated. Defaults to
     * NO. */
    //additive 属性为 YES 能够对所有形式的需要更新的元素重用相同的动画，且无需提前知道它们的位置。
    animation.additive = YES;
    animation.repeatCount = MAXFLOAT;
    [shakeView.layer addAnimation:animation forKey:nil];
    
}

- (void)angleShake{
    UIView * shakeView = [[UIView alloc] initWithFrame:CGRectMake(100, 380, 50, 50)];
    shakeView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:shakeView];
    
    UIView * red = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 30, 30)];
    red.backgroundColor = [UIColor redColor];
    [shakeView addSubview:red];
    
    CAKeyframeAnimation *keyframeAni = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    //时间
    keyframeAni.duration = 0.2;
    //旋转度数(弧度)
    keyframeAni.values = @[@(kToDegress(5)),@(kToDegress(-5)),@(kToDegress(5))];
    //重复次数
    keyframeAni.repeatCount = MAXFLOAT;
    [shakeView.layer addAnimation:keyframeAni forKey:nil];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
