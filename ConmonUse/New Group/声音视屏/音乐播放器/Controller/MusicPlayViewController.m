//
//  MusicPlayViewController.m
//  ConmonUse
//
//  Created by jorgon on 27/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "MusicPlayViewController.h"
#import <Masonry.h>
#import "MusicOperationTool.h"
#import "MusicMessageModel.h"
#import "LrcLabel.h"
#import "CALayer+LayerPause.h"
#import <YYCategories.h>
#import "LrcDataTool.h"
#import "LrcModel.h"
#import "MyProxy.h"
#import "TimeTool.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicTool.h"

@interface MusicPlayViewController ()
@property (nonatomic, strong) UIImageView * backGroundImageView;
@property (nonatomic, strong) UIToolbar * backGroundToolbar;

@property (nonatomic, strong) UIView * contentContainerView;
@property (nonatomic, strong) UIImageView * foreImageView;
@property (nonatomic, strong) LrcLabel * lrcLabel;
@property (nonatomic, strong) UIScrollView * lrcBackView;
@property (nonatomic, strong) UIView * progressContainerView;
@property (nonatomic, strong) UILabel * costTimeLabel;
@property (nonatomic, strong) UILabel * totalTimeLabel;
@property (nonatomic, strong) UISlider * progressSlider;
@property (nonatomic, strong) UIView * playContainView;
@property (nonatomic, strong) UIView * priorView;
@property (nonatomic, strong) UIButton * priorButton;
@property (nonatomic, strong) UIView * playView;
@property (nonatomic, strong) UIButton * playButton;
@property (nonatomic, strong) UIView * nextView;
@property (nonatomic, strong) UIButton * nextButton;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) CADisplayLink * displayLink;
@end

