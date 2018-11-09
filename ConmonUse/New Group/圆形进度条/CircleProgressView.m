//
//  CircleProgressView.m
//  ConmonUse
//
//  Created by jorgon on 06/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//
#define kCircleProgessViewLineWidth 5

#import "CircleProgressView.h"

@interface CircleProgressView()
{
    //轨迹图层
    CAShapeLayer *_circleLayer;
    
    //轨迹的路径
    UIBezierPath *_circlePath;
    
    //进度的图层
    CAShapeLayer *_progessLayer;
    
    //进度的路径
    UIBezierPath *_progessPath;
}
@end

@implementation CircleProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //轨迹图层
        _circleLayer = [CAShapeLayer new];
        _circleLayer.frame = super.bounds;
        //填充的颜色
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        //线条的宽度
        _circleLayer.lineWidth = kCircleProgessViewLineWidth;
        //线条的颜色
        _circleLayer.strokeColor = [UIColor blackColor].CGColor;
        
        
        //轨迹path
        _circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width/2 - kCircleProgessViewLineWidth/2
                                                 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        _circleLayer.path = _circlePath.CGPath;
        

        /**
         进度的图层
         */
        _progessLayer = [CAShapeLayer layer];
        _progessLayer.frame = self.bounds;
        //填充颜色
        _progessLayer.fillColor = [UIColor grayColor].CGColor;
        //线条的宽度
        _progessLayer.lineWidth = kCircleProgessViewLineWidth;
        //线条的颜色
        _progessLayer.strokeColor = [UIColor orangeColor].CGColor;
        //线头样式
        _progessLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_progessLayer];
        
        //设置进度
        [self setProgess:0.0f];
        
    }
    return self;
}

//更新进度
- (void)setProgess:(CGFloat)progess
{
    _progess = progess;
    
    //轨迹path
    _progessPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width/2 - kCircleProgessViewLineWidth/2
                                              startAngle:0 endAngle:M_PI*2*_progess  clockwise:YES];
    _progessLayer.path = _progessPath.CGPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
