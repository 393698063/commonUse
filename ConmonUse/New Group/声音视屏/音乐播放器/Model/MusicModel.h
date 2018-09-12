//
//  MusicModel.h
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Resources(file) [@"Resources.bundle/" stringByAppendingString:file]
@interface MusicModel : NSObject
#pragma mark --------------------------
#pragma mark 属性

/** 歌曲名称*/
@property (nonatomic, copy) NSString *name;

/** 演唱者*/
@property (nonatomic, strong) NSString *singer;

/** 歌手头像*/
@property (nonatomic, strong) NSString *singerIcon;

/** 歌词文件名称*/
@property (nonatomic, strong) NSString *lrcname;

/** 歌曲文件名称*/
@property (nonatomic, strong) NSString *filename;

/** 专辑图片*/
@property (nonatomic, strong) NSString *icon;
@end
