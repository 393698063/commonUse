//
//  QGLRCViewController.m
//  ConmonUse
//

//  Copyright © 2019年 jorgon. All rights reserved.
//

#import "QGLRCViewController.h"
#import "QGLRCView.h"

@interface QGLRCViewController ()
@property (nonatomic, strong) QGLRCView * lrcView;
@end

@implementation QGLRCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lrcView = [[QGLRCView alloc] initWithFrame:CGRectMake(0, 100, 300, 50)];
    [self.view addSubview:self.lrcView];
    
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 300, 100, 50);
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)onBtnClick:(UIButton *)btn {
    [self.lrcView startAnimation];
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
