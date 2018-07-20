//
//  CirclePortraitShape.m
//  Quartz动画知识
//
//  Created by jorgon on 09/07/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "CirclePortraitShape.h"

@implementation CirclePortraitShape

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //创建一个图层
        CAShapeLayer * shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        
        /*
         bezierPathWithArcCenter 圆心坐标
         radius:圆弧半径
         startAngle:开始弧度
         endAngle:结束的弧度
         clockwise:是否是顺时针,YES表示顺时针
         */
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
        
        shapeLayer.path = path.CGPath;
        
        //图层蒙版
        self.layer.mask = shapeLayer;
        
        self.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"c75c10385343fbf2c6e17e6eb27eca8064388faa.jpg"].CGImage);
    }
    return self;
}

@end
