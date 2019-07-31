//
//  ObjectAdressTransmit.m
//  ConmonUse
//
//  Created by jorgon on 2019/1/17.
//  Copyright © 2019年 jorgon. All rights reserved.
//

#import "ObjectAdressTransmit.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>

@implementation ObjectAdressTransmit
/*
 * malloc_size
 返回指针所指向对象字节数。但是这种方法不会考虑到对象成员变量指针所指向对象所占用的内存。
 跟instrument 的 Allocation计算出来的值相同。
 
 使用 Runtime 中 class_getInstanceSize 输出一个类的实例对象的成员变量的大小
 */

//对象占用内存大小
+ (void)objcSize {
    NSObject *objc = [[NSObject alloc] init];
    NSLog(@"animal对象实际需要的内存大小: %zd", class_getInstanceSize([objc class]));
    NSLog(@"animal对象实际分配的内存大小: %zd", malloc_size((__bridge const void *)(objc)));
    
}

+ (id)addressToObj:(NSString *)address
{
    if (![address hasPrefix:@"0x"]) return nil;
    
    Class cls = nil;
    NSString *realAddress = nil;
    
    NSArray *arr = [address componentsSeparatedByString:@"__objCls__"];
    if (arr.count > 2) return nil;
    
    realAddress = [arr objectAtIndex:0];
    if (arr.count == 2) {
        cls = NSClassFromString([arr objectAtIndex:1]);
    }
    //strtol，strtoll，strtoul, strtoull字符串转化成数字
    unsigned long long hex = strtoull(address.UTF8String, NULL, 0);
    size_t size = malloc_size((const void *)hex);
    if (size >= 16) {
        id obj = (__bridge id)(void *)hex;
        if (cls) {
            if ([obj isKindOfClass:cls]) return obj;
            return nil;
        }
        return obj;
    }
    return nil;
}


+ (NSString *)objToAddress:(id)obj containClass:(BOOL)containCls
{
    if (obj && [obj class]) {
        __unused void *p = (__bridge_retained void *)(obj);
        NSString * address = [NSString stringWithFormat:@"%p%@", obj, containCls ? [NSString stringWithFormat:@"__objCls__%@", NSStringFromClass([obj class])] : @""];
        // 延迟释放
        __weak typeof(obj) weakObj = obj;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakObj) strongObj = weakObj;
            if (!strongObj) {
                NSAssert(NO, @"对象%@已经被提前释放，这是个bug", address);
                return ;
            }
            CFRelease(p);
        });
        return address;
    } else {
        return nil;
    }
}





@end
