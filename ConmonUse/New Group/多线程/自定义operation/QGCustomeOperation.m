//
//  QGCustomeOperation.m
//  ConmonUse
//
//  Created by qiaogang02 on 2020/2/13.
//  Copyright © 2020 jorgon. All rights reserved.
//
/**
 自定义并发的NSOperation
 自定义并发的NSOperation需要以下步骤：
 1.start方法：该方法必须实现，
 2.main:该方法可选，如果你在start方法中定义了你的任务，则这个方法就可以不实现，但通常为了代码逻辑清晰，通常会在该方法中定 义自己的任务
 3.isExecuting isFinished 主要作用是在线程状态改变时，产生适当的KVO通知
 4.isConcurrent :必须覆盖并返回YES;
 */
#import "QGCustomeOperation.h"

@interface QGCustomeOperation ()
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end

@implementation QGCustomeOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            return;
        }
    }
}

- (id)init {
    if(self = [super init])
    {
        _executing = NO;
        _finished = NO;
    }
    return self;
}
- (BOOL)isConcurrent {
    return YES;
}
- (BOOL)isExecuting {
    return _executing;
}
- (BOOL)isFinished {
    return _finished;
}
//- (void)start {
//    //第一步就要检测是否被取消了，如果取消了，要实现相应的KVO
//    if ([self isCancelled]) {
//        [self willChangeValueForKey:@"isFinished"];
//        finished = YES;
//        [self didChangeValueForKey:@"isFinished"];
//        return;
//    }
//    //如果没被取消，开始执行任务
//    [self willChangeValueForKey:@"isExecuting"];
//    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
//    executing = YES;
//    [self didChangeValueForKey:@"isExecuting"];
//}

//metrics 指标 获取网络请求的各种时间 任务时间，dns时间 tcp时间
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    NSArray *array = metrics.transactionMetrics;
    for (NSURLSessionTaskTransactionMetrics *transaction in array) {
        if (transaction.resourceFetchType == NSURLSessionTaskMetricsResourceFetchTypeNetworkLoad ) {
            //request time
            NSTimeInterval taskTime = ([transaction.domainLookupStartDate timeIntervalSince1970] - [transaction.fetchStartDate timeIntervalSince1970]) * 1000000;
            NSTimeInterval dnsTime = ([transaction.domainLookupEndDate timeIntervalSince1970] - [transaction.domainLookupStartDate timeIntervalSince1970]) * 1000000;
            NSTimeInterval tcpTime = ([transaction.secureConnectionStartDate timeIntervalSince1970] - [transaction.connectStartDate timeIntervalSince1970]) * 1000000;
            NSTimeInterval sslTime = ([transaction.secureConnectionEndDate timeIntervalSince1970] - [transaction.secureConnectionStartDate timeIntervalSince1970]) * 1000000;
            NSTimeInterval sendTime = ([transaction.requestEndDate timeIntervalSince1970] - [transaction.requestStartDate timeIntervalSince1970]) * 1000000;
            NSTimeInterval ttfbTime = ([transaction.responseStartDate timeIntervalSince1970] - [transaction.requestEndDate timeIntervalSince1970]) * 1000000;
            NSTimeInterval bodyTime = ([transaction.responseEndDate timeIntervalSince1970] - [transaction.responseStartDate timeIntervalSince1970]) * 1000000;
            
//            [_timeDic setValue:@([transaction.fetchStartDate timeIntervalSince1970] * 1000) forKey:@"native-fetchStart"];
//            [_timeDic setValue:@([transaction.responseEndDate timeIntervalSince1970] * 1000) forKey:@"native-responseEnd"];
//            [_timeDic setValue:@(taskTime) forKey:@"native-task"];
//            [_timeDic setValue:@(dnsTime) forKey:@"native-dns"];
//            [_timeDic setValue:@(tcpTime) forKey:@"native-tcp"];
//            [_timeDic setValue:@(sslTime) forKey:@"native-ssl"];
//            [_timeDic setValue:@(sendTime) forKey:@"native-send"];
//            [_timeDic setValue:@(ttfbTime) forKey:@"native-ttfb"];
//            [_timeDic setValue:@(bodyTime) forKey:@"native-body"];
//            [_timeDic setValue:transaction.networkProtocolName forKey:@"native-protocol"];
//            [_timeDic setValue:@(transaction.proxyConnection) forKey:@"native-proxy"];
            break;
        }
    }
}
@end
