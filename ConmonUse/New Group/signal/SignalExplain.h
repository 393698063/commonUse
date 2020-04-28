//
//  SignalExplain.h
//  ConmonUse
//
//    on 2018/11/9.
//  Copyright © 2018年 jorgon. All rights reserved.
//
/*
 什么是Signal
 
 在计算机科学中，信号（英语：Signals）是Unix、类Unix以及其他POSIX兼容的操作系统中进程间通讯的一种有限制的方式。
 它是一种异步的通知机制，用来提醒进程一个事件已经发生。当一个信号发送给一个进程，
 操作系统中断了进程正常的控制流程，此时，任何非原子操作都将被中断。如果进程定义了信号的处理函数，
 那么它将被执行，否则就执行默认的处理函数。
 */
/*
 如何使用Signal
 
 
 在项目工程中，要使用 Signal 时，通过引入 signal.h 来使用:
 
 #include <sys/signal.h>
 在 sys/signal 文件内定义了大量的系统信号标识
 
 使用这些信号标识，要通过函数 void (*signal(int, void (*)(int)))(int); 来进行使用,如下所示:
 //定义一个接收到信号的回调函数
 void HandleException(int signo)
 {
 printf("Lanou's sig is:%d",signo);
 }
 //注册Alerm信号的回调函数
 signal(SIGALRM, HandleException);
 信号处理函数可以通过 signal() 系统调用来设置。如果没有为一个信号设置对应的处理函数，
 就会使用默认的处理函数，否则信号就被进程截获并调用相应的处理函数。在没有处理函数的情况下，
 程序可以指定两种行为：忽略这个信号 SIG_IGN 或者用默认的处理函数 SIG_DFL 。
 但是有两个信号是无法被截获并处理的： SIGKILL、SIGSTOP 。
 */

/*
 Signal信号的类型
 
 SIGABRT--程序中止命令中止信号
 SIGALRM--程序超时信号
 SIGFPE--程序浮点异常信号
 SIGILL--程序非法指令信号
 SIGHUP--程序终端中止信号
 SIGINT--程序键盘中断信号
 SIGKILL--程序结束接收中止信号
 SIGTERM--程序kill中止信号
 SIGSTOP--程序键盘中止信号
 SIGSEGV--程序无效内存中止信号
 SIGBUS--程序内存字节未对齐中止信号
 SIGPIPE--程序Socket发送失败中止信号
 */


// 运行信号demo 需要在viewdidoload中断点 在控制台 pro hand -p true -s false SIGABRT
#ifndef SignalExplain_h
#define SignalExplain_h


#endif /* SignalExplain_h */
