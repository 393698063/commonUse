//
//  NSObject+Test.m
//  ConmonUse
//
//  Created by jorgon on 31/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "NSObject+Test.h"
#import <objc/runtime.h>
//Creating String Representations for Enumerated Type
NSString * const TestStyleTypeDescription[] = {
    [TestStyleDefault] = @"Default1",
    [TestStyleValue1] = @"Subtitle1",
    [TestStyleValue2] = @"Value 11",
    [TestStyleSubtitle] = @"Value 21"
};
@implementation NSObject (Test)
- (void)method:(id)object, ... {
    
    va_list args;
    va_start(args, object);
    while (object) {
        // ...
        object = va_arg(args, id);
        NSLog(@"%@",object);
    }
    va_end(args);
}

+ (NSSet *)subclasses {
    NSMutableSet *mutableSubclasses = [NSMutableSet set];
    unsigned int count;
    Class *classes = objc_copyClassList(&count); for (int i = 0; i < count; i++) {
        Class class = classes[i];
        for (Class superclass = class_getSuperclass(class);
             superclass != Nil;
             superclass = class_getSuperclass(superclass))
        {
            if (superclass == self) {
                [mutableSubclasses addObject:class]; }
        } }
    free(classes);
    return [NSSet setWithSet:mutableSubclasses];
}

+ (NSArray *)superclasses {
    NSMutableArray *mutableSuperclasses = [NSMutableArray array];
    for (Class superclass = class_getSuperclass(self); superclass != Nil;
         superclass = class_getSuperclass(superclass))
    {
        [mutableSuperclasses addObject:superclass];
    }
    return [NSArray arrayWithArray:mutableSuperclasses]; }

@end
