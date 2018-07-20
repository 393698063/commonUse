//
//  CircleProgress.m
//  Quartz动画知识
//
//  Created by jorgon on 06/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "CircleProgress.h"
#import "CircleProgressView.h"

@interface CircleProgress ()
@property (nonatomic, strong) CircleProgressView * progressView;
@end

@implementation CircleProgress

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISlider * slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 100, 200, 20)];
    slider.maximumValue = 1.0f;
    slider.minimumValue = 0.0f;
    slider.minimumTrackTintColor = [UIColor greenColor];
    [slider addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    self.progressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 200, 100, 100)];
    [self.view addSubview:self.progressView];
}

- (void)change:(UISlider *)slider{
    [self.progressView setProgess:slider.value];
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
