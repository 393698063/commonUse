//
//  MeasureOperationTimeViewController.m
//  ConmonUse
//
//  Created by jorgon on 31/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "MeasureOperationTimeViewController.h"
//Benchmarking the Execution Time of an operation
/*
 基准测试
 
 在 GCD 的一个不起眼的角落，你会发现一个适合优化代码的灵巧小工具
 把这个声明放到你的代码中，你就能够测量给定的代码执行的平均的纳秒数
 */
extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));


@interface MeasureOperationTimeViewController ()

@end

@implementation MeasureOperationTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self test];
}

- (void)test{
    size_t const objectCount = 1000;
    uint64_t t = dispatch_benchmark(10000, ^{
        @autoreleasepool {
            id obj = @42;
            NSMutableArray *array = [NSMutableArray array];
            for (size_t i = 0; i < objectCount; ++i) {
                [array addObject:obj];
            }
        }
    });
    NSLog(@"-[NSMutableArray addObject:] : %llu ns", t);
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
