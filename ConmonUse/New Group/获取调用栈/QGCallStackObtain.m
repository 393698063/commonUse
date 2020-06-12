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
/**
   1 task_threads 获取当前所有线程，遍历所有线程通过thread_info获取各个线程的详细信息
 
 对于每一个线程，可以用 thread_get_state 方法获取它的所有信息，
 信息填充在 _STRUCT_MCONTEXT 类型的参数中。
 这个方法中有两个参数随着 CPU 架构的不同而改变，
 因此我定义了 BS_THREAD_STATE_COUNT 和 BS_THREAD_STATE 这两个宏用于屏蔽不同 CPU 之间的区别
 在 _STRUCT_MCONTEXT 类型的结构体中，存储了当前线程的 Stack Pointer 和最顶部栈帧的 Frame Pointer
 ，从而获取到了整个线程的调用栈
 
   2 thread_get_state 得到machine context 里面函数调用指针
 2创建栈结构体
 3根据获取到的栈帧地址，找到对应的image的游标，从而能够获取image的更多信息
 5. 知道image后，根据Mach-O文件的结构，先找到Mach-O里对应的Header通过_dyld_get_image_header
    找到mach_header结构体，然后使用_dyld_get_image_vmaddr_slide方法，获取虚拟内存地址slide（偏移）的数量
 动态链接器    偏移量 + image基地址  = 虚拟地址空间
 6. 计算ASLR
 7， 遍历所有segment， 查找目标地址在那个 segment里
 */
/**
@abstract NSThread 的封装层级
 很多文章都提到了 NSThread 是 pthread 的封装，这就涉及两个问题:

 pthread 是什么
 NSThread 如何封装 pthread
 pthread 中的字母 p 是 POSIX 的简写，POSIX 表示 “可移植操作系统接口(Portable Operating System Interface)”。

 每个操作系统都有自己的线程模型，不同操作系统提供的，操作线程的 API 也不一样，这就给跨平台的线程管理带来了问题，而 POSIX 的目的就是提供抽象的 pthread 以及相关 API，这些 API 在不同操作系统中有不同的实现，但是完成的功能一致。

 Unix 系统提供的 thread_get_state 和 task_threads 等方法，操作的都是内核线程，每个内核线程由 thread_t 类型的 id 来唯一标识，pthread 的唯一标识是 pthread_t 类型。

 内核线程和 pthread 的转换(也即是 thread_t 和 pthread_t 互转)很容易，因为 pthread 诞生的目的就是为了抽象内核线程。

 说 NSThread 封装了 pthread 并不是很准确，NSThread 内部只有很少的地方用到了 pthread。NSThread 的 start 方法简化版实现如下:

 - (void) start {
   pthread_attr_t    attr;
   pthread_t        thr;
   errno = 0;
   pthread_attr_init(&attr);
   if (pthread_create(&thr, &attr, nsthreadLauncher, self)) {
       // Error Handling
   }
 }
 
 甚至于 NSThread 都没有存储新建 pthread 的 pthread_t 标识。

 另一处用到 pthread 的地方就是 NSThread 在退出时，调用了 pthread_exit()。除此以外就很少感受到 pthread 的存在感了，因此个人认为 “NSThread 是对 pthread 的封装” 这种说法并不准确。


 @description  主线程转内核 thread
 本来以为问题已经圆满解决，不料还有一个坑，主线程设置 name 后无法用 pthread_getname_np 读取到。

 好在我们还可以迂回解决问题: 事先获得主线程的 thread_t，然后进行比对。

 上述方案要求我们在主线程中执行代码从而获得 thread_t，显然最好的方案是在 load 方法里:

 + (void)load {
     main_thread_id = mach_thread_self();
 }
 */

//https://www.cnblogs.com/LiLihongqiang/p/7645987.html

#pragma -mark DEFINE MACRO FOR DIFFERENT CPU ARCHITECTURE
#if defined(__arm64__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(3UL))
#define BS_THREAD_STATE_COUNT ARM_THREAD_STATE64_COUNT
#define BS_THREAD_STATE ARM_THREAD_STATE64
#define BS_FRAME_POINTER __fp
#define BS_STACK_POINTER __sp
#define BS_INSTRUCTION_ADDRESS __pc

