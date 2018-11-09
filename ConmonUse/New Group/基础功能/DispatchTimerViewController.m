//
//  DispatchTimerViewController.m
//  ConmonUse
//
//  Created by jorgon on 31/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "DispatchTimerViewController.h"

@interface DispatchTimerViewController ()
@property (nonatomic, strong) CAGradientLayer * layer;
@end

@implementation DispatchTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.layer = [CAGradientLayer layer];
    self.layer.frame = CGRectMake(100, 100, 100, 100);
    [self.view.layer addSublayer:self.layer];
    NSString *string = @"中国";
    NSString *language = (__bridge NSString *)CFStringTokenizerCopyBestStringLanguage( (__bridge CFStringRef)string,
                                                                 CFRangeMake(0, [string length]));
    
    NSArray *colors = @[(id)[[UIColor redColor] CGColor], (id)[[UIColor orangeColor] CGColor]];
    NSArray *locations = @[@(0.0), @(1.0)]; NSTimeInterval duration = 1.0f;
    [UIView animateWithDuration:duration animations:^{
        [CATransaction begin]; {
            [CATransaction setAnimationDuration:duration];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [(CAGradientLayer *)self.layer setColors:colors];
            [(CAGradientLayer *)self.layer setLocations:locations]; }
        [CATransaction commit]; }];
    
    
    [self dispatchTimer];
    dispatchTimer(self, 1, ^(dispatch_source_t timer) {
        NSLog(@"2dafa");
    });
}

void dispatchTimer(id target, double timeInterval,void (^handler)(dispatch_source_t timer))
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), (uint64_t)(timeInterval *NSEC_PER_SEC), 0);
    // 设置回调
    __weak __typeof(target) weaktarget  = target;
    dispatch_source_set_event_handler(timer, ^{
        if (!weaktarget)  {
            dispatch_source_cancel(timer);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) handler(timer);
            });
        }
    });
    // 启动定时器
    dispatch_resume(timer);
}
- (void)dispatchTimer{
    // timer 为局部变量，timer不执行回调
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    int64_t delay = 5 * NSEC_PER_SEC;
    int64_t leeway = 1 * NSEC_PER_SEC;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delay , leeway);
    
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"Ding Dong!");
    });
    dispatch_resume(timer);
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
