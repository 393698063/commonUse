//
//  FunctionListViewController.m
//  ConmonUse
//
//  Created by jorgon on 06/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "FunctionListViewController.h"
#import "ControllerTransitionScaleAnimation.h"

@interface FunctionListViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray * data;
@property (nonatomic, weak) id <UINavigationControllerDelegate> navDelegate ;
@end

@implementation FunctionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    self.data= @[@"CircleProgress",@"CirclePortraitViewController",
                 @"KeyanimationViewController",
                 @"BasicAnimationViewController",
                 @"CATransitionViewController",
                 @"FilterAnimationViewController",
                 @"PourWaterViewController",
                 @"PanMenuViewController",
                 @"MessageForwardController",
                 @"SoundEffectViewController",
                 @"MusicListViewController",
                 @"MeasureOperationTimeViewController",
                 @"DispatchTimerViewController",
                 @"GraphicViewController",
                 @"PasteBoardViewController",
                 @"ScrollReuseViewController",
                 @"AVPlayerViewController",
                 @"SiriShortCutManagerViewController",
                 @"CustomPlayerViewController",
                 @"ScrollViewShakeViewController",
                 @"ScrolloffsetViewController",
                 @"ImageClipViewController",
                 @"AVSpeechSynthesizeViewController",
                 @"AVAudioViewController",
                 @"QGAVRecordViewController",
                 @"QGAVRecoredViewController_AVAsset",
                 @"QGFaceDetactorViewController"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _navDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.delegate = _navDelegate;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tt"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tt"];
    }
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * vcStr = self.data[indexPath.row];
    if (!vcStr.length) {
        return;
    }
    NSString * type = @"push";
    switch (indexPath.row%13) {
        case 1:
            type = @"fade";
//            label.text = @"淡入淡出";
            break;
        case 2:
            type = @"push";
//            label.text = @"推挤";
            break;
        case 3:
            type = @"reveal";
//            label.text = @"揭开";
            break;
        case 4:
            type = @"moveIn";
//            label.text = @"覆盖";
            break;
        case 5:
            type = @"cube";
//            label.text = @"立方体";
            break;
        case 6:
            type = @"suckEffect";
//            label.text = @"吮吸";
            break;
        case 7:
            type = @"oglFlip";
//            label.text = @"翻转";
            break;
        case 8:
            type = @"rippleEffect";
//            label.text = @"波纹";
            break;
        case 9:
            type = @"pageCurl";
//            label.text = @"翻页";
            break;
        case 10:
            type = @"pageUnCurl";
//            label.text = @"反翻页";
            break;
        case 11:
            type = @"cameraIrisHollowOpen";
//            label.text = @"开镜头";
            break;
        case 12:
            type = @"cameraIrisHollowClose";
//            label.text = @"关镜头";
            break;
        default:
            break;
    }
//    //创建过渡动画
    CATransition *transiton = [CATransition animation];
    //类型,立方体
    transiton.type = type;
    transiton.subtype = kCATransitionFromRight;
    //动画时间
    transiton.duration = 1;
    UIViewController * vc = [[NSClassFromString(vcStr) alloc] init];
    vc.title = vcStr;
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view.layer addAnimation:transiton forKey:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 转场动画
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if ([toVC isKindOfClass:NSClassFromString(@"ScrollReuseViewController")] || [toVC isKindOfClass:NSClassFromString(@"FunctionListViewController")] ) {
//        [toVC.view.layer removeAllAnimations];
        [toVC.navigationController.view.layer removeAllAnimations];
        return [ControllerTransitionScaleAnimation new];
    }
    return nil;
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