#elif defined(__arm__)
#define DETAG_INSTRUCTION_ADDRESS(A) ((A) & ~(1UL))
#define BS_THREAD_STATE_COUNT ARM_THREAD_STATE_COUNT
#define BS_THREAD_STATE ARM_THREAD_STATE
#define BS_FRAME_POINTER __r[7]
#define BS_STACK_POINTER __sp
#define BS_INSTRUCTION_ADDRESS __pc

#elif defined(__x86_64__)
#define DETAG_INSTRUCTION_ADDRESS(A) (A)
#define BS_THREAD_STATE_COUNT x86_THREAD_STATE64_COUNT
#define BS_THREAD_STATE x86_THREAD_STATE64
#define BS_FRAME_POINTER __rbp
#define BS_STACK_POINTER __rsp
#define BS_INSTRUCTION_ADDRESS __rip

#elif defined(__i386__)
#define DETAG_INSTRUCTION_ADDRESS(A) (A)
#define BS_THREAD_STATE_COUNT x86_THREAD_STATE32_COUNT
#define BS_THREAD_STATE x86_THREAD_STATE32
#define BS_FRAME_POINTER __ebp
#define BS_STACK_POINTER __esp
#define BS_INSTRUCTION_ADDRESS __eip

#endif

#define CALL_INSTRUCTION_FROM_RETURN_ADDRESS(A) (DETAG_INSTRUCTION_ADDRESS((A)) - 1)

#if defined(__LP64__)
#define TRACE_FMT         "%-4d%-31s 0x%016lx %s + %lu"
#define POINTER_FMT       "0x%016lx"
#define POINTER_SHORT_FMT "0x%lx"
#define BS_NLIST struct nlist_64
#else
#define TRACE_FMT         "%-4d%-31s 0x%08lx %s + %lu"
#define POINTER_FMT       "0x%08lx"
#define POINTER_SHORT_FMT "0x%lx"
#define BS_NLIST struct nlist
#endif
// 栈帧结构体：
typedef struct BSStackFrameEntry{
    const struct BSStackFrameEntry *const previous; //!< 上一个栈帧
    const uintptr_t return_address;                 //!< 当前栈帧的地址
} BSStackFrameEntry;

static mach_port_t main_thread_id;

+ (void)load {
    main_thread_id = mach_thread_self();
}

+ (void)readStack {
    [NSThread new];
}


+ (NSString *)bs_backtraceOfAllThread {
    thread_act_array_t threads;
    mach_msg_type_number_t thread_count = 0;
    const task_t this_task = mach_task_self(); //相当于进程，获得任务的端口，带有发送权限的名称
    
    kern_return_t kr = task_threads(this_task, &threads, &thread_count);
    if(kr != KERN_SUCCESS) {
        return @"Fail to get information of all threads";
    }
    
    NSMutableString *resultString = [NSMutableString stringWithFormat:@"Call Backtrace of %u threads:\n", thread_count];
    for(int i = 0; i < thread_count; i++) {
        [resultString appendString:_bs_backtraceOfThread(threads[i])];
    }
    return [resultString copy];
}

#pragma -mark Get call backtrace of a mach_thread
NSString *_bs_backtraceOfThread(thread_t thread) {
    uintptr_t backtraceBuffer[50]; // unsigned long
    int i = 0;
    NSMutableString *resultString = [[NSMutableString alloc] initWithFormat:@"Backtrace of Thread %u:\n", thread];
    
    _STRUCT_MCONTEXT machineContext;
    if(!bs_fillThreadStateIntoMachineContext(thread, &machineContext)) {
        return [NSString stringWithFormat:@"Fail to get information about thread: %u", thread];
    }
    //    machineContext->__ss.__rip
    const uintptr_t instructionAddress = bs_mach_instructionAddress(&machineContext);
    backtraceBuffer[i] = instructionAddress;
    ++i;
    
    uintptr_t linkRegister = bs_mach_linkRegister(&machineContext);
    if (linkRegister) {
        backtraceBuffer[i] = linkRegister;
        i++;
    }

    if(instructionAddress == 0) {
        return @"Fail to get instruction address";
    }
    
    BSStackFrameEntry frame = {0}; ///    machineContext->__ss.__rbp
    const uintptr_t framePtr = bs_mach_framePointer(&machineContext);
    if(framePtr == 0 ||
       bs_mach_copyMem((void *)framePtr, &frame, sizeof(frame)) != KERN_SUCCESS) {
        return @"Fail to get frame pointer";
    }
    
    for(; i < 50; i++) {
        backtraceBuffer[i] = frame.return_address;
        if(backtraceBuffer[i] == 0 ||
           frame.previous == 0 ||
           bs_mach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS) {
            break;
        }
    }
    
    int backtraceLength = i;
    Dl_info symbolicated[backtraceLength];
    bs_symbolicate(backtraceBuffer, symbolicated, backtraceLength, 0);
    for (int i = 0; i < backtraceLength; ++i) {
        [resultString appendFormat:@"%@", bs_logBacktraceEntry(i, backtraceBuffer[i], &symbolicated[i])];
    }
    [resultString appendFormat:@"\n"];
    return [resultString copy];
}

