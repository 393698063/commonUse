//
//  AVPlayerViewController.m
//  ConmonUse
//
//    on 2018/10/12.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "AVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerViewController ()
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * playItem;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;
@property (nonatomic, strong) UISlider * sliderl;
@property (assign, nonatomic)BOOL isReadToPlay;
@end

@implementation AVPlayerViewController
/*
 AVPlayerLayer帮我们把视频呈现出来了，可以说是AVPlayerLayer就是一个视频播放器的载体，它负责需要播放的画面。
 用MVC比喻，就是AVPlayerLayer属于V层，负责对用户的呈现。
 从AVPlayerLayer的便利构造器方法中可以看出我们在创建一个AVPlayerLayer的时候需要一个AVPlayer类型的参数。
 所以在创建AVPlayerLayer的时候，我们需要先有一个AVPlayer，它用MVC来分类的话就相当于MVC中的C层，
 负责播放单元和播放界面的协调工作，我们在它的便利构造器方法中可以看到他需要我们传入一个AVPlayerItem也就是播放单元，
 所谓的播放单元就是给播放器提供了一个数据的来源，用MVC来类比的话，
 它就属于M层，在创建一个播放单元的时候，我们首先得需要一个网址。
 综上所述，将一个视频播放出来可分为如下几个步骤。
 第一步：首先我们需要一个播放的网址
 NSURL *mediaURL = [NSURL URLWithString:@"http://baobab.wdjcdn.com
 第二步：初始化一个播放单元
 
 self.item = [AVPlayerItem playerItemWithURL:mediaURL];
 第三步：初始化一个播放器对象
 
 self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
 第四步：初始化一个播放器的Layer
 
 self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
 self.playerLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 500);
 [self.view.layer addSublayer:self.playerLayer];
 第五步：开始播放
 
 [self.myPlayer play];
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self playMethod];
    
}


- (void)playMethod {
    NSURL * url = [NSURL URLWithString:@"https://vd3.bdstatic.com/mda-igqnfkm99zggr7gc/mda-igqnfkm99zggr7gc.mp4?playlist=%5B%22hd%22%2C%22sc%22%5D&auth_key=1539338165-0-0-8a7e5f60244d0bbcfb01e996eeceaa9d&bcevod_channel=searchbox_feed&pd=haokan"];
    self.playItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200);
    
    self.playerLayer.backgroundColor = [UIColor redColor].CGColor;
    
    [self.view.layer addSublayer:self.playerLayer];
    
    [self.playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.player play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"item 有误");
                self.isReadToPlay = NO;
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"准好播放了");
                self.isReadToPlay = YES;
                self.sliderl.maximumValue = self.playItem.duration.value / self.playItem.duration.timescale;
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                self.isReadToPlay = NO;
                break;
            default:
                break;
        }
    }
    //移除监听（观察者）
    [object removeObserver:self forKeyPath:@"status"];
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
