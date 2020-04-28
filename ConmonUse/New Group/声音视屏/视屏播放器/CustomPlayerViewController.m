//
//  CustomPlayerViewController.m
//  ConmonUse
//
//    on 2018/10/23.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "CustomPlayerViewController.h"
#import "SBPlayer.h"

@interface CustomPlayerViewController ()
@property (nonatomic,strong) SBPlayer *player;
@end

@implementation CustomPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"126"];
    [self.view addSubview:imageView];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.backgroundColor = [UIColor cyanColor];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(100);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(@-50);
    }];
    
    //纯代码请用此种方法
    //http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8 直播网址
    //初始化播放器
    self.player = [[SBPlayer alloc]initWithUrl:[NSURL URLWithString:@"https://vd3.bdstatic.com/mda-igqnfkm99zggr7gc/mda-igqnfkm99zggr7gc.mp4?playlist=%5B%22hd%22%2C%22sc%22%5D&auth_key=1539338165-0-0-8a7e5f60244d0bbcfb01e996eeceaa9d&bcevod_channel=searchbox_feed&pd=haokan"]];
    //设置标题
    [self.player setTitle:@"这是一个标题"];
    //设置播放器背景颜色
    self.player.backgroundColor = [UIColor blackColor];
    //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
    self.player.mode = SBLayerVideoGravityResizeAspect;
    //添加播放器到视图
    [self.view addSubview:self.player];
    //约束，也可以使用Frame
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(100);
        make.height.mas_equalTo(@250);
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
- (IBAction)playOrPause:(id)sender {
    
    [self.player stop];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    
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