@implementation MusicPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
    
    [self setUpData];
    
    [self addTimer];
    
    [self addDisplaylink];
    if (@available(iOS 11.0, *)){
    } else {
        [self updateViewConstraints];
    }
    
    // 监听播放完毕后的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playNext:)
                                                 name:kPlayFinishNotificationName
                                               object:nil];
    /*
     AVAudioSessionInterruptionNotification来通知。其回调回来的userInfo主要包含两个键：
     
     AVAudioSessionInterruptionTypeKey： 取值为AVAudioSessionInterruptionTypeBegan表示中断开始，我们应该暂停播放和采集，取值为AVAudioSessionInterruptionTypeEnded表示中断结束，我们可以继续播放和采集。
     AVAudioSessionInterruptionOptionKey： 当前只有一种值AVAudioSessionInterruptionOptionShouldResume表示此时也应该恢复继续播放和采集。
     
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioDidInterrup:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    /*
     将其他App占据AudioSession的时候用AVAudioSessionSilenceSecondaryAudioHintNotification来进行通知。其回调回来的userInfo键为：
     
     AVAudioSessionSilenceSecondaryAudioHintTypeKey
     可能包含的值：
     
     AVAudioSessionSilenceSecondaryAudioHintTypeBegin： 表示其他App开始占据Session
     AVAudioSessionSilenceSecondaryAudioHintTypeEnd: 表示其他App开始释放Session
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(otherAudioPlay:)
                                                 name:AVAudioSessionSilenceSecondaryAudioHintNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)audioDidInterrup:(NSNotification *)notification{
    NSDictionary * userInfo = notification.userInfo;
    AVAudioSessionInterruptionType type = ((NSNumber *)userInfo[AVAudioSessionInterruptionTypeKey]).integerValue;
    if (type == AVAudioSessionInterruptionTypeBegan) {
        if (self.playButton.isSelected) {
            [self play:self.playButton];
        }
    } else if(type == AVAudioSessionInterruptionTypeBegan) {
        if (!self.playButton.isSelected) {
            [self play:self.playButton];
        }
    }
}
- (void)otherAudioPlay:(NSNotification *)notification{
    NSDictionary * userInfo = notification.userInfo;
    AVAudioSessionSilenceSecondaryAudioHintType type = ((NSNumber *)userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey]).integerValue;
    if (type == AVAudioSessionSilenceSecondaryAudioHintTypeBegin) {
        if (self.playButton.isSelected) {
            [self play:self.playButton];
        }
    } else if (type == AVAudioSessionSilenceSecondaryAudioHintTypeEnd) {
        if (!self.playButton.isSelected) {
            [self play:self.playButton];
        }
    }
}
- (void)didBecomActive:(NSNotification *)notification{
//    [self getAvaudioSession];
//    if (!self.playButton.isSelected) {
//        [self play:self.playButton];
//    }
}
- (void)getAvaudioSession{
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
    }
    
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}
- (void)setUpUI{


    self.backGroundImageView = [[UIImageView alloc] init];
    self.backGroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backGroundImageView];
    
    self.backGroundToolbar = [[UIToolbar alloc] init];
    self.backGroundToolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.backGroundToolbar];
    
    self.contentContainerView = [[UIView alloc] init];
    self.foreImageView = [[UIImageView alloc] init];
    self.foreImageView.backgroundColor = [UIColor redColor];
    self.lrcLabel = [[LrcLabel alloc] init];
//    self.lrcLabel.backgroundColor = [UIColor redColor];
    [self.contentContainerView addSubview:self.foreImageView];
    [self.contentContainerView addSubview:self.lrcLabel];
    [self.view addSubview:self.contentContainerView];
    
    self.progressContainerView = [[UIView alloc] init];
    self.progressContainerView.backgroundColor = [UIColor greenColor];
    self.costTimeLabel = [[UILabel alloc] init];
    self.costTimeLabel.backgroundColor = [UIColor grayColor];
    self.costTimeLabel.font = [UIFont systemFontOfSize:12];
    self.costTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.totalTimeLabel = [[UILabel alloc] init];
    self.totalTimeLabel.backgroundColor = [UIColor grayColor];
    self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.totalTimeLabel.font = [UIFont systemFontOfSize:12];
    self.progressSlider = [[UISlider alloc] init];
    [self.progressSlider addTarget:self action:@selector(sliderDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(sliderDidTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressSlider addTarget:self action:@selector(sliderDidValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    [self.progressContainerView addSubview:self.progressSlider];
    [self.progressContainerView addSubview:self.costTimeLabel];
    [self.progressContainerView addSubview:self.totalTimeLabel];
    [self.view addSubview:self.progressContainerView];
    
    self.playContainView = [[UIView alloc] init];
    self.playContainView.backgroundColor = [UIColor grayColor];
    self.priorView = [[UIView alloc] init];
    self.priorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.priorButton setImage:[UIImage imageNamed:@"player_btn_pre_normal"] forState:UIControlStateNormal];
    [self.priorButton addTarget:self action:@selector(playPrior:) forControlEvents:UIControlEventTouchUpInside];
    [self.priorView addSubview:self.priorButton];
    self.priorView.backgroundColor = [UIColor cyanColor];
    self.playView = [[UIView alloc] init];
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.playView addSubview:self.playButton];
    self.playView.backgroundColor = [UIColor redColor];
    self.nextView = [[UIView alloc] init];
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton setImage:[UIImage imageNamed:@"player_btn_next_normal"] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(playNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextView addSubview:self.nextButton];
    self.nextView.backgroundColor = [UIColor darkGrayColor];
    [self.playContainView addSubview:self.priorView];
    [self.playContainView addSubview:self.playView];
    [self.playContainView addSubview:self.nextView];
    [self.view addSubview:self.playContainView];
    
    
   
}
/** 当切换歌曲的时候, 更新 一次 界面数据*/
- (void)setUpData{
    // 获取最新数据
    MusicMessageModel * musicMessageModel = [[MusicOperationTool shareInstance] getNewMusicMessageModel];
    self.navigationItem.title = musicMessageModel.musicM.name;
    self.backGroundImageView.image = [UIImage imageNamed:musicMessageModel.musicM.icon];
    self.foreImageView.image = [UIImage imageNamed:musicMessageModel.musicM.icon];
    // 进度恢复成0
    self.progressSlider.value = 0.0;
    // 播放时长是0
    self.costTimeLabel.text = @"00:00";
    // 总时长
    self.totalTimeLabel.text = musicMessageModel.totalTimeFormat;
    
    [self addRotationAnimation];
    
    if (musicMessageModel.isPlaying) {
        [self resumeRotationAnimatioin];
    }else{
        [self pauseRotationAnimation];
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.foreImageView.bounds
                                                byRoundingCorners:UIRectCornerAllCorners
                                                      cornerRadii:CGSizeMake(self.foreImageView.width*0.5, self.foreImageView.width*0.5)];
    CAShapeLayer * layer = [[CAShapeLayer alloc] init];
    layer.frame = self.foreImageView.bounds;
    layer.path = path.CGPath;
    self.foreImageView.layer.mask = layer;
}

