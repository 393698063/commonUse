//
//  CATransitionView.m
//  过度动画Demo
//
//  Created by vera on 15/8/6.
//  Copyright (c) 2015年 vera. All rights reserved.
//

#import "CATransitionView.h"

@interface CATransitionView()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CATransitionView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self addSubview:self.imageView];
    }
    
    return self;
}

//xib
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self addSubview:self.imageView];
    }
    
    return self;
}

//设置坐标大小
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
}

#pragma mark - getter和setter
//getter
- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
    }
    
    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    //赋值
    _imageView.image = image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
