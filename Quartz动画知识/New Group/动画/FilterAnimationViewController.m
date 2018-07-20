//
//  FilterAnimationViewController.m
//  Quartz动画知识
//
//  Created by jorgon on 11/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "FilterAnimationViewController.h"

@interface FilterAnimationViewController ()

@end

@implementation FilterAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self filter];
}

- (void)filter{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 150, 150)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor blackColor];
    
    
    // The selection layer will pulse continuously.
    
    // This is accomplished by setting a bloom filter on the layer
    
    // create the filter and set its default values
    
    CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
    
    [filter setDefaults];
    
    [filter setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
    
    
    // name the filter so we can use the keypath to animate the inputIntensity
    
    // attribute of the filter
    
    [filter setName:@"pulseFilter"];
    
    // set the filter to the selection layer's filters
    
    [view.layer setFilters:[NSArray arrayWithObject:filter]];
    
    
    // create the animation that will handle the pulsing.
    
    CABasicAnimation* pulseAnimation = [CABasicAnimation animation];
    
    // the attribute we want to animate is the inputIntensity
    
    // of the pulseFilter
    
    pulseAnimation.keyPath = @"filters.pulseFilter.inputIntensity";
    
    // we want it to animate from the value 0 to 1
    
    pulseAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
    
    pulseAnimation.toValue = [NSNumber numberWithFloat: 2.5];
    
    
    // over a one second duration, and run an infinite
    
    // number of times
    
    pulseAnimation.duration = 10.0;
    
    pulseAnimation.repeatCount = HUGE_VALF;
    
    
    // we want it to fade on, and fade off, so it needs to
    
    // automatically autoreverse.. this causes the intensity
    
    // input to go from 0 to 1 to 0
    
    pulseAnimation.autoreverses = YES;
    
    
    // use a timing curve of easy in, easy out..
    
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    
    
    // add the animation to the selection layer. This causes
    
    // it to begin animating. We'll use pulseAnimation as the
    
    // animation key name
    [view.layer addAnimation:pulseAnimation forKey:@"pulseAnimation"];
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
