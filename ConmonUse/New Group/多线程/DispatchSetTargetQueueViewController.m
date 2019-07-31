//
//  DispatchSetTargetQueueViewController.m
//  ConmonUse
//
//  Copyright © 2019年 jorgon. All rights reserved.
//

#import "DispatchSetTargetQueueViewController.h"

@interface DispatchSetTargetQueueViewController ()

@end

@implementation DispatchSetTargetQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self changeQueuePriority];
}

//二、变更执行优先级
- (void)changeQueuePriority{
    //优先级变更的串行队列，初始是默认优先级
    dispatch_queue_t serialQueue = dispatch_queue_create("com.gcd.setTargetQueue.serialQueue", NULL);
    
    //优先级不变的串行队列（参照），初始是默认优先级
    dispatch_queue_t serialDefaultQueue = dispatch_queue_create("com.gcd.setTargetQueue.serialDefaultQueue", NULL);
    
    //变更前
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
    });
    dispatch_async(serialDefaultQueue, ^{
        NSLog(@"2");
    });
    
    //获取优先级为后台优先级的全局队列
    dispatch_queue_t globalDefaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    //变更优先级
    dispatch_set_target_queue(serialQueue, globalDefaultQueue);
    
    //变更后
    dispatch_async(serialQueue, ^{
        NSLog(@"1");
    });
    dispatch_async(serialDefaultQueue, ^{
        NSLog(@"2");
    });
}
//三、设置执行阶层
- (void)setExcuteOrder {
//    首先创建5个串行队列
    dispatch_queue_t serialQueue1 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue1", NULL);
    dispatch_queue_t serialQueue2 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue2", NULL);
    dispatch_queue_t serialQueue3 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue3", NULL);
    dispatch_queue_t serialQueue4 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue4", NULL);
    dispatch_queue_t serialQueue5 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue5", NULL);
    
    dispatch_async(serialQueue1, ^{
        NSLog(@"1");
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@"2");
    });
    dispatch_async(serialQueue3, ^{
        NSLog(@"3");
    });
    dispatch_async(serialQueue4, ^{
        NSLog(@"4");
    });
    dispatch_async(serialQueue5, ^{
        NSLog(@"5");
    });
    
    /*
     这样就是5个串行队列在并行执行操作，执行结果无固定顺序
     2017-02-28 21:32:48.787 GCDLearn[1449:71250] 5
     2017-02-28 21:32:48.786 GCDLearn[1449:71242] 3
     2017-02-28 21:32:48.786 GCDLearn[1449:71226] 1
     2017-02-28 21:32:48.786 GCDLearn[1449:71235] 2
     2017-02-28 21:32:48.786 GCDLearn[1449:71244] 4
     */
}

- (void)excuteOrder {
    //创建目标串行队列
    dispatch_queue_t targetSerialQueue = dispatch_queue_create("com.gcd.setTargetQueue2.targetSerialQueue", NULL);
    //     首先创建5个串行队列
    dispatch_queue_t serialQueue1 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue1", NULL);
    dispatch_queue_t serialQueue2 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue2", NULL);
    dispatch_queue_t serialQueue3 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue3", NULL);
    dispatch_queue_t serialQueue4 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue4", NULL);
    dispatch_queue_t serialQueue5 = dispatch_queue_create("com.gcd.setTargetQueue2.serialQueue5", NULL);
    
    //设置执行阶层
    dispatch_set_target_queue(serialQueue1, targetSerialQueue);
    dispatch_set_target_queue(serialQueue2, targetSerialQueue);
    dispatch_set_target_queue(serialQueue3, targetSerialQueue);
    dispatch_set_target_queue(serialQueue4, targetSerialQueue);
    dispatch_set_target_queue(serialQueue5, targetSerialQueue);
    
    dispatch_async(serialQueue1, ^{
        NSLog(@"1");
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@"2");
    });
    dispatch_async(serialQueue3, ^{
        NSLog(@"3");
    });
    dispatch_async(serialQueue4, ^{
        NSLog(@"4");
    });
    dispatch_async(serialQueue5, ^{
        NSLog(@"5");
    });
    
    /*
     有顺序了
     2017-02-28 21:38:06.606 GCDLearn[1506:75803] 1
     2017-02-28 21:38:06.607 GCDLearn[1506:75803] 2
     2017-02-28 21:38:06.607 GCDLearn[1506:75803] 3
     2017-02-28 21:38:06.608 GCDLearn[1506:75803] 4
     2017-02-28 21:38:06.608 GCDLearn[1506:75803] 5
     */
    
    /*
     在必须将不可并行执行的处理追加到多个Serial Dispatch Queue中时，
     如果使用dispatch_set_target_queue函数将目标指定为某一个Serial Dispatch Queue，
     即可防止处理并行执行
     */
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
