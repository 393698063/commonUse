//
//  QGFaceDetactorViewController.m
//  ConmonUse
//
//  Created by Qiao,Gang(RM) on 2019/6/28.
//  Copyright © 2019年 jorgon. All rights reserved.
//

#import "QGFaceDetactorViewController.h"

@interface QGFaceDetactorViewController ()
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * label;
@end

@implementation QGFaceDetactorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.label];
    [self faceDetectWithImage:self.imageView.image];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width / 16 * 9)];
        NSString * path = [[NSBundle mainBundle] pathForResource:@"face.PNG" ofType:nil];
        _imageView.image = [UIImage imageWithContentsOfFile:path];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, 300, 50)];
        _label.textColor = [UIColor blackColor];
    }
    return _label;
}

#pragma mark - 识别人脸
- (void)faceDetectWithImage:(UIImage *)image {
    
    for (UIView *view in _imageView.subviews) {
        [view removeFromSuperview];
    }
    
    // 图像识别能力：可以在CIDetectorAccuracyHigh(较强的处理能力)与CIDetectorAccuracyLow(较弱的处理能力)中选择，因为想让准确度高一些在这里选择CIDetectorAccuracyHigh
    NSDictionary *opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    // 将图像转换为CIImage
    CIImage *faceImage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector *faceDetector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    // 识别出人脸数组
    NSArray *features = [faceDetector featuresInImage:faceImage];
    // 得到图片的尺寸
    CGSize inputImageSize = [faceImage extent].size;
    //将image沿y轴对称
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
    //将图片上移
    transform = CGAffineTransformTranslate(transform, 0, -inputImageSize.height);
#warning 为什么要将图片上移
    // 取出所有人脸
    for (CIFaceFeature *faceFeature in features){
        //获取人脸的frame
        CGRect faceViewBounds = CGRectApplyAffineTransform(faceFeature.bounds, transform);
        CGSize viewSize = _imageView.bounds.size;
        CGFloat scale = MIN(viewSize.width / inputImageSize.width,
                            viewSize.height / inputImageSize.height);
        CGFloat offsetX = (viewSize.width - inputImageSize.width * scale) / 2;
        CGFloat offsetY = (viewSize.height - inputImageSize.height * scale) / 2;
        // 缩放
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        // 修正
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds,scaleTransform);
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
        
        //描绘人脸区域
        UIView* faceView = [[UIView alloc] initWithFrame:faceViewBounds];
        faceView.layer.borderWidth = 2;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [_imageView addSubview:faceView];
        
        // 判断是否有左眼位置
        if(faceFeature.hasLeftEyePosition){}
        // 判断是否有右眼位置
        if(faceFeature.hasRightEyePosition){}
        // 判断是否有嘴位置
        if(faceFeature.hasMouthPosition){}
    }
    self.label.text = [NSString stringWithFormat:@"识别出了%ld张脸", features.count];
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
