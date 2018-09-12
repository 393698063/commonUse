//
//  LrcModel.h
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LrcModel : NSObject
/** 开始时间*/
@property (nonatomic, assign) NSTimeInterval beginTime;

/** 结束时间*/
@property (nonatomic, assign) NSTimeInterval endTime;

/** 歌词*/
@property (nonatomic, copy) NSString *lrcStr;
@end
