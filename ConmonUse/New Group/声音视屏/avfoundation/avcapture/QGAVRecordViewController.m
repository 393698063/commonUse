//
//  QGAVRecordViewController.m
//  ConmonUse
//
//  Created by jorgon on 2019/5/21.
//  Copyright © 2019年 jorgon. All rights reserved.
//

/*
 
 下面是一个有趣的写法，上网搜到这样一段话，补充说明之后能理解这种写法：
 这个问题严格上讲和Objective－C没什么太大的关系，这个是GNU C的对C的扩展语法
 
 在理解一下什么是GNU C ，下面是百度给的定义：
 GNU C 函式库（GNU C Library，又称为glibc）是一种按照LGPL许可协议发布的，公开源代码的，免费的，方便从网络下载的C的编译程序。
 GNU C运行期库，是一种C函式库，
 是程序运行时使用到的一些API集合，它们一般是已预先编译好，以二进制代码形式存
 在Linux类系统中，GNU C运行期库，通常作为GNU C编译程序的一个部分发布。
 它最初是自由软件基金会为其GNU操作系统所写，但目前最主要的应用是配合Linux内核，成为GNU/Linux操作系统一个重要的组成部分。
 
 继续解释：
 Xcode采用的Clang编译，Clang作为GCC(GCC的初衷是为GNU操作系统专门编写的一款编译器)的替代品，
 和GCC一样对于GNU C语法完全支持
 
 你可能知道if(condition)后面只能根一条语句，多条语句必须用{}阔起来，这个语法扩展即将一条(多条要用到{})语句外面加一个括号(),
 这样的话你就可以在表达式中应用循环、判断甚至本地变量等。
 表达式()最后一行应该一个能够计算结果的子表达式加上一个分号(;),这个子表达式作为整个结构的返回结果
 
 这个扩展在代码中最常见的用处在于宏定义中
 

self.captureSession = ({
    // 分辨率设置
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 先判断这个设备是否支持设置你要设置的分辨率
    if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        
 
        // 下面是对你能设置的预设图片的质量和分辨率的说明
         //AVCaptureSessionPresetHigh      High 最高的录制质量，每台设备不同
         //AVCaptureSessionPresetMedium    Medium 基于无线分享的，实际值可能会改变
         //AVCaptureSessionPresetLow       LOW 基于3g分享的
        // AVCaptureSessionPreset640x480   640x480 VGA
        // AVCaptureSessionPreset1280x720  1280x720 720p HD
        // AVCaptureSessionPresetPhoto     Photo 完整的照片分辨率，不支持视频输出
 
        [session setSessionPreset:AVCaptureSessionPresetMedium];
    }
    session;
});
 */

#import "QGAVRecordViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QGAVRecordViewController ()<AVCaptureFileOutputRecordingDelegate>
@property (nonatomic, strong) AVCaptureSession * captureSession;
@property (nonatomic, strong) AVCaptureFileOutput * captureMovieFileOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;
@property (nonatomic, copy) NSString * videoPath;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) UIButton * startButton;
@end

@implementation QGAVRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.startButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"开始录制" forState:UIControlStateNormal];
        button.frame = CGRectMake(100, 500, 100, 50);
        button;
    });
    [self.view addSubview:self.startButton];
    [self initParam];
}

#pragma mark -
#pragma mark - target method

- (void)startRecord:(UIButton *)btn {
    [self startCaptureWithSession];
}

//视频录制  AVCaptureSession + AVCaptureMovieFileOutput

