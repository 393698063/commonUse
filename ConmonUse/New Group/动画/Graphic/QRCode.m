//
//  QRCode.m
//  ConmonUse
//
//  Created by jorgon on 03/09/18.
//  Copyright © 2018年 jorgon. All rights reserved.
//

#import "QRCode.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import <YYCategories.h>


@interface QRCode()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession * captureSession;
@property (nonatomic, assign) BOOL isReading;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) CALayer * scanLayer;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * videoPreviewLayer;
@property (nonatomic, strong) UIView * boxView;
@end

@implementation QRCode
singleton_m(Code)
+ (UIImage *)generateQRcode:(NSString *)message{
    CIFilter * QRCodeGenerator = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [QRCodeGenerator setValue:[message dataUsingEncoding:NSUTF8StringEncoding]
                       forKey:@"inputMessage"];
    [QRCodeGenerator setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage * cimage = QRCodeGenerator.outputImage;
    UIImage * image = [UIImage imageWithCIImage:cimage];
    return image;
}
- (void)ReadingQRCode:(UIViewController *)controller{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                     if (granted) {
                                         //配置扫描view
                                         [self loadScanView:controller];
                                     } else {
                                         if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
                                             UIAlertController * alert = [UIAlertController alertControllerWithTitle:@""
                                                                                                             message:@"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机"
                                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                             UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                 
                                             }];
                                             UIAlertAction * sure = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                 
                                             }];
                                             [alert addAction:cancel];
                                             [alert addAction:sure];
                                             [controller presentViewController:alert animated:YES completion:nil];
                                         }
                                         else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
                                             NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机";
                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                                             [alertView show];
#pragma clang diagnostic pop
                                         }
                                     }
                                     
                                 });
                             }];
}

- (void)loadScanView:(UIViewController *)controller{
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:output];
    //5.设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //5.2.设置输出媒体数据类型为QRCode
    [output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //8.设置图层的frame
    UIView * viewPreview = controller.view;
    [_videoPreviewLayer setFrame:CGRectMake(0, viewPreview.height * 0.5, viewPreview.width, viewPreview.height * 0.5)];
    //9.将图层添加到预览view的图层上
    [viewPreview.layer addSublayer:_videoPreviewLayer];
    //10.设置扫描范围
    output.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    //10.1.扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(viewPreview.bounds.size.width * 0.2,
                                                       viewPreview.bounds.size.height*0.1 + viewPreview.height * 0.5,
                                                       viewPreview.bounds.size.width * 0.6,
                                                       viewPreview.bounds.size.width * 0.6)];
    _boxView.layer.borderColor = [UIColor redColor].CGColor;
    _boxView.layer.borderWidth = 1.0;
    
    [viewPreview addSubview:_boxView];
    
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor blackColor].CGColor;
    [_boxView.layer addSublayer:_scanLayer];
    
    [self startRunning];
}

- (void)startRunning{
    if (self.captureSession) {
        self.isReading = YES;
        [self.captureSession startRunning];
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats: YES];
    }
}

#pragma mark 结束
- (void)stopRunning {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil ;
    }
    [self.captureSession stopRunning];
    [_scanLayer removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
    [_boxView removeFromSuperview];
}
- (void)moveUpAndDownLine{
    CGRect frame = self.scanLayer.frame;
    NSLog(@"%@",NSStringFromCGRect(frame));
    if (_boxView.frame.size.height <= self.scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        self.scanLayer.frame = frame;
    } else {
        frame.origin.y += 5;
        [UIView animateWithDuration:0.1 animations:^{
            self.scanLayer.frame = frame;
        }];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    NSString *QRCode = nil;
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            QRCode=[(AVMetadataMachineReadableCodeObject*)metadata stringValue];
            break;
        } }
    NSLog(@"QR Code: %@", QRCode);
    [self stopRunning];
}
@end
