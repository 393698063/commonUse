//
//  SignalHandler.h
//  ConmonUse
//
//    on 2018/11/9.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/signal.h>
NS_ASSUME_NONNULL_BEGIN

@interface SignalHandler : NSObject
+ (instancetype)Instance;
//注册捕获信号的方法
+ (void)RegisterSignalHandler;
@end

NS_ASSUME_NONNULL_END