/*
 1、初始化 AVCaptureSession 得到一个捕捉会话对象。
 
 2、通过 AVCaptureDevice 的类方法 defaultDeviceWithMediaType 区别 MediaType 得到 AVCaptureDevice 对象。
 
 3、得到上面的 AVCaptureDevice 对象之后，就是我们的 AVCaptureDeviceInput 输入对象了。
 把我们的输入对象添加到 AVCaptureSession ，
 当然这里输入对象是要区分音频和视频对象的，这个具体的代码里面我们说。
 
 4、有了输入当然也就有 AVCaptureMovieFileOutput，把它添加给AVCaptureSession对象。
 
 5、通过我们初始化的AVCaptureMovieFileOutput的connectionWithMediaType方法得到一个AVCaptureConnection对象，
 ACCaptureConnection可以控制input到output的数据传输，也可以设置视频录制的一些属性。
 
 6、也是通过前面得到的AVCaptureSession对象初始化得到一个AVCaptureVideoPreviewLayer对象，
 用来预览我们要录制的视频画面，注意这个时候我们的视频录制还没有开始。
 
 7、现在看看AVCaptureSession对象，你就发现输入输出以及Connection还有预览层都有了，那就让它 startRunning。
 
 8、好了，用我们的AVCaptureMovieFileOutput 的 startRecordingToOutputFileURL 开始录制吧。
 
 9、录制到满足你的需求时候记得让你startRunning的AVCaptureSession 通过 stopRunning休息了，
 让你的AVCaptureMovieFileOutput也可以stopRecording。这样整个过程就结束了！
 
 上面的过程我们就把使用AVCaptureSession + AVCaptureMovieFileOutput录制视频的过程说的清楚了，有些细节我们也提过了，我们看看下面我们的Demo效果，
 由于是在真机测试的就简单截两张图。具体的可以运行Demo看看：
 */


- (void)initParam {
//    self.videoPath = ({
//        NSString * url  = [NSTemporaryDirectory() stringByAppendingPathComponent:@"zhangxu.mov"];
//        NSLog(@"视频想要缓存的地址:%@",url);
//        url;
//    }) ;
    self.captureSession = ({
        // 分辨率设置
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        // 先判断这个设备是否支持设置你要设置的分辨率
        if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
            
            /*
             下面是对你能设置的预设图片的质量和分辨率的说明
             AVCaptureSessionPresetHigh      High 最高的录制质量，每台设备不同
             AVCaptureSessionPresetMedium    Medium 基于无线分享的，实际值可能会改变
             AVCaptureSessionPresetLow       LOW 基于3g分享的
             AVCaptureSessionPreset640x480   640x480 VGA
             AVCaptureSessionPreset1280x720  1280x720 720p HD
             AVCaptureSessionPresetPhoto     Photo 完整的照片分辨率，不支持视频输出
             */
            [session setSessionPreset:AVCaptureSessionPresetMedium];
        }
        session;
    });
    
    /*
     用于展示制的画面
     */
    self.captureVideoPreviewLayer = ({
        
        AVCaptureVideoPreviewLayer * preViewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        preViewLayer.frame = CGRectMake(10, 70, 355, 355);
        
        /*
         AVLayerVideoGravityResizeAspect:保留长宽比，未填充部分会有黑边
         AVLayerVideoGravityResizeAspectFill:保留长宽比，填充所有的区域
         AVLayerVideoGravityResize:拉伸填满所有的空间
         */
        preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:preViewLayer];
        self.view.layer.masksToBounds = YES;
        preViewLayer;
    });
    
    // 初始化一个设备输出对象
    self.captureMovieFileOutput = ({
        
        //输出一个电影文件
        /*
         a.AVCaptureMovieFileOutput  输出一个电影文件
         b.AVCaptureVideoDataOutput  输出处理视频帧被捕获
         c.AVCaptureAudioDataOutput  输出音频数据被捕获
         d.AVCaptureStillImageOutput 捕获元数据
         */
        
        AVCaptureMovieFileOutput * output = [[AVCaptureMovieFileOutput alloc]init];
        
        /*
         一个ACCaptureConnection可以控制input到output的数据传输。
         */
        AVCaptureConnection * connection = [output connectionWithMediaType:AVMediaTypeVideo];
        
        if ([connection isVideoMirroringSupported]) {
            
            /*
             视频防抖 是在 iOS 6 和 iPhone 4S 发布时引入的功能。到了 iPhone 6，增加了更强劲和流畅的防抖模式，
             被称为影院级的视频防抖动。相关的 API 也有所改动 (目前为止并没有在文档中反映出来，不过可以查看头文件）。
             防抖并不是在捕获设备上配置的，而是在 AVCaptureConnection 上设置。由于不是所有的设备格式都支持全部的防抖模式，
             所以在实际应用中应事先确认具体的防抖模式是否支持：
             
             typedef NS_ENUM(NSInteger, AVCaptureVideoStabilizationMode) {
             AVCaptureVideoStabilizationModeOff       = 0,
             AVCaptureVideoStabilizationModeStandard  = 1,
             AVCaptureVideoStabilizationModeCinematic = 2,
             AVCaptureVideoStabilizationModeAuto      = -1,  自动
             } NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
             */
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            //预览图层和视频方向保持一致
            connection.videoOrientation = [self.captureVideoPreviewLayer connection].videoOrientation;
        }
        
        if ([self.captureSession canAddOutput:output]) {
            
            [self.captureSession addOutput:output];
        }
        
        output;
    });
}