- (void)addTimer{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:1.0 target:[MyProxy proxyWithTarget:self] selector:@selector(setUpDataTimes) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}
/** 移除定时器*/
- (void)removeTimer{
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)addDisplaylink{
    if (!_displayLink) {
        CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget:[MyProxy proxyWithTarget:self]
                                                                  selector:@selector(updateLrc)];
        self.displayLink = displayLink;
        // 添加到 runloop
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

/** 移除 歌词面板信息 定时器*/
- (void)removeDisplayLind{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)updateLrc{
    MusicMessageModel * musicMessageModel = [[MusicOperationTool  shareInstance] getNewMusicMessageModel];
    NSArray <LrcModel *> * lrcModels = [LrcDataTool getLrcData:musicMessageModel.musicM.lrcname];
    [LrcDataTool getRow:musicMessageModel.costTime andLrcs:lrcModels completion:^(NSInteger row, LrcModel *lrcModel) {
       // 4.设置单行歌词
        self.lrcLabel.text = lrcModel.lrcStr;
        
        // 5.跟新歌词进度
        CGFloat progress = (musicMessageModel.costTime - lrcModel.beginTime) / (lrcModel.endTime - lrcModel.beginTime);
        self.lrcLabel.progress = progress;
    }];
    
    // 7.设置锁屏信息
    // 前台不更新, 进入后台之后才更新
    UIApplicationState state =  [UIApplication sharedApplication].applicationState;
    if (state == UIApplicationStateBackground) {
        [[MusicOperationTool shareInstance] setUpLockMessage];
    }
}

/** 当切换歌曲的时候, 更新 多次 界面数据*/
- (void)setUpDataTimes{
    // 获取最新数据
    MusicMessageModel *musicMessageModel = [[MusicOperationTool shareInstance] getNewMusicMessageModel];
    
    self.costTimeLabel.text = musicMessageModel.costTimeFormat;
    self.progressSlider.value = 1.0 * musicMessageModel.costTime / musicMessageModel.totalTime;
    
    // 播放或者暂停按钮 待定
    self.playButton.selected = musicMessageModel.isPlaying;
}

- (void)play:(UIButton *)button{
    button.selected = !button.selected;
    [self.playButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_offset(10);
    }];
    if (button.selected) {
        [[MusicOperationTool shareInstance] playCurrentMusic];
        [self resumeRotationAnimatioin];
    }
    else {
        [[MusicOperationTool shareInstance] pauseCurrentMusic];
        [self pauseRotationAnimation];
    }
}
- (void)playPrior:(UIButton *)button{
    if ([[MusicOperationTool shareInstance] preMusic]) {
         [self setUpData];
    };
}
- (void)playNext:(UIButton *)button{
    if ([[MusicOperationTool shareInstance] nextMusic]) {
        [self setUpData];
    }
}

- (void)addRotationAnimation{
    // 1.移除之前的动画
    NSString *key = @"rotation";
    [self.foreImageView.layer removeAnimationForKey:key];
    
    // 2.重新添加动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = 0;
    animation.toValue = @(M_PI * 2);
    animation.duration = 30;
    animation.repeatCount = MAXFLOAT;
    
    // 设置播放完成之后不移除
    animation.removedOnCompletion = NO;
    
    // 添加动画
    [self.foreImageView.layer addAnimation:animation forKey:key];
}
- (void)resumeRotationAnimatioin{
    [self.foreImageView.layer resumeLayer:self.foreImageView.layer];
}
- (void)pauseRotationAnimation{
    [self.foreImageView.layer pauseLayer:self.foreImageView.layer];
}
/* Base implementation sends -updateConstraints to the view.
 When a view has a view controller, this message is sent to the view controller during
 the autolayout updateConstraints pass in lieu of sending updateConstraints directly
 to the view.
 You may override this method in a UIViewController subclass for updating custom
 constraints instead of subclassing your view and overriding -[UIView updateConstraints].
 Overrides must call super or send -updateConstraints to the view.
 */
