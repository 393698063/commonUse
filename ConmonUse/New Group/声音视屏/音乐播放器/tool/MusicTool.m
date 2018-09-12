//
//  MusicTool.m
//  ConmonUse
//
//  Created by jorgon on 24/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "MusicTool.h"

@interface MusicTool()<AVAudioPlayerDelegate>

@end

@implementation MusicTool

#pragma mark- -------初始化
- (instancetype)init{
    if (self = [super init]) {
        //在iOS中每个应用都有一个音频会话，这个会话就通过AVAudioSession来表示
        // 1.获取音频会话
        AVAudioSession * session = [AVAudioSession sharedInstance];
        
        /*
         会话类型 说明 是否要求输入 是否要求输出 是否遵从静音键
         AVAudioSessionCategoryAmbient 混音播放，可以与其他音频应用同时播放 否 是 是
         AVAudioSessionCategorySoloAmbient 独占播放 否 是 是
         AVAudioSessionCategoryPlayback 后台播放，也是独占的 否 是 否
         AVAudioSessionCategoryRecord 录音模式，用于录音时使用 是 否 否
         AVAudioSessionCategoryPlayAndRecord 播放和录音，此时可以录音也可以播放 是 是 否
         AVAudioSessionCategoryAudioProcessing 硬件解码音频，此时不能播放和录制 否 否 否
         AVAudioSessionCategoryMultiRoute 多种输入输出，例如可以耳机、USB设备同时播放 是 是 否
         */
        // 2.设置音频会话类别
        NSError *error = nil;
        // 3.激活会话
        [session setActive:YES error:&error];
        if (error) {
            NSLog(@"%@", error);
            return nil;
        }
        
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error) {
            NSLog(@"%@", error);
            return nil;
        }
    }
    return self;
}
#pragma mark- ----- 单首音乐操作
- (BOOL)playMusic:(NSString *)musicName{
    NSURL * url = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
    if (!url) {
        return false;
    }
    
    if (self.player.url && [self.player.url isEqual:url]) {
        if (self.player.isPlaying) {
            [self.player play];
        }
        return false;
    }
    [self stopCurrentMusic];
    // 创建 AVAudioPlayer
    NSError * error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.player.delegate = self;
    if (error) {
        NSLog(@"%@",error);
        return false;
    }
    
    @try{
        //2. 准备播放
        [self.player prepareToPlay];
        // 3.开始播放
        [self.player play];
    }
    @catch(NSException * exception){
        NSLog(@"%@",exception.userInfo);
    }
    @finally {
        
    }
    return true;
}

- (void)pauseCurrentMusic{
    [self.player pause];
}

- (void)resumeCurrentMusic{
    
    [self.player play];
}

/**
 停止当前音乐
 */
- (void)stopCurrentMusic{
    if (self.player) {
        [self.player stop];
        self.player.delegate = self;
        self.player = nil;
    }
}
/*
 * 到某一时间播放
 */
- (void)seekTo:(NSTimeInterval)timeInteval{
    self.player.currentTime = timeInteval;
}

#pragma mark- --- AVAudioPlayerDelegate

/** 监听播放完成*/
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    //NSLog(@"歌曲播放完毕");
    
    // 发布通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayFinishNotificationName object:nil];
    
}





@end
