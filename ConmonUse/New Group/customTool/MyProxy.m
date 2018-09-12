//
//  MyProxy.m
//  消息代理NSProxy
//
//  Created by jorgon on 03/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "MyProxy.h"

@interface MyProxy ()
@property (nullable, nonatomic, weak, readonly) id target;
@end

@implementation MyProxy

+ (id)proxyWithTarget:(id)target{
    MyProxy * proxy = [MyProxy alloc];
    proxy->_target = target;
    
    return proxy;
}
// 也可以单独实现这一个方法；
- (id)forwardingTargetForSelector:(SEL)aSelector{
    return _target;
}

//重写以下俩个方法
- (void)forwardInvocation:(NSInvocation *)invocation{
    if ([_target respondsToSelector:invocation.selector]) {
//        NSLog(@"Before calling \"%@\".", NSStringFromSelector(invocation.selector));
        [invocation invokeWithTarget:_target];
//        NSLog(@"After calling \"%@\".", NSStringFromSelector(invocation.selector));
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    
    return [_target methodSignatureForSelector:sel];
}

@end
