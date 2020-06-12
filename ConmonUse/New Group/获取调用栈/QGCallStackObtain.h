//
//  QGCallStackObtain.h
//  ConmonUse
//
//  Created by qiaogang02 on 2020/5/9.
//  Copyright © 2020 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QGCallStackObtain : NSObject
+ (void)clallStack;

+ (NSString *)bs_backtraceOfAllThread;
+ (NSString *)bs_backtraceOfCurrentThread;
+ (NSString *)bs_backtraceOfMainThread;
+ (NSString *)bs_backtraceOfNSThread:(NSThread *)thread;

@end

NS_ASSUME_NONNULL_END