#pragma -mark Convert NSThread to Mach thread
thread_t bs_machThreadFromNSThread(NSThread *nsthread) {
    char name[256];
    mach_msg_type_number_t count;
    thread_act_array_t list; // 获取内核线程
    // mach task 线程的执行环境
    task_threads(mach_task_self(), &list, &count);//获取当前所有线程
    
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    NSString *originName = [nsthread name];
    [nsthread setName:[NSString stringWithFormat:@"%f", currentTimestamp]];
    
    if ([nsthread isMainThread]) {
        return (thread_t)main_thread_id;
    }
    
    for (int i = 0; i < count; ++i) {
        pthread_t pt = pthread_from_mach_thread_np(list[i]);
        if ([nsthread isMainThread]) {
            if (list[i] == main_thread_id) {
                return list[i];
            }
        }
        if (pt) {
            name[0] = '\0';
            pthread_getname_np(pt, name, sizeof name);
            if (!strcmp(name, [nsthread name].UTF8String)) {
                [nsthread setName:originName];
                return list[i];
            }
        }
    }
    
    [nsthread setName:originName];
    return mach_thread_self();
}

#pragma -mark GenerateBacbsrackEnrty
NSString* bs_logBacktraceEntry(const int entryNum,
                               const uintptr_t address,
                               const Dl_info* const dlInfo) {
    char faddrBuff[20];
    char saddrBuff[20];
    
    const char* fname = bs_lastPathEntry(dlInfo->dli_fname);
    if(fname == NULL) {
        sprintf(faddrBuff, POINTER_FMT, (uintptr_t)dlInfo->dli_fbase);
        fname = faddrBuff;
    }
    
    uintptr_t offset = address - (uintptr_t)dlInfo->dli_saddr;
    const char* sname = dlInfo->dli_sname;
    if(sname == NULL) {
        sprintf(saddrBuff, POINTER_SHORT_FMT, (uintptr_t)dlInfo->dli_fbase);
        sname = saddrBuff;
        offset = address - (uintptr_t)dlInfo->dli_fbase;
    }
    return [NSString stringWithFormat:@"%-30s  0x%08" PRIxPTR " %s + %lu\n" ,fname, (uintptr_t)address, sname, offset];
}

const char* bs_lastPathEntry(const char* const path) {
    if(path == NULL) {
        return NULL;
    }
    
    char* lastFile = strrchr(path, '/');
    return lastFile == NULL ? path : lastFile + 1;
}
#pragma -mark HandleMachineContext
bool bs_fillThreadStateIntoMachineContext(thread_t thread, _STRUCT_MCONTEXT *machineContext) {
    mach_msg_type_number_t state_count = BS_THREAD_STATE_COUNT;
    // thread_get_state 获取线程信息
    kern_return_t kr = thread_get_state(thread, BS_THREAD_STATE, (thread_state_t)&machineContext->__ss, &state_count);
    return (kr == KERN_SUCCESS);
}

uintptr_t bs_mach_framePointer(mcontext_t const machineContext){
    return machineContext->__ss.BS_FRAME_POINTER;
}

uintptr_t bs_mach_stackPointer(mcontext_t const machineContext){
    return machineContext->__ss.BS_STACK_POINTER;
}

uintptr_t bs_mach_instructionAddress(mcontext_t const machineContext){
    return machineContext->__ss.BS_INSTRUCTION_ADDRESS;
}
/**
 _STRUCT_MCONTEXT32
 {
     _STRUCT_X86_EXCEPTION_STATE32   __es;
     _STRUCT_X86_THREAD_STATE32      __ss;
     _STRUCT_X86_FLOAT_STATE32       __fs;
 };
 */
