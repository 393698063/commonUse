//
//  BasicAnimationViewController.m
//  ConmonUse
//
//  Created by jorgon on 10/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "BasicAnimationViewController.h"

@interface BasicAnimationViewController ()

@end

@implementation BasicAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self moveAnimation];
    [self rotateAnimationX];
    [self rotateAnimationY];
    [self rotateAnimationZ];
    [self rotation];
    [self scalX];
    [self scalY];
    [self scalZ];
    [self scal];
    [self translationX];
    [self translationY];
    [self translationZ];
    [self translation];
    [self shake];
    [self spring];
}
// 旋转动画
- (void)rotateAnimationX{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 50, 50)];
    view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:M_PI]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)rotateAnimationY{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(70, 100, 50, 50)];
    view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:M_PI]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)rotateAnimationZ{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(130, 100, 50, 50)];
    view.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:M_PI]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)rotation{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(190, 100, 50, 50)];
    view.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:M_PI]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)scalX{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 160, 50, 50)];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:1.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:2]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)scalY{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(70, 160, 50, 50)];
    view.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:1.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:2]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)scalZ{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(130, 160, 50, 50)];
    view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.scale.z"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:1.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:2]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)scal{//相当于x，y，z
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(190, 160, 50, 50)];
    view.backgroundColor = [UIColor brownColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
//    bsa.fromValue = [NSNumber numberWithFloat:1.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:2]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)translationX{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 260, 50, 50)];
    view.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:view];
    
//    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
//    bsa.repeatCount = MAXFLOAT;
//    bsa.duration = 4;
//    bsa.beginTime = CACurrentMediaTime();
//    bsa.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
//    bsa.toValue = [NSNumber numberWithFloat:80]; // 终止角度
//    [view.layer addAnimation:bsa forKey:nil];
    CABasicAnimation *animation1 =[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation1.toValue = [NSNumber numberWithFloat:80];; // 終点
    CABasicAnimation *animation2 =[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation2.fromValue = [NSNumber numberWithFloat:0.0]; // 开始时的角度
    animation2.toValue = [NSNumber numberWithFloat:M_PI]; // 结束时的角度
    
    
    /* 动画组 */
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.0;
    group.repeatCount = MAXFLOAT;
    
    group.animations = [NSArray arrayWithObjects:animation1, animation2, nil];
    [view.layer addAnimation:group forKey:nil];
    
}
- (void)translationY{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(70, 260, 50, 50)];
    view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:80]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)translationZ{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(130, 260, 50, 50)];
    view.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:80]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}
- (void)translation{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(190, 260, 50, 50)];
    view.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 4;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:80]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}

- (void)shake{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 320, 50, 50)];
    view.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:view];
    
    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    bsa.repeatCount = MAXFLOAT;
    bsa.duration = 0.3;
    bsa.autoreverses = YES;
    bsa.beginTime = CACurrentMediaTime();
    bsa.fromValue = [NSNumber numberWithFloat:-5]; // 起始角度
    bsa.toValue = [NSNumber numberWithFloat:5]; // 终止角度
    [view.layer addAnimation:bsa forKey:nil];
}

- (void)spring {
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 500, 80, 80)];
    imageView.image = [UIImage imageNamed:@"feedGold"];
    [self.view addSubview:imageView];
    imageView.transform = CGAffineTransformScale(imageView.transform, 0.5, 0.5);
    [UIView animateWithDuration:1 delay:0
         usingSpringWithDamping:0.2
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageView.frame = CGRectMake(100, 510, 80, 80);
                         imageView.transform = CGAffineTransformScale(imageView.transform, 1, 1);;
                     } completion:^(BOOL finished) {
                         
                     }];
    
    
    UIImageView * imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(200, 500, 80, 80)];
    imageView1.image = [UIImage imageNamed:@"feedGold"];
    [self.view addSubview:imageView1];
    shakerAnimation(imageView1, 2, 20);
    [self springScale];
}

- (void)springScale {
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 500, 40, 40)];
    imageView.image = [UIImage imageNamed:@"feedGold"];
    [self.view addSubview:imageView];
//    CABasicAnimation * bsa = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    bsa.repeatCount = MAXFLOAT;
//    bsa.duration = 4;
//    bsa.beginTime = CACurrentMediaTime();
//    bsa.fromValue = [NSNumber numberWithFloat:0.1]; // 起始角度
//    bsa.toValue = [NSNumber numberWithFloat:1]; // 终止角度
    CAKeyframeAnimation * bsa = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bsa.values = @[@0.3, @0.5, @0.8, @1];
    bsa.keyTimes = @[@0, @0.4, @0.8, @1];
    bsa.duration = 2;
    bsa.repeatCount = MAXFLOAT;
//    [imageView.layer addAnimation:bsa forKey:@""];
    
    CAKeyframeAnimation * anima = spring(imageView, 2, 10);
    
    CAAnimationGroup * group = [[CAAnimationGroup alloc] init];
    group.duration = 2;
    group.animations = @[bsa,anima];
    group.repeatCount = MAXFLOAT;
    [imageView.layer addAnimation:group forKey:@""];
}

CAKeyframeAnimation * spring (UIView *view ,NSTimeInterval duration,float height){
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat currentTx = view.transform.ty;
    animation.duration = duration;
    //    animation.autoreverses = YES;
    animation.values = @[@(currentTx), @(currentTx + height), @(currentTx-height/3*2), @(currentTx + height/3*2), @(currentTx -height/3), @(currentTx + height/3), @(currentTx)];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}
// 重力弹跳动画效果
void shakerAnimation (UIView *view ,NSTimeInterval duration,float height){
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat currentTx = view.transform.ty;
    animation.duration = duration;
//    animation.autoreverses = YES;
    animation.values = @[@(currentTx), @(currentTx + height), @(currentTx-height/3*2), @(currentTx + height/3*2), @(currentTx -height/3), @(currentTx + height/3), @(currentTx)];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:animation forKey:@"kViewShakerAnimationKey"];
}

// 移动动画
- (void)moveAnimation{
    UIView * myView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 50, 50)];
    myView.backgroundColor = [UIColor redColor];
    [self.view addSubview:myView];
    
    CABasicAnimation * bsAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    bsAnimation.duration = 4;
    
//    bsAnimation.autoreverses = YES;
    
//    bsAnimation.repeatCount = MAXFLOAT;
    /*
     The begin time of the object, in relation to its parent object, if
     * applicable. Defaults to 0. */
    bsAnimation.beginTime = CACurrentMediaTime();
    bsAnimation.fromValue = [NSValue valueWithCGPoint:myView.layer.position];// 起始帧
    bsAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(300, 300)]; // 终了帧
    bsAnimation.fillMode = kCAFillModeBoth;
    bsAnimation.removedOnCompletion = false;
    [myView.layer addAnimation:bsAnimation forKey:nil];
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
