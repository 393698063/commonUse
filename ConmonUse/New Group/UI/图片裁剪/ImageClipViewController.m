//
//  ImageClipViewController.m
//  ConmonUse
//
//  Created by jorgon on 2019/5/5.
//  Copyright © 2019年 jorgon. All rights reserved.
//

#import "ImageClipViewController.h"

@interface ImageClipViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIImageView * imageView;
@end

@implementation ImageClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    self.scrollView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    [self.scrollView addSubview:self.imageView];
    self.imageView.frame = self.scrollView.bounds;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width,self.scrollView.bounds.size.height);
    self.imageView.image = [UIImage imageNamed:@"testImage.jpeg"];
}

#pragma mark - scrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.minimumZoomScale = 0.5;
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

@end