uintptr_t bs_mach_linkRegister(mcontext_t const machineContext){
#if defined(__i386__) || defined(__x86_64__)
    return 0;
#else
    return machineContext->__ss.__lr;
#endif
}

kern_return_t bs_mach_copyMem(const void *const src, void *const dst, const size_t numBytes){
    vm_size_t bytesCopied = 0;
    //mach_vm_read_overwrite 的低级函数. 这个函数可以在其中指定两个指针以及从一个指针复制到另一个指针的字节数
    //是一个系统调用, 即调用是在内核级别执行的, 因此可以安全地检查它并返回错误.
    return vm_read_overwrite(mach_task_self(), (vm_address_t)src, (vm_size_t)numBytes, (vm_address_t)dst, &bytesCopied);
}

#pragma -mark Symbolicate
void bs_symbolicate(const uintptr_t* const backtraceBuffer,
                    Dl_info* const symbolsBuffer,
                    const int numEntries,
                    const int skippedEntries){
    int i = 0;
    
    if(!skippedEntries && i < numEntries) {
        bs_dladdr(backtraceBuffer[i], &symbolsBuffer[i]);
        i++;
    }
    
    for(; i < numEntries; i++) {
        bs_dladdr(CALL_INSTRUCTION_FROM_RETURN_ADDRESS(backtraceBuffer[i]), &symbolsBuffer[i]);
    }
}

