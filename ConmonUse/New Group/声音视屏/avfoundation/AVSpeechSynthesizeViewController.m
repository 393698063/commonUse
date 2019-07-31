//
//  AVSpeechSynthesizeViewController.m
//  ConmonUse
//
//  Created by jorgon on 2019/5/21.
//  Copyright © 2019年 jorgon. All rights reserved.
//

#import "AVSpeechSynthesizeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVSpeechSynthesizeViewController ()<AVSpeechSynthesizerDelegate>

@end

@implementation AVSpeechSynthesizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self speakHintMessage];
}

// 简单的语音测试
-(void)speakHintMessage{
    AVSpeechSynthesizer * speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    speechSynthesizer.delegate = self;
    // Utterance 表达方式
    AVSpeechSynthesisVoice * voice  = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    AVSpeechUtterance  * utterance = [[AVSpeechUtterance alloc]initWithString:@"准备了猪，开始录制视频了"];
    utterance.rate  = 0.5; // 这个是播放速率 默认1.0
    utterance.voice = voice;
    utterance.pitchMultiplier = 0.8;        // 可在播放待定语句时候改变声调
    utterance.postUtteranceDelay = 0.1; // 语音合成器在播放下一条语句的时候有短暂的停顿  这个属性指定停顿的时间
    [speechSynthesizer speakUtterance:utterance];
    
    /*
     "[AVSpeechSynthesisVoice 0x978a0b0] Language: th-TH",
     "[AVSpeechSynthesisVoice 0x977a450] Language: pt-BR",
     "[AVSpeechSynthesisVoice 0x977a480] Language: sk-SK",
     "[AVSpeechSynthesisVoice 0x978ad50] Language: fr-CA",
     "[AVSpeechSynthesisVoice 0x978ada0] Language: ro-RO",
     "[AVSpeechSynthesisVoice 0x97823f0] Language: no-NO",
     "[AVSpeechSynthesisVoice 0x978e7b0] Language: fi-FI",
     "[AVSpeechSynthesisVoice 0x978af50] Language: pl-PL",
     "[AVSpeechSynthesisVoice 0x978afa0] Language: de-DE",
     "[AVSpeechSynthesisVoice 0x978e390] Language: nl-NL",
     "[AVSpeechSynthesisVoice 0x978b030] Language: id-ID",
     "[AVSpeechSynthesisVoice 0x978b080] Language: tr-TR",
     "[AVSpeechSynthesisVoice 0x978b0d0] Language: it-IT",
     "[AVSpeechSynthesisVoice 0x978b120] Language: pt-PT",
     "[AVSpeechSynthesisVoice 0x978b170] Language: fr-FR",
     "[AVSpeechSynthesisVoice 0x978b1c0] Language: ru-RU",
     "[AVSpeechSynthesisVoice 0x978b210] Language: es-MX",
     "[AVSpeechSynthesisVoice 0x978b2d0] Language: zh-HK",
     "[AVSpeechSynthesisVoice 0x978b320] Language: sv-SE",
     "[AVSpeechSynthesisVoice 0x978b010] Language: hu-HU",
     "[AVSpeechSynthesisVoice 0x978b440] Language: zh-TW",
     "[AVSpeechSynthesisVoice 0x978b490] Language: es-ES",
     "[AVSpeechSynthesisVoice 0x978b4e0] Language: zh-CN",
     "[AVSpeechSynthesisVoice 0x978b530] Language: nl-BE",
     "[AVSpeechSynthesisVoice 0x978b580] Language: en-GB",
     "[AVSpeechSynthesisVoice 0x978b5d0] Language: ar-SA",
     "[AVSpeechSynthesisVoice 0x978b620] Language: ko-KR",
     "[AVSpeechSynthesisVoice 0x978b670] Language: cs-CZ",
     "[AVSpeechSynthesisVoice 0x978b6c0] Language: en-ZA",
     "[AVSpeechSynthesisVoice 0x978aed0] Language: en-AU",
     "[AVSpeechSynthesisVoice 0x978af20] Language: da-DK",
     "[AVSpeechSynthesisVoice 0x978b810] Language: en-US",
     "[AVSpeechSynthesisVoice 0x978b860] Language: en-IE",
     "[AVSpeechSynthesisVoice 0x978b8b0] Language: hi-IN",
     "[AVSpeechSynthesisVoice 0x978b900] Language: el-GR",
     "[AVSpeechSynthesisVoice 0x978b950] Language: ja-JP" )
     */
    // 通过这个方法可以看到整个支持的会话的列表,信息如上输出
    NSLog(@"目前支持的语音列表:%@",[AVSpeechSynthesisVoice speechVoices]);
}

#pragma mark -

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
//    [synthesizer stopSpeakingAtBoundary:utterance];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    NSLog(@"%s",__func__);
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
