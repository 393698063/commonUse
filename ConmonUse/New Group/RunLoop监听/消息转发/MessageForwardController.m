//
//  MessageForwardController.m
//  ConmonUse
//
//  Created by jorgon on 23/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "MessageForwardController.h"
#import <objc/runtime.h>

@interface methodHelper : NSObject
- (void)methodHelper;
@end

@implementation methodHelper
- (void)methodHelper{
    NSLog(@"%@, %p", self, _cmd);
}
@end

@interface MessageForwardController ()
{
    dispatch_semaphore_t  _lock;
}
@end

@implementation MessageForwardController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _lock = dispatch_semaphore_create(1);
    self.title = @"消息转发";
    [self performSelector:@selector(add:) withObjects:@[@[@1,@2,@3]]];
//    [self performSelector:@selector(add:) withObjects:@[@[@1,@2,@3]]];
    [self performSelector:@selector(tt) withObjects:nil];
}

#pragma mark - 消息转发流程
//+ (BOOL)resolveClassMethod:(SEL)sel{
//    return YES;
//}
//+ (BOOL)resolveInstanceMethod:(SEL)sel{
//
//    //不过这种方案更多的是为了实现@dynamic属性，新增的方法提前实现了
//    //    _objc_msgForward();
//    NSLog(@"method: %@",NSStringFromSelector(sel));
//    BOOL rtn = [super resolveInstanceMethod:sel];
//
//    NSString * method = NSStringFromSelector(sel);
//    if ([method isEqualToString:@"tt"]) {
////        * @return YES if the method was added successfully, otherwise NO
////            *  (for example, the class already contains a method implementation with that name).
//       BOOL isAdd = class_addMethod(self.class, sel, class_getMethodImplementation(self, @selector(startEngine:)), "s@:@");
//        if (isAdd) {
//            class_replaceMethod(self.class, sel, class_getMethodImplementation(self, @selector(startEngine:)), "s@:@");
//        }
//        return YES;
//    }
//
//    return  rtn;
//}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    /*
     如果一个对象实现了这个方法，并返回一个非nil的结果，
     则这个对象会作为消息的新接收者，且消息会被分发到这个对象。
     当然这个对象不能是self自身，否则就是出现无限循环
     
     这一步合适于我们只想将消息转发到另一个能处理该消息的对象上。
     但这一步无法对消息进行处理，如操作消息的参数和返回值。
     */
    
    methodHelper * helper = [methodHelper new];
    BOOL didAddMethod =  class_addMethod([methodHelper class], aSelector, class_getMethodImplementation(NSClassFromString(@"methodHelper"), @selector(methodHelper)), "s@:@");
    
    if (didAddMethod) {
        class_replaceMethod([methodHelper class],
                            aSelector,
                            class_getMethodImplementation(NSClassFromString(@"methodHelper"), @selector(methodHelper)),"s@:@");
    }
    
    
    return helper;
}


- (void)startEngine:(id)obj{
    NSLog(@"%@",@"startEngine");
}








#pragma mark - 多参数performSelector
- (NSString *)add:(NSArray *)args{
    NSInteger total = 0;
    for (int i = 0; i < args.count; i ++) {
        total += ((NSNumber *)args[i]).integerValue;
    }
    NSLog(@"和是：%ld",total);
    return @"ttt";
}
//多参数perform
- (id)performSelector:(SEL)aSelector withObjects:(NSArray *)objects{
//    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    // 方法签名（方法的描述）
//    NSMethodSignature * signature = [[self class] instanceMethodSignatureForSelector:aSelector];
   NSMethodSignature * signature = [self methodSignatureForSelector:aSelector];
    if (signature == nil) {
        // 可以抛出异常也可以不操作
        return nil;
    }
    if (![self respondsToSelector:aSelector]) {
        return nil;
    }
    //    NSMethodSignature * aSignature = [self methodSignatureForSelector:aSelector];
    //NSInvocation : 利用一个NSInvocation对象包装一次方法调用
    //    （方法调用者、方法名、方法参数、方法返回值
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = aSelector;
    NSInteger paramsCount = signature.numberOfArguments - 2;//除self,_cmd意外的参数个数
    paramsCount = MIN(paramsCount, objects.count);
    for (NSInteger i = 0; i < paramsCount; i ++) {
        id object = objects[i];
        if ([object isKindOfClass:[NSNull class]]) {
            continue;
        }
        [invocation setArgument:&object atIndex:i + 2];
    }
    if (!invocation.argumentsRetained) {
        [invocation retainArguments];
    }
    [invocation invoke];
    
    //获得返回值类型
    const char *returnType = signature.methodReturnType;
    
    id returnValue = nil;
    void *tempResultSet = NULL;
    //如果没有返回值，也就是消息声明为void，那么returnValue=nil
    if( !strcmp(returnType, @encode(void)) ){
            returnValue =  nil;
    }
    //如果返回值为对象，那么为变量赋值
    else if( !strcmp(returnType, @encode(id)) ){
        
        [invocation getReturnValue:&tempResultSet];
        returnValue = (__bridge id)(tempResultSet);//防止某些崩溃 https://segmentfault.com/q/1010000006086673/a-1020000006095964
    }
    else{
        //如果返回值为普通类型NSInteger  BOOL
        //返回值长度
        NSUInteger length = [signature methodReturnLength];
        //根据长度申请内存
        void *buffer = (void *)malloc(length);
        //为变量赋值
        [invocation getReturnValue:buffer];
        if( !strcmp(returnType, @encode(BOOL)) ) {
            returnValue = [NSNumber numberWithBool:*((BOOL*)buffer)];
        }
        else if( !strcmp(returnType, @encode(NSInteger)) ){
            returnValue = [NSNumber numberWithInteger:*((NSInteger*)buffer)];
        }
        else{
            returnValue = [NSValue valueWithBytes:buffer objCType:returnType];
        }
        free(buffer);
    }
    
//    if (signature.methodReturnLength > 2) {
//        [invocation getReturnValue:&tempResultSet];
//        returnValue = (__bridge id)(tempResultSet);//防止某些崩溃 https://segmentfault.com/q/1010000006086673/a-1020000006095964
//    }
//    dispatch_semaphore_signal(_lock);
    return returnValue;
}

- (void)dealloc{
    NSLog(@"%s",__func__);
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
