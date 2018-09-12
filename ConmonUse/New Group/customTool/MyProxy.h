//
//  MyProxy.h
//  消息代理NSProxy
//
//  Created by jorgon on 03/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyProxy : NSProxy
+ (id)proxyWithTarget:(id)target;
@end