-(void)startCaptureWithSession{
    
    // 先删除之前的视频文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.videoPath] error:NULL];
    }
    
    NSError * error = nil;
    if ([self SetSessioninputs:error]) {
        
        // 开始录制
        [self.captureSession startRunning];
//        [self startRecordSession];
        
    }else{
        
        [self.captureSession stopRunning];
        NSLog(@"录制失败：%@",error);
    }
}

-(void)startRuningWithSession{
    
    __block int time = 0;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        
        time++;
        NSLog(@"录制的时长：%d",time);
        if (time == 10) {
            
            NSLog(@"录制的时长限制在10秒以内");
            [self.captureMovieFileOutput stopRecording];
            [self.captureSession stopRunning];
            dispatch_source_cancel(_timer);
        }
    });
    dispatch_resume(_timer);
}

#pragma mark --
#pragma mark -- AVCaptureMovieFileOutput 录制视频
-(void)startRecordSession{
    
    [self.captureMovieFileOutput startRecordingToOutputFileURL:({
        
        NSURL * url  = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"zhangxu.mov"]];
        NSLog(@"视频想要缓存的地址:%@",url);
        if ([[NSFileManager defaultManager]fileExistsAtPath:url.path]) {
            
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
        url;
    }) recordingDelegate:self];
}

-(BOOL)SetSessioninputs:(NSError *)error{
    
    // capture 捕捉 捕获
    /*
     视频输入类
     AVCaptureDevice 捕获设备类
     AVCaptureDeviceInput 捕获设备输入类
     */
    AVCaptureDevice * captureDevice   = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice: captureDevice error: &error];
    
    if (!videoInput) {
        return NO;
    }
    
    // 给捕获会话类添加输入捕获设备
    if ([self.captureSession canAddInput:videoInput]) {
        
        [self.captureSession addInput:videoInput];
    }else{
        return NO;
    }
    /*
     添加音频捕获设备
     */
    AVCaptureDevice * audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput * audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    if (!audioDevice) {
        
        return NO;
    }
    if ([self.captureSession canAddInput:audioInput]) {
        
        [self.captureSession addInput:audioInput];
    }
    return YES;
}

#pragma mark -
#pragma mark - recordDelegate
/*!
 @method captureOutput:didStartRecordingToOutputFileAtURL:fromConnections:
 @abstract
 Informs the delegate when the output has started writing to a file.
 
 @param output
 The capture file output that started writing the file.
 @param fileURL
 The file URL of the file that is being written.
 @param connections
 An array of AVCaptureConnection objects attached to the file output that provided the data that is being written to the file.
 
 @discussion
 This method is called when the file output has started writing data to a file. If an error condition prevents any data from being written, this method may not be called. captureOutput:willFinishRecordingToOutputFileAtURL:fromConnections:error: and captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error: will always be called, even if no data is written.
 
 Clients should not assume that this method will be called on a specific thread, and should also try to make this method as efficient as possible.
 */
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    //Recording started
    NSLog(@"视频录制开始！！");
    [self startRuningWithSession]; // 开始计时
}

