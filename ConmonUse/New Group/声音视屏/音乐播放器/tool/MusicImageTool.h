//
//  MusicImageTool.h
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MusicImageTool : NSObject
/**
 *  重新绘制锁屏歌曲图片
 *
 *  @param sourceImage 歌曲图片
 *  @param lrcStr      当前播放的歌词
 *
 *  @return 新的图片
 */
+ (UIImage *)getNewImage:(UIImage *)sourceImage andLrcStr:(NSString *)lrcStr;
@end
