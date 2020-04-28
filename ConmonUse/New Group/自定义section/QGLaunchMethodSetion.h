//
//  QGLaunchMethodSetion.h
//  ConmonUse
//
//  Created by qiaogang02 on 2019/12/2.
//  Copyright © 2019 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>

static char * LEVEL_A = "LEVEL_A";
static char * LEVEL_B = "LEVEL_B";
static char * LEVEL_C = "LEVEL_C";

typedef void (*VoidFuntion)(void);

/**
 typedef void (*bdhk_section_func)(void);
 #define func_init(key) \
 static void func(void); \
 static bdhk_section_func _fn_##key __attribute__((used, section("__DATA, "#key""))) = func; \
 static void func(void)

 func_init(bdhk_section) {
     NSLog(@"000");
 }
 */
// 宏定义中把 # 把参数变为一个字符串， ## 把两个宏参数贴合在一起
//char * str __attribute((used,section("__DATA,Test"))) = "Hello world";
//使用 used字段，即使没有任何引用，在Release下也不会被优化
#define WriteSection(sectName) __attribute__((used, section("__DATA,"#sectName" ")))
#define QG_SECTIONNAME "__DATA"
#define QGMETHOD_ATTRIBUTE(sectionName) __attribute((used, section(QG_SECTIONNAME "," #sectionName)))

#define QG_FUNCTIONS_EXPORT_BEGIN(KEY) \
static void QG_INJECT_##KEY##_FUNCTION(void){

#define QG_FUNCTIONS_EXPORT_END(KEY) \
} \
static VoidFuntion dymlLoader##KEY##function  QGMETHOD_ATTRIBUTE(KEY) = QG_INJECT_##KEY##_FUNCTION;

//static char * LEVEL_A = "LEVEL_A";
//static char * LEVEL_B = "LEVEL_B";
//static char * LEVEL_C = "LEVEL_C";
//
//typedef void (*ONLDynamicLoaderInjectFunction)(void);
//
//#define CRDYML_SEGMENTNAME "__DATA"
//#define CRDYML_ATTRIBUTE(sectionName) __attribute((used, section(CRDYML_SEGMENTNAME "," #sectionName )))
//
//#define CRDYML_FUNCTIONS_EXPORT_BEGIN(KEY) \
//static void CRDYML_INJECT_##KEY##_FUNCTION(void){
//
//#define CRDYML_FUNCTIONS_EXPORT_END(KEY) \
//} \
//static ONLDynamicLoaderInjectFunction dymlLoader##KEY##function CRDYML_ATTRIBUTE(KEY) = CRDYML_INJECT_##KEY##_FUNCTION;



NS_ASSUME_NONNULL_BEGIN

@interface QGLaunchMethodSetion : NSObject

+ (void)executeFunctionsForKey:(char *)key;

@end

NS_ASSUME_NONNULL_END