/*!
 @method captureOutput:didPauseRecordingToOutputFileAtURL:fromConnections:
 @abstract
 Called whenever the output is recording to a file and successfully pauses the recording at the request of the client.
 
 @param output
 The capture file output that has paused its file recording.
 @param fileURL
 The file URL of the file that is being written.
 @param connections
 An array of AVCaptureConnection objects attached to the file output that provided the data that is being written to the file.
 
 @discussion
 Delegates can use this method to be informed when a request to pause recording is actually respected. It is safe for delegates to change what the file output is currently doing (starting a new file, for example) from within this method. If recording to a file is stopped, either manually or due to an error, this method is not guaranteed to be called, even if a previous call to pauseRecording was made.
 
 Clients should not assume that this method will be called on a specific thread, and should also try to make this method as efficient as possible.
 */
- (void)captureOutput:(AVCaptureFileOutput *)output
didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL
      fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
}

/*!
 @method captureOutput:didResumeRecordingToOutputFileAtURL:fromConnections:
 @abstract
 Called whenever the output, at the request of the client, successfully resumes a file recording that was paused.
 
 @param output
 The capture file output that has resumed its paused file recording.
 @param fileURL
 The file URL of the file that is being written.
 @param connections
 An array of AVCaptureConnection objects attached to the file output that provided the data that is being written to the file.
 
 @discussion
 Delegates can use this method to be informed when a request to resume recording is actually respected. It is safe for delegates to change what the file output is currently doing (starting a new file, for example) from within this method. If recording to a file is stopped, either manually or due to an error, this method is not guaranteed to be called, even if a previous call to resumeRecording was made.
 
 Clients should not assume that this method will be called on a specific thread, and should also try to make this method as efficient as possible.
 */
- (void)captureOutput:(AVCaptureFileOutput *)output didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    
}

/*!
 @method captureOutput:willFinishRecordingToOutputFileAtURL:fromConnections:error:
 @abstract
 Informs the delegate when the output will stop writing new samples to a file.
 
 @param output
 The capture file output that will finish writing the file.
 @param fileURL
 The file URL of the file that is being written.
 @param connections
 An array of AVCaptureConnection objects attached to the file output that provided the data that is being written to the file.
 @param error
 An error describing what caused the file to stop recording, or nil if there was no error.
 
 @discussion
 This method is called when the file output will stop recording new samples to the file at outputFileURL, either because startRecordingToOutputFileURL:recordingDelegate: or stopRecording were called, or because an error, described by the error parameter, occurred (if no error occurred, the error parameter will be nil). This method will always be called for each recording request, even if no data is successfully written to the file.
 
 Clients should not assume that this method will be called on a specific thread, and should also try to make this method as efficient as possible.
 */
- (void)captureOutput:(AVCaptureFileOutput *)output willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    
}

//@required

/*!
 @method captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:
 @abstract
 Informs the delegate when all pending data has been written to an output file.
 
 @param output
 The capture file output that has finished writing the file.
 @param outputFileURL
 The file URL of the file that has been written.
 @param connections
 An array of AVCaptureConnection objects attached to the file output that provided the data that was written to the file.
 @param error
 An error describing what caused the file to stop recording, or nil if there was no error.
 
 @discussion
 This method is called when the file output has finished writing all data to a file whose recording was stopped, either because startRecordingToOutputFileURL:recordingDelegate: or stopRecording were called, or because an error, described by the error parameter, occurred (if no error occurred, the error parameter will be nil). This method will always be called for each recording request, even if no data is successfully written to the file.
 
 Clients should not assume that this method will be called on a specific thread.
 
 Delegates are required to implement this method.
 */
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    NSLog(@"视频录制结束！！");
    NSLog(@"视频缓存地址:%@",outputFileURL);
    BOOL recordedSuccessfully = YES;
    id captureResult = [[error userInfo]objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
    if (captureResult) {
        
        recordedSuccessfully = [captureResult boolValue];
    }
    
    if (recordedSuccessfully) {
        
        [self compressVideoWithFileUrl:outputFileURL];
    }
}