bool bs_dladdr(const uintptr_t address, Dl_info* const info) {
    info->dli_fname = NULL;
    info->dli_fbase = NULL;
    info->dli_sname = NULL;
    info->dli_saddr = NULL;
    
    const uint32_t idx = bs_imageIndexContainingAddress(address);
    if(idx == UINT_MAX) {
        return false;
    }
    const struct mach_header* header = _dyld_get_image_header(idx);
    //_dyld_get_image_vmaddr_slide来获取image虚拟地址的偏移量
    const uintptr_t imageVMAddrSlide = (uintptr_t)_dyld_get_image_vmaddr_slide(idx);
    const uintptr_t addressWithSlide = address - imageVMAddrSlide;
    const uintptr_t segmentBase = bs_segmentBaseOfImageIndex(idx) + imageVMAddrSlide;
    if(segmentBase == 0) {
        return false;
    }
    
    info->dli_fname = _dyld_get_image_name(idx);
    info->dli_fbase = (void*)header;
    
    // Find symbol tables and get whichever symbol is closest to the address.
    /*
     * This is the symbol table entry structure for 64-bit architectures.
     */
//    struct nlist_64 {
//        union {
//            uint32_t  n_strx; /* index into the string table */
//        } n_un;
//        uint8_t n_type;        /* type flag, see below */
//        uint8_t n_sect;        /* section number or NO_SECT */
//        uint16_t n_desc;       /* see <mach-o/stab.h> */
//        uint64_t n_value;      /* value of this symbol (or stab offset) */
//    };
    const BS_NLIST* bestMatch = NULL;
    uintptr_t bestDistance = ULONG_MAX;
    uintptr_t cmdPtr = bs_firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return false;
    }
    for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SYMTAB) {
            /*
            * The symtab_command contains the offsets and sizes of the link-edit 4.3BSD
            * "stab" style symbol table information as described in the header files
            * <nlist.h> and <stab.h>.
            */
//            struct symtab_command {
//                uint32_t    cmd;        /* LC_SYMTAB */
//                uint32_t    cmdsize;    /* sizeof(struct symtab_command) */
//                uint32_t    symoff;        /* symbol table offset */
//                uint32_t    nsyms;        /* number of symbol table entries */
//                uint32_t    stroff;        /* string table offset */
//                uint32_t    strsize;    /* string table size in bytes */
//            };
            const struct symtab_command* symtabCmd = (struct symtab_command*)cmdPtr;
            const BS_NLIST* symbolTable = (BS_NLIST*)(segmentBase + symtabCmd->symoff);
            const uintptr_t stringTable = segmentBase + symtabCmd->stroff;
            
            for(uint32_t iSym = 0; iSym < symtabCmd->nsyms; iSym++) {
                // If n_value is 0, the symbol refers to an external object.
                if(symbolTable[iSym].n_value != 0) {
                    uintptr_t symbolBase = symbolTable[iSym].n_value;
                    uintptr_t currentDistance = addressWithSlide - symbolBase;
                    if((addressWithSlide >= symbolBase) &&
                       (currentDistance <= bestDistance)) {
                        bestMatch = symbolTable + iSym;
                        bestDistance = currentDistance;
                    }
                }
            }
            if(bestMatch != NULL) {
                info->dli_saddr = (void*)(bestMatch->n_value + imageVMAddrSlide);
                info->dli_sname = (char*)((intptr_t)stringTable + (intptr_t)bestMatch->n_un.n_strx);
                if(*info->dli_sname == '_') {
                    info->dli_sname++;
                }
                // This happens if all symbols have been stripped.
                if(info->dli_saddr == info->dli_fbase && bestMatch->n_type == 3) {
                    info->dli_sname = NULL;
                }
                break;
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return true;
}

// struct mach_header {
//     uint32_t    magic;        /* mach magic number identifier */
//     cpu_type_t    cputype;    /* cpu specifier */
//     cpu_subtype_t    cpusubtype;    /* machine specifier */
//     uint32_t    filetype;    /* type of file */
//     uint32_t    ncmds;        /* number of load commands */
//     uint32_t    sizeofcmds;    /* the size of all the load commands */
//     uint32_t    flags;        /* flags */
// };
//
uintptr_t bs_firstCmdAfterHeader(const struct mach_header* const header) {
    switch(header->magic) {
        case MH_MAGIC:
        case MH_CIGAM:
            return (uintptr_t)(header + 1);
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((struct mach_header_64*)header) + 1);
        default:
            return 0;  // Header is corrupt
    }
}
//struct segment_command { /* for 32-bit architectures */
//    uint32_t    cmd;        /* LC_SEGMENT */
//    uint32_t    cmdsize;    /* includes sizeof section structs */
//    char        segname[16];    /* segment name */
//    uint32_t    vmaddr;        /* memory address of this segment */
//    uint32_t    vmsize;        /* memory size of this segment */
//    uint32_t    fileoff;    /* file offset of this segment */
//    uint32_t    filesize;    /* amount to map from the file */
//    vm_prot_t    maxprot;    /* maximum VM protection */
//    vm_prot_t    initprot;    /* initial VM protection */
//    uint32_t    nsects;        /* number of sections in segment */
//    uint32_t    flags;        /* flags */
//};
uint32_t bs_imageIndexContainingAddress(const uintptr_t address) {
    const uint32_t imageCount = _dyld_image_count();
    const struct mach_header* header = 0;
    
    for(uint32_t iImg = 0; iImg < imageCount; iImg++) {
        header = _dyld_get_image_header(iImg);
        if(header != NULL) {
            // Look for a segment command with this address within its range.
            uintptr_t addressWSlide = address - (uintptr_t)_dyld_get_image_vmaddr_slide(iImg);
            uintptr_t cmdPtr = bs_firstCmdAfterHeader(header);
            if(cmdPtr == 0) {
                continue;
            }
            // 遍历所有segment， 查找目标地址在那个 segment里
            for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
                const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                if(loadCmd->cmd == LC_SEGMENT) {
                    const struct segment_command* segCmd = (struct segment_command*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                else if(loadCmd->cmd == LC_SEGMENT_64) {
                    const struct segment_command_64* segCmd = (struct segment_command_64*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                cmdPtr += loadCmd->cmdsize;
            }
        }
    }
    return UINT_MAX;
}

uintptr_t bs_segmentBaseOfImageIndex(const uint32_t idx) {
    const struct mach_header* header = _dyld_get_image_header(idx);
    
    // Look for a segment command and return the file image address.
    uintptr_t cmdPtr = bs_firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return 0;
    }
    for(uint32_t i = 0;i < header->ncmds; i++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SEGMENT) {
            const struct segment_command* segmentCmd = (struct segment_command*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return segmentCmd->vmaddr - segmentCmd->fileoff;
            }
        }
        else if(loadCmd->cmd == LC_SEGMENT_64) {
            const struct segment_command_64* segmentCmd = (struct segment_command_64*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                // vmaddr - fileoff
                return (uintptr_t)(segmentCmd->vmaddr - segmentCmd->fileoff);
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return 0;
}

@end
