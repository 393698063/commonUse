//
//  SoundEffectViewController.m
//  ConmonUse
//
//  Created by jorgon on 22/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//
/*
 AudioToolbox.framework是一套基于C语言的框架，使用它来播放音效其本质是将短音频注册到系统声音服务（System Sound Service）。System Sound Service是一种简单、底层的声音播放服务，但是它本身也存在着一些限制：
 
 音频播放时间不能超过30s
 数据必须是PCM或者IMA4格式
 音频文件必须打包成.caf、.aif、.wav中的一种（注意这是官方文档的说法，实际测试发现一些.mp3也可以播放）
 */
#import "SoundEffectViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SoundEffectViewController ()

@end

@implementation SoundEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self playAudio];
}

void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}

- (void)playAudio{
    NSString * audioPath = [[NSBundle mainBundle] pathForResource:@"test.mp3" ofType:nil];
    NSURL * audioUrl = [NSURL fileURLWithPath:audioPath];
    
    //1.获得系统声音ID
    SystemSoundID soundID = 0;
    /*
     inFileUrl:音频文件url
     outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    //AudioServicesCreateSystemSoundID(   CFURLRef                    inFileURL,
    //    SystemSoundID*              outSystemSoundID)
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioUrl), &soundID);
    
    
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    /*
     AudioServicesAddSystemSoundCompletion(  SystemSoundID                                       inSystemSoundID,
     CFRunLoopRef __nullable                             inRunLoop,
     CFStringRef __nullable                              inRunLoopMode,
     AudioServicesSystemSoundCompletionProc              inCompletionRoutine,
     void * __nullable                                   inClientData)
     __OSX_AVAILABLE_STARTING(__MAC_10_5,__IPHONE_2_0);
     */
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
//    AudioServicesPlaySystemSound(soundID);//播放音效
     AudioServicesPlayAlertSound(soundID);//播放音效并震动
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
