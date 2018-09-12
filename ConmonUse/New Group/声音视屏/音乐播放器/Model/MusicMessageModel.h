//
//  MusicMessageModel.h
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicModel.h"

@interface MusicMessageModel : NSObject
/** 音乐数据*/
@property (nonatomic, strong) MusicModel *musicM;

/** 当前播放时长*/
@property (nonatomic, assign) NSTimeInterval costTime;

/** 歌曲总时长*/
@property (nonatomic, assign) NSTimeInterval totalTime;

/** 当前播放状态*/
@property (nonatomic, assign, getter=isPlaying) BOOL playing;

#pragma mark --------------------------
#pragma mark 时间格式
/** 当前播放时长 字符串格式*/
@property (nonatomic, strong, readonly) NSString *costTimeFormat;

/** 歌曲总时长 字符串格式*/
@property (nonatomic, strong, readonly) NSString *totalTimeFormat;
@end
