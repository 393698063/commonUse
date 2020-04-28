//
//  QGCustomSection.m
//  ConmonUse
//
//  Created by qiaogang02 on 2019/11/26.
//  Copyright © 2019 jorgon. All rights reserved.
//

#import "QGCustomSection.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>

#ifndef __LP64__   //是否64位
#define mach_header mach_header
#else
#define mach_header mach_header_64
#endif

// 宏定义中把 # 把参数变为一个字符串， ## 把两个宏参数贴合在一起
//char * str __attribute((used,section("__DATA,Test"))) = "Hello world";
//使用 used字段，即使没有任何引用，在Release下也不会被优化
//#define WriteSection(sectName) __attribute__((used, section("__DATA,"#sectName" ")))
#define WriteSection(sectName) __attribute__((used, section("__DATA"","#sectName)))
#define SectionDataWithKeyValue(key,value) char * k##key WriteSection(CustomSection) = "{ \""#key"\" : \""#value"\"}";
// 这个宏定义 定义了一个静态常量 k##key
/**
 SectionDataWithKeyValue(key,value) char * k##key = "{ \""#key"\" : \""#value"\"}" __attribute__((used, section("__DATA,"#sectName" ")))
 */

// 注入 ：
SectionDataWithKeyValue(url, www.baidu.com)

SectionDataWithKeyValue(dd, ddddddddd)


static NSString *configuration = @"";
const struct mach_header *machHeader = NULL;
@implementation QGCustomSection

+ (void)readSection {
    NSLog(@"section:%@", [self readConfigFromSectionName:@"CustomSection"]);
}

+ (NSArray <NSDictionary *> *)readConfigFromSectionName:(NSString *)sectionName
{
    NSMutableArray *configs = [NSMutableArray array];
    if (sectionName.length)
    {
//        struct mach_header_64 {
//            uint32_t    magic;        /* mach magic number identifier */
//            cpu_type_t    cputype;    /* cpu specifier */
//            cpu_subtype_t    cpusubtype;    /* machine specifier */
//            uint32_t    filetype;    /* type of file */
//            uint32_t    ncmds;        /* number of load commands */
//            uint32_t    sizeofcmds;    /* the size of all the load commands */
//            uint32_t    flags;        /* flags */
//            uint32_t    reserved;    /* reserved */
//        };
        if (machHeader == NULL)
        {
            
//             typedef struct dl_info {
//                     const char      *dli_fname;     /* Pathname of shared object */
//                     void            *dli_fbase;     /* Base address of shared object */
//                     const char      *dli_sname;     /* Name of nearest symbol */
//                     void            *dli_saddr;     /* Address of nearest symbol */
//             } Dl_info;
            Dl_info info; //Structure filled in by dladdr().
            dladdr((__bridge const void *)(configuration), &info);
            machHeader = (struct mach_header*)info.dli_fbase;
        }
        unsigned long size = 0;
//        extern uint8_t *getsectiondata(
//        const struct mach_header_64 *mhp,
//        const char *segname,
//        const char *sectname,
//        unsigned long *size);
        uintptr_t *memory = (uintptr_t*)getsectiondata(machHeader, "__DATA", [sectionName UTF8String], & size);
        
        NSUInteger counter = size/sizeof(void*);
        NSError *converError = nil;
        for(int idx = 0; idx < counter; ++idx){
            char *string = (char*)memory[idx];
            
            NSString *str = [NSString stringWithUTF8String:string];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&converError];
            if (json && [json isKindOfClass:[NSDictionary class]])
            {
                [configs addObject:json];
            }
        }
    }
    return configs;
}

@end
