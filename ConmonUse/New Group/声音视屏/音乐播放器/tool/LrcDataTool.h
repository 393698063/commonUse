//
//  LrcDataTool.h
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LrcModel;
@interface LrcDataTool : NSObject
/**
 *  根据歌词文件名获取歌词数据
 *
 *  @param filename 歌词文件名
 *
 *  @return 歌词对象数组 NSArray<QQLrcModel *>
 */
+ (NSArray<LrcModel *> *)getLrcData:(NSString *)filename;


/**
 *  获取当前播放的歌词所在的行
 *
 *  @param currentTime 已经播放的时间 NSTimeInterval
 *  @param lrcMs       歌词信息 NSArray<QQLrcModel *>
 *  @param completion  获取信息后要执行的操作
 */
+ (void)getRow:(NSTimeInterval)currentTime
       andLrcs:(NSArray<LrcModel *> *)lrcMs
    completion:(void (^)(NSInteger row, LrcModel *lrcModel))completion;

@end
