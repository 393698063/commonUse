//
//  AVAudioViewController.m
//  ConmonUse
//
//  Created by jorgon on 2019/5/21.
//  Copyright © 2019年 jorgon. All rights reserved.
//

#import "AVAudioViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>

@interface AVAudioViewController ()<AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;
@property (nonatomic, strong) UIButton * playButton;
@property (nonatomic, strong) UIButton * funtionButton;
@property (nonatomic, strong) UILabel * progressLabel;
@property (nonatomic, strong) UISlider * progressSlider;
@property (nonatomic, strong) UILabel * specialLabel;
@property (nonatomic, strong) UILabel * specialNumLabel;
@property (nonatomic, strong) UILabel * averageLabel;
@property (nonatomic, strong) UILabel * averageNumLabel;
@end

@implementation AVAudioViewController

- (void)dealloc {
    [_audioPlayer removeObserver:self forKeyPath:@"currentTime"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
     NSURL * url = [[NSBundle mainBundle] URLForResource:@"Resources.bundle/MP3s/235319.mp3" withExtension:nil];
    NSError * error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.delegate = self;
    [self.audioPlayer addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionNew context:nil];
    self.progressSlider.maximumValue = self.audioPlayer.duration;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTime"]) {
//        NSNumber * new = [change objectForKey:NSKeyValueObservingOptionNew];
//        self.progressSlider.value = new.floatValue;
    }
}

- (void)initUI{
    [self.view addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.top.mas_equalTo(100);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
    [self.view addSubview:self.funtionButton];
    [self.funtionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.playButton.mas_bottom).mas_offset(100);
        make.width.mas_equalTo(100);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.view addSubview:self.progressLabel];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.funtionButton.mas_bottom).mas_offset(100);
        make.left.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    [self.view addSubview:self.progressSlider];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressLabel.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.progressLabel.mas_left);
        make.width.mas_equalTo(250);
    }];

    [self.view addSubview:self.specialLabel];
    [self.specialLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressSlider.mas_bottom).mas_offset(50);
        make.left.mas_equalTo(50);
        make.height.mas_equalTo(50);
        //        make.width.mas_equalTo(250);
    }];
    
    [self.view addSubview:self.specialNumLabel];
    [self.specialNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.specialLabel.mas_right).mas_offset(5);
        make.top.mas_equalTo(self.specialLabel.mas_top);
        make.height.mas_equalTo(50);
        make.width.mas_greaterThanOrEqualTo(20);
    }];
    
    [self.view addSubview:self.averageLabel];
    [self.averageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.specialLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(50);
        make.height.mas_equalTo(50);
        make.width.mas_greaterThanOrEqualTo(10);
    }];
    [self.view addSubview:self.averageNumLabel];
    [self.averageNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.averageLabel.mas_top);
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(self.averageLabel.mas_right).mas_offset(5);
        make.width.mas_greaterThanOrEqualTo(10);
    }];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    
}

/* AVAudioPlayer INTERRUPTION NOTIFICATIONS ARE DEPRECATED - Use AVAudioSession instead. */

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    
}

/* audioPlayerEndInterruption:withOptions: is called when the audio session interruption has ended and this player had been interrupted while playing. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags{
    
}

/* audioPlayerEndInterruption: is called when the preferred method, audioPlayerEndInterruption:withFlags:, is not implemented. */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    
}



- (void)playAction:(UIButton *)btn {
    if (!btn.selected) {
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        [self.audioPlayer updateMeters];
        self.specialNumLabel.text = [NSString stringWithFormat:@"%f",[self.audioPlayer peakPowerForChannel:0]];
        self.averageNumLabel.text = [NSString stringWithFormat:@"%f",[self.audioPlayer averagePowerForChannel:0]];
    } else {
        [self.audioPlayer pause];
    }
    btn.selected = !btn.selected;
}


- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_playButton setTitle:@"开始播放" forState:UIControlStateNormal];
        [_playButton setTitle:@"暂停播放" forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)funtionButton {
    if (!_funtionButton) {
        _funtionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_funtionButton setTitle:@"获取分贝值" forState:UIControlStateNormal];
        [_funtionButton setTitle:@"暂停播放" forState:UIControlStateSelected];
    }
    return _funtionButton;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.text = @"播放进度";
        _progressLabel.font = [UIFont systemFontOfSize:18];
        _progressLabel.textColor = [UIColor blackColor];
    }
    return _progressLabel;
}

- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.minimumValue = 0.0;
        _progressSlider.maximumValue = 1.0;
    }
    return _progressSlider;
}

- (UILabel *)specialLabel {
    if (!_specialLabel) {
        _specialLabel = [[UILabel alloc] init];
        _specialLabel.text = @"指定频道分贝值";
        _specialLabel.font = [UIFont systemFontOfSize:18];
        _specialLabel.textColor = [UIColor blackColor];
    }
    return _specialLabel;
}

- (UILabel *)specialNumLabel {
    if (!_specialNumLabel) {
        _specialNumLabel = [[UILabel alloc] init];
        _specialNumLabel.font = [UIFont systemFontOfSize:18];
        _specialNumLabel.textColor = [UIColor blackColor];
    }
    return _specialNumLabel;
}

- (UILabel *)averageLabel {
    if (!_averageLabel) {
        _averageLabel = [[UILabel alloc] init];
        _averageLabel.text = @"平均分贝值";
        _averageLabel.font = [UIFont systemFontOfSize:18];
        _averageLabel.textColor = [UIColor blackColor];
    }
    return _averageLabel;
}

- (UILabel *)averageNumLabel {
    if (!_averageNumLabel) {
        _averageNumLabel = [[UILabel alloc] init];
        _averageNumLabel.font = [UIFont systemFontOfSize:18];
        _averageNumLabel.textColor = [UIColor blackColor];
    }
    return _averageNumLabel;
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
