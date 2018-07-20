//
//  PourWaterViewController.m
//  Quartz动画知识
//
//  Created by jorgon on 11/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "PourWaterViewController.h"

@interface PourWaterViewController ()
{
    CAShapeLayer * uplayer;
    CAShapeLayer * downLayer;
}
@end

@implementation PourWaterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView * gray = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
    gray.image = [UIImage imageNamed:@"gray"];
    [self.view addSubview:gray];
    
    UIImageView * green = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
    green.image = [UIImage imageNamed:@"green"];
    [self.view addSubview:green];
    
    
    CALayer * layer = [CALayer layer];
    layer.frame = green.bounds;
    
//    layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    uplayer = [CAShapeLayer layer];
    uplayer.bounds = CGRectMake(0, 0, 30.0f, 30.0f);
    uplayer.fillColor = [UIColor whiteColor].CGColor; // Any color but clear will be OK
    uplayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(15.0f, 15.0f)
                                                           radius:15.0f
                                                       startAngle:0
                                                         endAngle:2*M_PI
                                                        clockwise:YES].CGPath;
    uplayer.opacity = 0.8f;
    uplayer.position = CGPointMake(-5.0f, -5.0f);
    [layer addSublayer:uplayer];
    
    downLayer = [CAShapeLayer layer];
    downLayer.bounds = CGRectMake(0, 0, 30.0f, 30.0f);
    downLayer.fillColor = [UIColor greenColor].CGColor; // Any color but clear will be OK
    downLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(15.0f, 15.0f)
                                                             radius:15.0f
                                                         startAngle:0
                                                           endAngle:2*M_PI
                                                          clockwise:YES].CGPath;
    downLayer.position = CGPointMake(35.0f, 35.0f);
    [layer addSublayer:downLayer];
    
    /* When true an implicit mask matching the layer bounds is applied to
     * the layer (including the effects of the `cornerRadius' property). If
     * both `mask' and `masksToBounds' are non-nil the two masks are
     * multiplied to get the actual mask values. Defaults to NO.
     * Animatable. */
    green.layer.mask = layer;
//    [green.layer addSublayer:layer];
    
    
    CABasicAnimation * bsup = [CABasicAnimation animationWithKeyPath:@"position"];
    bsup.fromValue = [NSValue valueWithCGPoint:CGPointMake(-5.0f, -5.0f)];
    bsup.toValue = [NSValue valueWithCGPoint:CGPointMake(10.0f, 10.0f)];
    bsup.duration = 1.5f;
    bsup.autoreverses = YES;
    bsup.repeatCount = HUGE_VAL;
    [uplayer addAnimation:bsup forKey:nil];
    
    CABasicAnimation * bsDown = [CABasicAnimation animationWithKeyPath:@"position"];
    bsDown.fromValue = [NSValue valueWithCGPoint:CGPointMake(35.0f, 35.0f)];
    bsDown.toValue = [NSValue valueWithCGPoint:CGPointMake(20.0f, 20.0f)];
    bsDown.duration = 1.5f;
    bsDown.autoreverses = YES;
    bsDown.repeatCount = HUGE_VAL;
    [downLayer addAnimation:bsDown forKey:nil];
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
