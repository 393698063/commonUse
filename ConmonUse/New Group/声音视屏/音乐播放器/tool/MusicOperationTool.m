//
//  MusicOperationTool.m
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//
//  负责的音乐播放的业务逻辑, 比如, 顺序播放, 随机播放等等
#import "MusicOperationTool.h"
#import "LrcDataTool.h"
#import "MusicImageTool.h"
#import "MusicTool.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MusicMessageModel.h"
#import "MusicModel.h"
#import "LrcModel.h"
#import <MJExtension/MJExtension.h>

@interface MusicOperationTool()
/** 音乐播放工具*/
@property (nonatomic, strong) MusicTool *tool;

/** 锁屏 所需的图片参数设置*/
@property (nonatomic, strong) MPMediaItemArtwork *artwork;

/** 当前播放音乐的信息*/
@property (nonatomic, strong) MusicMessageModel *musicMessageModel;

/** 当前播放音乐的索引*/
@property (nonatomic, assign) NSInteger index;

/** 记录当前歌曲的歌词 播放到哪一行*/
@property (nonatomic, assign) NSInteger lrcRow;
@end

@implementation MusicOperationTool

+ (instancetype)shareInstance{
    static MusicOperationTool * _operationTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _operationTool = [[MusicOperationTool alloc] init];
    });
    return _operationTool;
}
- (instancetype)init{
    if (self = [super init]) {
        _tool = [[MusicTool alloc] init];
        _musicMessageModel = [[MusicMessageModel alloc] init];
        _lrcRow = -1;
    }
    return self;
}

#pragma mark- set 方法
- (void)setIndex:(NSInteger)index{
    _index = index;
    if (index < 0) {
        _index = self.musicMList.count -1;
    } else if (index > self.musicMList.count -1) {
        _index = 0;
    }
}

- (MusicMessageModel *)getNewMusicMessageModel{
    // 跟新数据
    self.musicMessageModel.musicM = self.musicMList[self.index];
    
    // 已经播放的时长
    self.musicMessageModel.costTime = self.tool.player.currentTime;
    
    // 总时长
    self.musicMessageModel.totalTime = self.tool.player.duration;
    
    // 播放状态
    self.musicMessageModel.playing = self.tool.player.playing;
    
    return self.musicMessageModel;
}

#pragma mark 单首音乐的操作

- (BOOL)playMusic:(MusicModel *)music {
    NSString * fileName = music.filename;
    BOOL isPlayMusicSucceed = [self.tool playMusic:fileName];
    
    if (self.musicMList == nil || self.musicMList.count <= 1) {
        NSLog(@"没有播放列表, 只能播放一首歌");
        //        isPlayMusicSucceed = NO;
        return NO;
    }
    
    // 记录当前播放歌曲的索引
    self.index = [self.musicMList indexOfObject:music];
    
    return isPlayMusicSucceed;
}

- (void)playCurrentMusic{
    [self.tool resumeCurrentMusic];
}

- (void)pauseCurrentMusic {
    [self.tool pauseCurrentMusic];
}

- (void)stopCurrentMusic {
    [self.tool stopCurrentMusic];
}

- (BOOL)nextMusic{
    self.index += 1;
    if (self.musicMList) {
        MusicModel * music = self.musicMList[self.index];
        return [self playMusic:music];
    }
    return false;
}

- (BOOL)preMusic{
    self.index -= 1;
    if (self.musicMList) {
        MusicModel *music = self.musicMList[self.index];
        return [self playMusic:music];
    }
    return NO;
}

- (void)seekTo:(NSTimeInterval)timeInteval{
    
    [self.tool seekTo:timeInteval];
}

#pragma mark 锁屏信息设置
- (void)setUpLockMessage{
    
    //NSLog(@"设置了锁屏信息");
    
    MusicMessageModel *musicMessageModel = [self getNewMusicMessageModel];
    
    // 展示锁屏信息
    //一个可用于设置并显示APP中当前播放的媒体信息的对象
    /*
     1、在设备锁屏界面和控制中心中(in the multimedia controls in the multitasking UI)
        显示媒体信息
     2、通过AirPlay将媒体资源在AppleTV中播放时，播放信息将会出现在电视屏幕上。
     3、当前设备连接到一个iPod附件上，附件上也会显示当前正在播放的媒体信息
     */
    // 1.获取锁屏播放中心
    MPNowPlayingInfoCenter *playCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 1.0 当前正在播放的歌曲信息
    // 获取当前播放歌曲的所有歌词信息
    NSArray *lrcMs = [LrcDataTool getLrcData:musicMessageModel.musicM.lrcname];
    // 获取当前播放的歌词模型
    __block LrcModel *lrcM = nil;
    __block NSInteger currentLrcRow = 0;
    [LrcDataTool getRow:musicMessageModel.costTime
                andLrcs:lrcMs
             completion:^(NSInteger row, LrcModel *lrcModel) {
        
        currentLrcRow = row;
        lrcM = lrcModel;
    }];
    
    // 1.1 字典信息
    NSString *songName = musicMessageModel.musicM.name;
    NSString *singerName = musicMessageModel.musicM.singer;
    NSTimeInterval costTime = musicMessageModel.costTime;
    NSTimeInterval totalTime = musicMessageModel.totalTime;
    
    NSString *icon = musicMessageModel.musicM.icon;
    if (icon) {
        UIImage *image = [UIImage imageNamed:icon];
        if (image) {
            
            // 如果当前歌词没有播放完毕, 则无需重新绘制新图
            if (self.lrcRow != currentLrcRow) {
                
                //NSLog(@"绘制了新图片");
                // 重新绘制图片
                UIImage *newImage = [MusicImageTool getNewImage:image andLrcStr:lrcM.lrcStr];
                
                //                self.artwork = [[MPMediaItemArtwork alloc] initWithImage:newImage];
                
                if (@available(iOS 10.0, *)) {
                    self.artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:newImage.size
                                                                   requestHandler:^UIImage * _Nonnull(CGSize size) {
                                                                       return newImage;
                                                                   }];
                } else {
                    self.artwork = [[MPMediaItemArtwork alloc] initWithImage:newImage];
                }
                
                self.lrcRow = currentLrcRow;
            }
        }
    }
    
    // 1.2 创建字典
    NSDictionary *dict = @{
                           // 歌曲名称
                           MPMediaItemPropertyAlbumTitle : songName,
                           
                           // 演唱者
                           MPMediaItemPropertyArtist : singerName,
                           
                           // 当前播放的时间
                           MPNowPlayingInfoPropertyElapsedPlaybackTime : @(costTime),
                           
                           // 总时长
                           MPMediaItemPropertyPlaybackDuration : @(totalTime),
                           };
    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    if (self.artwork) {
        
        infoDict[MPMediaItemPropertyArtwork] = self.artwork;
    }
    
    // 2.给锁屏中心赋值
    playCenter.nowPlayingInfo = infoDict;
    
    // 3.接收远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
}

- (void)createRemoteCommandCenter{
    MPRemoteCommandCenter * remoteCenter = [MPRemoteCommandCenter sharedCommandCenter];
}

- (NSArray *)musicMList
{
    if(_musicMList == nil)
    {
        _musicMList = [MusicModel mj_objectArrayWithFilename:Resources(@"Musics.plist")];
    }
    return _musicMList;
}

@end
