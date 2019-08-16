//
//  main.m
//  ConmonUse
//
//  Created by jorgon on 06/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <DecompilationProtect/DecompilationProtect.h>
#import <DecompilationProtect/QGDecopilationProtect.h>


static __attribute__((always_inline)) void AntiDebugASM() {
    printf("11111");
#ifdef __arm__
    asm volatile(
                 "mov r0,#31\n"
                 "mov r1,#0\n"
                 "mov r2,#0\n"
                 "mov r12,#26\n"
                 "svc #80\n"
                 );
#endif
#ifdef __arm64__
    asm volatile(
                 "mov x0,#26\n"
                 "mov x1,#31\n"
                 "mov x2,#0\n"
                 "mov x3,#0\n"
                 "mov x16,#0\n"
                 "svc #128\n"
                 );
#endif
#ifdef __arm64e__
    asm volatile(
                 "mov x0,#26\n"
                 "mov x1,#31\n"
                 "mov x2,#0\n"
                 "mov x3,#0\n"
                 "mov x16,#0\n"
                 "svc #128\n"
                 );
#endif
#ifdef __armv7__
    asm volatile(
                 "mov x0,#26\n"
                 "mov x1,#31\n"
                 "mov x2,#0\n"
                 "mov x3,#0\n"
                 "mov x16,#0\n"
                 "svc #128\n"
                 );
#endif
#ifdef __armv7s__
    asm volatile(
                 "mov x0,#26\n"
                 "mov x1,#31\n"
                 "mov x2,#0\n"
                 "mov x3,#0\n"
                 "mov x16,#0\n"
                 "svc #128\n"
                 );
#endif
    
}


int main(int argc, char * argv[]) {
    @autoreleasepool {
        AntiDebugASM();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
