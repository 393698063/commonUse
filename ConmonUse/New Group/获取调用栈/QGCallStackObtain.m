//
//  QGCallStackObtain.m
//  ConmonUse
//
//  Created by qiaogang02 on 2020/5/9.
//  Copyright © 2020 jorgon. All rights reserved.
//
/**
 什么是调用栈？
 如何抓取线程当前的调用栈？
 如何符号化解析？
 一些特殊的调用栈
 （补充）如何检测App卡顿？
 */
//https://bestswifter.com/callstack/
/**
 调用栈：它是每个线程独享的一种数据结构
    栈帧：函数参数，返回地址，帧内的变量
 */
#import "QGCallStackObtain.h"
#import <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <sys/types.h>
#include <limits.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>
//https://juejin.im/post/5eb275f4f265da7bc4282c93
/**
 我们已经知道了通过fp就能找到上一级函数的地址。
 通过不停的找上一级fp就能找到当前所有方法调用栈的地址。（回溯法）
 栈帧结构{
 参数地址
 返回地址
 本地变量
 }
 */

// 栈帧结构体：
typedef struct BSStackFrameEntry{
    const struct BSStackFrameEntry *const previous; //!< 上一个栈帧
    const uintptr_t return_address;                 //!< 当前栈帧的地址
} BSStackFrameEntry;

@implementation QGCallStackObtain
+ (void)clallStack {
   NSArray * stacks = [NSThread callStackSymbols];
    NSLog(@"callStack: \n %@",stacks);
    /**
     callStack:
      (
         0   ConmonUse                           0x0000000106d7992f +[QGCallStackObtain clallStack] + 47
         1   ConmonUse                           0x0000000106d671fb -[ViewController viewDidLoad] + 91
         2   UIKitCore                           0x00007fff46f03d96 -[UIViewController _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 83
         3   UIKitCore                           0x00007fff46f08cef -[UIViewController loadViewIfRequired] + 1084
         4   UIKitCore                           0x00007fff46e6d2b0 -[UINavigationController _updateScrollViewFromViewController:toViewController:] + 160
         5   UIKitCore                           0x00007fff46e6d5b0 -[UINavigationController _startTransition:fromViewController:toViewController:] + 140
         6   UIKitCore                           0x00007fff46e6e47a -[UINavigationController _startDeferredTransitionIfNeeded:] + 868
         7   UIKitCore                           0x00007fff46e6f7e5 -[UINavigationController __viewWillLayoutSubviews] + 150
         8   UIKitCore                           0x00007fff46e51127 -[UILayoutContainerView layoutSubviews] + 217
         9   UIKitCore                           0x00007fff47a52ad5 -[UIView(CALayerDelegate) layoutSublayersOfLayer:] + 2478
         10  QuartzCore                          0x00007fff2b06e91d -[CALayer layoutSublayers] + 255
         11  QuartzCore                          0x00007fff2b073323 _ZN2CA5Layer16layout_if_neededEPNS_11TransactionE + 517
         12  QuartzCore                          0x00007fff2b07fa7c _ZN2CA5Layer28layout_and_display_if_neededEPNS_11TransactionE + 80
         13  QuartzCore                          0x00007fff2afc6e54 _ZN2CA7Context18commit_transactionEPNS_11TransactionEd + 324
         14  QuartzCore                          0x00007fff2affc32f _ZN2CA11Transaction6commitEv + 643
         15  UIKitCore                           0x00007fff475906cd __34-[UIApplication _firstCommitBlock]_block_invoke_2 + 81
         16  CoreFoundation                      0x00007fff23b0d09c __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__ + 12
         17  CoreFoundation                      0x00007fff23b0c808 __CFRunLoopDoBlocks + 312
         18  CoreFoundation                      0x00007fff23b07694 __CFRunLoopRun + 1284
         19  CoreFoundation                      0x00007fff23b06e66 CFRunLoopRunSpecific + 438
         20  GraphicsServices                    0x00007fff38346bb0 GSEventRunModal + 65
         21  UIKitCore                           0x00007fff47578dd0 UIApplicationMain + 1621
         22  ConmonUse                           0x0000000106d68b41 main + 129
         23  libdyld.dylib                       0x00007fff516ecd29 start + 1
     )
     */
}

+ (void)readStack {
    NSThread
}

@end
