//
//  ScrollViewShakeViewController.m
//  ConmonUse
//
//  Created by Qiao,Gang(RM) on 2018/10/24.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "ScrollViewShakeViewController.h"
#import <YYCategories.h>

@interface ScrollViewShakeViewController ()
@property (nonatomic, strong) UIScrollView * scrollView;
@end

@implementation ScrollViewShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.height = self.view.height - 64;
    self.scrollView.top = 64;
    NSArray * images = @[@"9.jpg",@"10.jpg",@"11.jpg"];
    self.scrollView.showsHorizontalScrollIndicator = false;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.scrollView.height * images.count);
    [self.view addSubview:_scrollView];
    self.scrollView.pagingEnabled = YES;
    [images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView  * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:obj]];
        imageView.frame = CGRectMake(0, self.scrollView.height * idx, self.scrollView.width, self.scrollView.height);
        [self.scrollView addSubview:imageView];
    }];
    
//    CAKeyframeAnimation * anima = [CAKeyframeAnimation animationWithKeyPath:@"contentOffset.y"];
//
//    anima.duration = 3.0;
//
//    anima.repeatCount = MAXFLOAT;
//
//    anima.autoreverses = YES;
//
//    anima.values = @[@0, @(self.scrollView.height * 0.3)];
//
//    [self.scrollView.layer addAnimation:anima forKey:@"ani"];
    [self animate];
}

- (void)animate{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            CGPoint originP = obj.layer.position;
            
            CAKeyframeAnimation * anima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            
            anima.duration = 3.0;
            
            anima.repeatCount = MAXFLOAT;
            
            anima.autoreverses = YES;
            anima.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            anima.values = @[[NSValue valueWithCGPoint:originP], [NSValue valueWithCGPoint:CGPointMake(originP.x, originP.y - 200)]];
            [obj.layer addAnimation:anima forKey:@"ddd"];
        }
        if (idx == 1) {
            CGPoint originP = obj.layer.position;
            
            CAKeyframeAnimation * anima = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            
            anima.duration = 3.0;
            
            anima.repeatCount = MAXFLOAT;
            
            anima.autoreverses = YES;
            
            anima.values = @[[NSValue valueWithCGPoint:originP], [NSValue valueWithCGPoint:CGPointMake(originP.x, originP.y - 200)]];
            
            [obj.layer addAnimation:anima forKey:@"ddd"];
        }
    }];
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
