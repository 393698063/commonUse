//
//  NSObject+Test.h
//  ConmonUse
//
//  Created by jorgon on 31/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>

//Declaring an NS_ENUM Type
typedef NS_ENUM(NSInteger, TestStyleType){
    TestStyleDefault,
    TestStyleValue1,
    TestStyleValue2,
    TestStyleSubtitle
};

//Declaring an NS_OPTIONS Type
typedef NS_OPTIONS(NSUInteger, TestResizing){
    TestResizingNone                  = 0,
    TestResizingftMargin    =1<<0,
    TestResizingWidth         =1<<1,
    TestResizingRightMargin   = 1 << 2,
    TestResizingTopMargin     =1<<3,
    TestResizingHeight        =1<<4,
    TestResizingBottomMargin  = 1 << 5
};

@interface NSObject (Test)

- (void)method:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
+ (NSSet *)subclasses;
+ (NSArray *)superclasses;
@end