#pragma mark --
#pragma mark -- 视频压缩方法
-(void)compressVideoWithFileUrl:(NSURL *)fileUrl{
    
    /*
     这里需要注意的一点就是在重复的路径上保存文件是不行的，可以选择在点击开始的时候删除之前的
     也可以这样按照时间命名不同的文件保存
     在后面的AVAssetWriter也要注意这一点
     */
    // 压缩后的视频的方法命名
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    // 压缩后的文件路径
    self.videoPath = [NSString stringWithFormat:@"%@/%@.mov",NSTemporaryDirectory(),[formatter stringFromDate:[NSDate date]]];
    
    // 先根据你传入的文件的路径创建一个AVAsset
    AVAsset * asset = [AVAsset  assetWithURL:fileUrl];
    /*
     
     根据urlAsset创建AVAssetExportSession压缩类
     第二个参数的意义：常用 压缩中等质量  AVAssetExportPresetMediumQuality
     AVF_EXPORT NSString *const AVAssetExportPresetLowQuality        NS_AVAILABLE_IOS(4_0);
     AVF_EXPORT NSString *const AVAssetExportPresetMediumQuality     NS_AVAILABLE_IOS(4_0);
     AVF_EXPORT NSString *const AVAssetExportPresetHighestQuality    NS_AVAILABLE_IOS(4_0);
     
     */
    AVAssetExportSession * exportSession = [[AVAssetExportSession alloc]initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    
    // 优化压缩，这个属性能使压缩的质量更好
    exportSession.shouldOptimizeForNetworkUse = YES;
    // 导处的文件的路径
    exportSession.outputURL =  [NSURL fileURLWithPath:self.videoPath];
    // 导出的文件格式
    /*!
     @constant  AVFileTypeMPEG4  mp4格式的   AVFileTypeQuickTimeMovie mov格式的
     @abstract A UTI for the MPEG-4 file format.
     @discussion
     The value of this UTI is @"public.mpeg-4".
     Files are identified with the .mp4 extension.
     可以看看这个outputFileType格式，比如AVFileTypeMPEG4也可以写成public.mpeg-4，其他类似
     */
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//    exportSession.progress
    NSLog(@"视频压缩后的presetName: %@",exportSession.presetName);
    // 压缩的方法  export 导出  Asynchronously 异步
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        /*
         exportSession.status 枚举属性
         typedef NS_ENUM(NSInteger, AVAssetExportSessionStatus) {
         AVAssetExportSessionStatusUnknown,
         AVAssetExportSessionStatusWaiting,
         AVAssetExportSessionStatusExporting,
         AVAssetExportSessionStatusCompleted,
         AVAssetExportSessionStatusFailed,
         AVAssetExportSessionStatusCancelled
         };
         */
        int exportStatus = exportSession.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed:
                
                NSLog(@"压缩失败");
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                /*
                 压缩后的大小
                 也可以利用exportSession的progress属性，随时监测压缩的进度
                 */
                NSData * data = [NSData dataWithContentsOfFile:self.videoPath];
                float dataSize = (float)data.length/1024/1024;
                NSLog(@"视频压缩后大小 %f M", dataSize);
                
            }
                break;
            default:
                break;
        }
    }];
}

/*
 上面是第一种视频录制的情况，AVCaptureSession + AVCaptureMovieFileOutput  在利用 AVAssetExportSession 压缩视频
 上面第一种方式的缺点就是视频压缩需要时间，压缩的速度比较慢，对用户的体验有一定的影响。
 还有第二种方式，利用AVCaptureSession + AVAssetWriter  这种方案
 */


@end
