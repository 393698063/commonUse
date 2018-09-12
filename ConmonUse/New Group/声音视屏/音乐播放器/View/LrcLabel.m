//
//  LrcLabel.m
//  ConmonUse
//
//  Created by jorgon on 27/08/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//https://www.jianshu.com/p/96cfd3697b21

#import "LrcLabel.h"

@implementation LrcLabel


/** 重写 set 方法, 重新绘制*/
- (void)setProgress:(CGFloat)progress{
    
    _progress = progress;
    
    if (_progress >= 0.99) {
        _progress = 0;
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    // 1.设置填充色
    [[UIColor greenColor] set];
    
    // 2.设置绘制的范围
    CGRect fillRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * self.progress, rect.size.height);
    
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
