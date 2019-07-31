//
//  DLOpenFrameworkViewController.m
//  ConmonUse
//
//  Created by jorgon on 2019/1/15.
//  Copyright © 2019年 jorgon. All rights reserved.
//
/*
 函数定义：
 　　void * dlopen( const char * pathname, int mode );
 　　函数描述：
 　　在dlopen的（）函数以指定模式打开指定的动态连接库文件，并返回一个句柄给调用进程。使用dlclose（）来卸载打开的库。
 　　mode：分为这两种
 　　RTLD_LAZY 暂缓决定，等有需要时再解出符号
 　　RTLD_NOW 立即决定，返回前解除所有未决定的符号。
 　　RTLD_LOCAL
 　　RTLD_GLOBAL 允许导出符号
 　　RTLD_GROUP
 　　RTLD_WORLD
 
 　　返回值:
 　　打开错误返回NULL
 　　成功，返回库引用
 　　编译时候要加入 -ldl (指定dl库)
 */
#import "DLOpenFrameworkViewController.h"
#include <dlfcn.h>

@interface DLOpenFrameworkViewController ()
@property (nonatomic,strong) id runtime_Player;
@end

@implementation DLOpenFrameworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self runtimePlay];
}

- (void)runtimePlay{
    // 获取音乐资源路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp3"];
    // 加载库到当前运行程序
    void *lib = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", RTLD_LAZY);
    if (lib) {
        // 获取类名称
        Class playerClass = NSClassFromString(@"AVAudioPlayer");
        // 获取函数方法
        SEL selector = NSSelectorFromString(@"initWithData:error:");
        // 调用实例化对象方法
        _runtime_Player = [[playerClass alloc] performSelector:selector withObject:[NSData dataWithContentsOfFile:path] withObject:nil];
        // 获取函数方法
        selector = NSSelectorFromString(@"play");
        // 调用播放方法
        [_runtime_Player performSelector:selector];
        NSLog(@"动态加载播放");
    }
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
