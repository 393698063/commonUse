//
//  ViewController.m
//  Quartz动画知识
//
//  Created by jorgon on 06/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    CALayer * layer;
}
@end

@implementation ViewController
/*
 CALayer的“Animatable”属性的设置都应该属于某一个CATransaction事务，CATransaction的作用是保证多个“Animatable”的变化同时进行。也就是说CALayer的属性修改需要依赖CATransaction。
 CATransaction 事务类,可以对多个layer的属性同时进行修改.它分隐式事务,和显式事务.
 [隐式]在某次RunLoop中设置了一个“Animatable”属性，如果当前没有设置事务，则会自动创建一个CATransaction，并在当前线程的下一个RunLoop中commit这个CATransaction。
 [显式]就是直接调用CATransaction的[CATransaction begin]，[CATransaction commit]等相关方法。比如我们不希望self.subLayer.position = CGPointMake(100, 100)产生动画，则可以在CATransaction中设置。
 区分隐式动画和隐式事务：隐式动画通过隐式事务实现动画 。
 区分显式动画和显式事务：显式动画有多种实现方式，显式事务是一种实现显式动画的方式
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //初始化一个layer,添加到主视图
    layer=[CALayer layer];
    layer.bounds = CGRectMake(0, 0, 200, 200);
    layer.position = CGPointMake(160, 250);
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.borderColor = [UIColor blackColor].CGColor;
    layer.opacity = 1.0f;
    [self.view.layer addSublayer:layer];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(50, 400, 100, 50);
    button.backgroundColor = [UIColor cyanColor];
    [button setTitle:@"dianjia" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeLayerProperty) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
//    [self observeRunloop];
//    [NSTimer scheduledTimerWithTimeInterval:2.0
//                                     target:self
//                                   selector:@selector(getCurrentRunLoopMode)
//                                   userInfo:nil repeats:YES];
}

- (void)observeRunloop{
    [self addObserver];
    NSLog(@"%@", [NSRunLoop currentRunLoop].currentMode); // 查看当前的RunLoop运行状态
}

// 添加一个监听者
- (void)addObserver {
    
    // 1. 创建监听者
    /**
     *  创建监听者
     *
     *  @param allocator#>  分配存储空间
     *  @param activities#> 要监听的状态
     *  @param repeats#>    是否持续监听
     *  @param order#>      优先级, 默认为0
     *  @param observer     观察者
     *  @param activity     监听回调的当前状态
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        
        /*
         kCFRunLoopEntry = (1UL << 0),          进入工作
         kCFRunLoopBeforeTimers = (1UL << 1),   即将处理Timers事件
         kCFRunLoopBeforeSources = (1UL << 2),  即将处理Source事件
         kCFRunLoopBeforeWaiting = (1UL << 5),  即将休眠
         kCFRunLoopAfterWaiting = (1UL << 6),   被唤醒
         kCFRunLoopExit = (1UL << 7),           退出RunLoop
         kCFRunLoopAllActivities = 0x0FFFFFFFU  监听所有事件
         */
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"进入");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"即将处理Timer事件");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"即将处理Source事件");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"即将休眠");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"被唤醒");
                break;
            case kCFRunLoopExit:
                NSLog(@"退出RunLoop");
                break;
            default:
                break;
        }
    });
    
    // 2. 添加监听者
    /**
     *  给指定的RunLoop添加监听者
     *
     *  @param rl#>       要添加监听者的RunLoop
     *  @param observer#> 监听者对象
     *  @param mode#>     RunLoop的运行模式, 填写默认模式即可
     */
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
    
    CFRelease(observer);
}

- (void)getCurrentRunLoopMode{
    // 每次定时器触发, 都去查看当前的RunLoop的运行mode
    NSLog(@"%@", [NSRunLoop currentRunLoop].currentMode);
}

-(IBAction)changeLayerProperty
{
    //设置变化动画过程是否显示，默认为NO不显示
//    [CATransaction setDisableActions:YES];
    //设置圆角
    layer.cornerRadius = (layer.cornerRadius == 0.0f) ? 30.0f : 0.0f;
    //设置透明度
    layer.opacity = (layer.opacity == 1.0f) ? 0.5f : 1.0f;
//    [self showTransaction];
//    [self transcationNest];
}

//显示事务
//通过明确的调用begin,commit来提交动画
- (void)showTransaction{
//    修改执行时间
    [CATransaction begin];
    //显式事务默认开启动画效果,kCFBooleanTrue关闭
    [CATransaction setValue:(id)kCFBooleanFalse
                     forKey:kCATransactionDisableActions];
    //动画执行时间
    [CATransaction setValue:[NSNumber numberWithFloat:5.0f] forKey:kCATransactionAnimationDuration];
    //[CATransaction setAnimationDuration:[NSNumber numberWithFloat:5.0f]];
    layer.cornerRadius = (layer.cornerRadius == 0.0f) ? 30.0f : 0.0f;
    layer.opacity = (layer.opacity == 1.0f) ? 0.5f : 1.0f;
    [CATransaction commit];
    
    
}

//事务的嵌套
- (void)transcationNest{
    [CATransaction begin];
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
//    layer.cornerRadius = (layer.cornerRadius == 0.0f) ? 50.0f : 0.0f;
    layer.backgroundColor = [UIColor greenColor].CGColor;
    [CATransaction commit];
    //上面的动画并不会立即执行，需要等最外层的commit
    [NSThread sleepForTimeInterval:5];
    //显式事务默认开启动画效果,kCFBooleanTrue关闭
    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
    //动画执行时间
    [CATransaction setValue:[NSNumber numberWithFloat:5.0f] forKey:kCATransactionAnimationDuration];
    //[CATransaction setAnimationDuration:[NSNumber numberWithFloat:5.0f]];
    layer.cornerRadius = (layer.cornerRadius == 0.0f) ? 30.0f : 0.0f;
    [CATransaction commit];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
