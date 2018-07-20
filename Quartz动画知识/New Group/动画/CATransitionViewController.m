//
//  CATransitionViewController.m
//  Quartz动画知识
//
//  Created by jorgon on 10/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//
//过度动画
#import "CATransitionViewController.h"
#import "CATransitionView.h"

@interface CATransitionViewController ()
{
    NSInteger index;
    UILabel * label;
}
@end

@implementation CATransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    index = 1;
    label = [[UILabel alloc] initWithFrame:CGRectMake(10, 174, 100, 20)];
    label.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:label];
    [self transitonCube];
    [self transitonFade];
}

- (void)transitonCube{
    CATransitionView * view = [[CATransitionView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 100)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor cyanColor];
    
    view.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",index]];
    
    UISwipeGestureRecognizer *swipeForLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    //方向
    swipeForLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:swipeForLeft];
    
    UISwipeGestureRecognizer *swipeForRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeForRight.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipeForRight];
    
}
- (void)swipe:(UISwipeGestureRecognizer *)gesture
{
    CATransitionView * view = (CATransitionView *)gesture.view;
    
    //过渡动画
    CATransition *transition = [CATransition animation];
    /*
     1     fade = 1,                   //淡入淡出
     2     push,                       //推挤
     3     reveal,                     //揭开
     4     moveIn,                     //覆盖
     5     cube,                       //立方体
     6     suckEffect,                 //吮吸
     7     oglFlip,                    //翻转
     8     rippleEffect,               //波纹
     9     pageCurl,                   //翻页
     10     pageUnCurl,                 //反翻页
     11     cameraIrisHollowOpen,       //开镜头
     12     cameraIrisHollowClose,      //关镜头
     */
    NSString * type = @"push";
    switch (index) {
        case 1:
            type = @"fade";
            label.text = @"淡入淡出";
            break;
        case 2:
            type = @"push";
            label.text = @"推挤";
            break;
        case 3:
            type = @"reveal";
            label.text = @"揭开";
            break;
        case 4:
            type = @"moveIn";
            label.text = @"覆盖";
            break;
        case 5:
            type = @"cube";
            label.text = @"立方体";
            break;
        case 6:
            type = @"suckEffect";
            label.text = @"吮吸";
            break;
        case 7:
            type = @"oglFlip";
            label.text = @"翻转";
            break;
        case 8:
            type = @"rippleEffect";
            label.text = @"波纹";
            break;
        case 9:
            type = @"pageCurl";
            label.text = @"翻页";
            break;
        case 10:
            type = @"pageUnCurl";
            label.text = @"反翻页";
            break;
        case 11:
            type = @"cameraIrisHollowOpen";
            label.text = @"开镜头";
            break;
        case 12:
            type = @"cameraIrisHollowClose";
            label.text = @"关镜头";
            break;
        default:
            break;
    }
    //设置类型
    /* The name of the transition. Current legal transition types include
     * `fade', `moveIn', `push' and `reveal'. Defaults to `fade'. */
    transition.type = type;
    //动画时间
    transition.duration = 1;
    
    
    //判断方向
    //向右滑
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        index--;
        if (index < 1) {
            index = 12;
        }
        //子类型
        /* An optional subtype for the transition. E.g. used to specify the
         * transition direction for motion-based transitions, in which case
         * the legal values are `fromLeft', `fromRight', `fromTop' and
         * `fromBottom'. */

        transition.subtype =  kCATransitionFromLeft;
    }
    else
    {
        index++;
        if (index > 12) {
            index = 1;
        }
        transition.subtype =  kCATransitionFromRight;
    }
    
    //添加动画到层
    [view.layer addAnimation:transition forKey:nil];
    
    //修改图片
    view.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",index]];
}

- (void)transitonFade{
    CATransitionView * view = [[CATransitionView alloc] initWithFrame:CGRectMake(0, 274, [UIScreen mainScreen].bounds.size.width, 100)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor cyanColor];
    
    view.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",index]];
    
    UISwipeGestureRecognizer *swipeForLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFade:)];
    //方向
    swipeForLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:swipeForLeft];
    
    UISwipeGestureRecognizer *swipeForRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeFade:)];
    swipeForRight.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipeForRight];
    
}
- (void)swipeFade:(UISwipeGestureRecognizer *)gesture
{
    CATransitionView * view = (CATransitionView *)gesture.view;
    //过渡动画
    CATransition *transition = [CATransition animation];
    //设置类型
    /* The name of the transition. Current legal transition types include
     * `fade', `moveIn', `push' and `reveal'. Defaults to `fade'. */
    transition.type = @"fade";
    //动画时间
    transition.duration = 1;
    
    
    //判断方向
    //向右滑
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        index--;
        if (index < 1) {
            index = 8;
        }
        //子类型
        /* An optional subtype for the transition. E.g. used to specify the
         * transition direction for motion-based transitions, in which case
         * the legal values are `fromLeft', `fromRight', `fromTop' and
         * `fromBottom'. */
        
        transition.subtype =  kCATransitionFromLeft;
    }
    else
    {
        index++;
        if (index > 8) {
            index = 1;
        }
        transition.subtype =  kCATransitionFromRight;
    }
    
    //添加动画到层
    [view.layer addAnimation:transition forKey:nil];
    
    //修改图片
    view.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg",index]];
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