- (void)updateViewConstraints{
    
    [self.backGroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view).insets(self.view.safeAreaInsets);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    
    [self.backGroundToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
         make.edges.mas_equalTo(self.backGroundImageView);
    }];
    
    [self.playContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.height.mas_equalTo(@120);
            make.left.mas_equalTo(@0);
            make.bottom.mas_equalTo(-self.view.safeAreaInsets.bottom);
            make.right.mas_equalTo(@0);
        } else {
            make.height.mas_equalTo(@120);
            make.left.mas_equalTo(@0);
            make.bottom.mas_equalTo(@0);
            make.right.mas_equalTo(@0);
        }
        
    }];
    
    [self.priorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@[self.playView.mas_width,self.nextView.mas_width]);
        make.left.mas_equalTo(@0);
        make.top.mas_equalTo(@[self.playView.mas_top,self.nextView.mas_top,self.playContainView]);
        make.right.mas_equalTo(self.playView.mas_left).mas_offset(0);
        make.bottom.mas_offset(0);
        make.bottom.mas_equalTo(@[self.playView.mas_bottom,self.nextView.mas_bottom,@0]);
    }];
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.nextView.mas_left);
    }];
    [self.nextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(@0);
    }];
    
    [self.priorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_offset(@0);
        make.width.and.height.mas_equalTo(@64);
        make.right.mas_offset(@(-10));
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(@64);
        make.center.mas_offset(0);
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_offset(@0);
        make.width.and.height.mas_equalTo(64);
        make.left.mas_offset(@10);
    }];
    
    [self.progressContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@40);
        make.left.mas_equalTo(@0);
        make.bottom.mas_equalTo(self.playContainView.mas_top).mas_offset(@0);
        make.right.mas_equalTo(@0);
    }];
    
    [self.costTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(5);
        make.width.mas_equalTo(50);
        make.centerY.mas_offset(0);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-5);
        make.width.mas_equalTo(50);
        make.centerY.mas_offset(0);
    }];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.costTimeLabel.mas_right).mas_offset(5);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left).mas_offset(-5);
        make.centerY.mas_offset(0);
    }];
    
    [self.contentContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.top.mas_equalTo(@120);
        make.bottom.mas_equalTo(self.progressContainerView.mas_top).mas_offset(@0);
    }];
    
    [self.foreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.contentContainerView.mas_width).multipliedBy(0.8);
        make.centerX.mas_offset(0);
        make.centerY.mas_offset(-30);
    }];
    
    [self.lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_offset(0);
        make.bottom.mas_offset(-10);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Slider Event
- (IBAction)sliderDidTouchDown:(UISlider *)sender {
    // 移除定时器
    [self removeTimer];
}

- (IBAction)sliderDidTouchUp:(UISlider *)sender {
    
    // 控制当前的播放进度
    // 1.添加定时器
    [self addTimer];
    
    // 2.计算当前时间
    // 2.1 总时长
    NSTimeInterval totalTime = [[MusicOperationTool shareInstance] getNewMusicMessageModel].totalTime;
    
    // 2.2. 当前时间
    NSTimeInterval currentTime = sender.value * totalTime;
    
    // 3.设置当前播放进度
    [[MusicOperationTool shareInstance] seekTo:currentTime];
    
    if (sender.value >= 1.0) {
        
        [self playNext:nil];
    }
}

- (IBAction)sliderDidValueChange:(UISlider *)sender {
    
    // 设置 已经播放时长
    
    // 1.计算总时长
    NSTimeInterval totalTime = [[MusicOperationTool shareInstance] getNewMusicMessageModel].totalTime;
    
    // 2.当前时间
    NSTimeInterval currentTime = sender.value * totalTime;
    
    // 3.设置 已经播放时长
    self.costTimeLabel.text = [TimeTool getFormatTime:currentTime];
    
    NSLog(@"%lf", sender.value);
}


#pragma mark - remoteEvent

- (void)motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event{
    [self playNext:nil];
}

/** 锁屏状态下接收的远程事件处理*/
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    
    UIEventSubtype type = event.subtype;
    switch (type) {
        case UIEventSubtypeRemoteControlPlay:{
            //NSLog(@"播放");
            //[[QQMusicOperationTool shareInstance] playCurrentMusic];
            [self play:self.playButton];
            break;
        }
            
        case UIEventSubtypeRemoteControlPause:{
            //NSLog(@"暂停");
            // [[QQMusicOperationTool shareInstance] pauseCurrentMusic];
            [self play:self.playButton];
            break;
        }
            
        case UIEventSubtypeRemoteControlNextTrack:{
            //NSLog(@"下一首");
            //            [[QQMusicOperationTool shareInstance] nextMusic];
            [self playNext:nil];
            break;
        }
            
        case UIEventSubtypeRemoteControlPreviousTrack:{
            //NSLog(@"上一首");
            //            [[QQMusicOperationTool shareInstance] preMusic];
            [self playPrior:nil];
            break;
        }
        case UIEventSubtypeRemoteControlStop:{
            [self play:self.playButton];
            break;
        }
        default:{
            //NSLog(@"暂不处理");
            break;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"%s",__func__);
    [self removeTimer];
    [self removeDisplayLind];
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
