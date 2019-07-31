//
//  QGAVRecoredViewController+AVAsset.m
//  ConmonUse
//
//  Created by jorgon on 2019/6/10.
//  Copyright © 2019年 jorgon. All rights reserved.
//
/*
 上面说了AVCaptureSession + AVCaptureMovieFileOutput，现在说说我们的AVCaptureSession + AVAssetWriter，这个过程比起我们前面提到的是要复杂的，先来一个大概的概括，然后把它在解析一下：
 
 1、建录制会话
 
 2、设置视频的输入 和 输出
 
 3、设置音频的输入 和 输出
 
 4、添加视频预览层
 
 5、开始采集数据，这个时候还没有写入数据，用户点击录制后就可以开始写入数据
 
 6、初始化AVAssetWriter, 我们会拿到视频和音频的数据流，用AVAssetWriter写入文件，这一步需要我们自己实现。
 */

#import "QGAVRecoredViewController+AVAsset.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

static NSString *const AssetCollectionName = @"录制视频";

static char const * CAPTURE_SESSION_QUEUE_VIDEO = "CAPTURE_SESSION_QUEUE_VIDEO";
static char const * CAPTURE_SESSION_QUEUE_AUDIO = "CAPTURE_SESSION_QUEUE_AUDIO";
static char const * CAPTURE_SESSION_QUEUE_ASSET_WRITER = "CAPTURE_SESSION_QUEUE_ASSET_WRITER";
@interface QGAVRecoredViewController_AVAsset ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) UIButton * startButton;

@property (nonatomic, strong) dispatch_queue_t  videoDataOutputQueue;
@property (nonatomic, strong) dispatch_queue_t  audioDataOutputQueue;
@property (nonatomic, strong) dispatch_queue_t  writingQueue;
@property (nonatomic, strong) AVCaptureSession * captureSession;
@property (nonatomic, strong) AVAssetWriter * assetWriter;
@property (nonatomic, strong) AVAssetWriterInput * videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInput * audioWriterInput;
@property (nonatomic, assign) AVAssetWriterStatus  writeState;
@property (nonatomic, strong) NSString * dataDirectory;
@property (nonatomic, strong) AVCaptureVideoDataOutput * videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput * audioDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

@property(nonatomic,strong) dispatch_source_t timer;
@property (nonatomic, assign) BOOL canWrite;

/*
 __attribute__ 简单介绍(属性)
 __attribute__ 是GNU C的特色之一，在iOS中也有广泛的应用，系统中也有许多用到的地方。attribute可以设置函数属性（Function Attribute ）、变量属性（Variable Attribute ）和类型属性（Type Attribute)等.
 
 CMFormatDescriptionRef 是非OC对象，在前面加上__attribute__((NSObject))后，outputVideoFormatDescription的内存管理就会被当做OC的对象来管理。
 */
@property(nonatomic,retain) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property(nonatomic,retain) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;
@end

@implementation QGAVRecoredViewController_AVAsset

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self requestAuthor];
    self.dataDirectory = [NSTemporaryDirectory() stringByAppendingString:@"Movie.mp4"];
    self.startButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(startCaptureVideoButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"开始录制" forState:UIControlStateNormal];
        button.frame = CGRectMake(100, 500, 100, 50);
        button;
    });
    [self.view addSubview:self.startButton];
    
    /*用来初始化各种线程*/
    [self initDispatchQueue];
    
    /* */
    NSError * error;
    /*在这里初始化AVCaptureDevice 以及 AVCaptureDeviceInput*/
    if ([self SetSessioninputs:error]) {
        
        self.writeState = FMRecordStatePrepareRecording;
        /*用来初始化AVCaptureSession  AVCaptureVideoDataOutput  AVCaptureAudioDataOutput 以及连接他们的 AVCaptureConnection */
        [self captureSessionAddOutputSession];
    }
}

#pragma mark -- 请求相册权限

- (void)requestAuthor {
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusAuthorized) {
       
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status) {
                    case PHAuthorizationStatusAuthorized: {
                       
                        break;
                    }
                    case PHAuthorizationStatusDenied: {
                        
                       
                        break;
                    }
                    default:
                        break;
                }
            });
        }];
    }
    
}

#pragma mark --
#pragma maek -- 开始录制按钮事件
-(void)startCaptureVideoButtonClick{
    
    // 测试录制前的语音
    [self speak];
    
    // 先删除之前的视频文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dataDirectory]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.dataDirectory] error:NULL];
    }
    //
    [self.captureSession startRunning];
    /*初始化 AVAssetWriterInput */
    [self initAssetWriterInputAndOutput];
    [self startRuningWithSession];
}

#pragma mark --
#pragma maek -- 开始录制计时
-(void)startRuningWithSession{
    
    __block int time = 0;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        
        time++;
        NSLog(@"录制的时长：%d",time);
        if (time == 10) {
            
            NSLog(@"录制的时长限制在10秒以内");
            // 结束记录
            [self finishRecording];
            [self.captureSession stopRunning];
            dispatch_source_cancel(_timer);
        }
    });
    dispatch_resume(_timer);
}

// 简单的语音测试
-(void)speak{
    
    // 这样子可以简单的播放一段语音
    AVSpeechSynthesizer * synthesizer = [[AVSpeechSynthesizer alloc]init];
    // Utterance 表达方式
    AVSpeechSynthesisVoice * voice  = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    AVSpeechUtterance  * utterance = [[AVSpeechUtterance alloc]initWithString:@"准备了猪，开始录制视频了"];
    utterance.rate  = 1.5;// 这个是播放速率 默认1.0
    utterance.voice = voice;
    utterance.pitchMultiplier = 0.8; // 可在播放待定语句时候改变声调
    utterance.postUtteranceDelay = 0.1; // 语音合成器在播放下一条语句的时候有短暂的停顿  这个属性指定停顿的时间
    [synthesizer speakUtterance:utterance];
    
    /*
     
     "[AVSpeechSynthesisVoice 0x978a0b0] Language: th-TH",
     "[AVSpeechSynthesisVoice 0x977a450] Language: pt-BR",
     "[AVSpeechSynthesisVoice 0x977a480] Language: sk-SK",
     "[AVSpeechSynthesisVoice 0x978ad50] Language: fr-CA",
     "[AVSpeechSynthesisVoice 0x978ada0] Language: ro-RO",
     "[AVSpeechSynthesisVoice 0x97823f0] Language: no-NO",
     "[AVSpeechSynthesisVoice 0x978e7b0] Language: fi-FI",
     "[AVSpeechSynthesisVoice 0x978af50] Language: pl-PL",
     "[AVSpeechSynthesisVoice 0x978afa0] Language: de-DE",
     "[AVSpeechSynthesisVoice 0x978e390] Language: nl-NL",
     "[AVSpeechSynthesisVoice 0x978b030] Language: id-ID",
     "[AVSpeechSynthesisVoice 0x978b080] Language: tr-TR",
     "[AVSpeechSynthesisVoice 0x978b0d0] Language: it-IT",
     "[AVSpeechSynthesisVoice 0x978b120] Language: pt-PT",
     "[AVSpeechSynthesisVoice 0x978b170] Language: fr-FR",
     "[AVSpeechSynthesisVoice 0x978b1c0] Language: ru-RU",
     "[AVSpeechSynthesisVoice 0x978b210] Language: es-MX",
     "[AVSpeechSynthesisVoice 0x978b2d0] Language: zh-HK",
     "[AVSpeechSynthesisVoice 0x978b320] Language: sv-SE",
     "[AVSpeechSynthesisVoice 0x978b010] Language: hu-HU",
     "[AVSpeechSynthesisVoice 0x978b440] Language: zh-TW",
     "[AVSpeechSynthesisVoice 0x978b490] Language: es-ES",
     "[AVSpeechSynthesisVoice 0x978b4e0] Language: zh-CN",
     "[AVSpeechSynthesisVoice 0x978b530] Language: nl-BE",
     "[AVSpeechSynthesisVoice 0x978b580] Language: en-GB",
     "[AVSpeechSynthesisVoice 0x978b5d0] Language: ar-SA",
     "[AVSpeechSynthesisVoice 0x978b620] Language: ko-KR",
     "[AVSpeechSynthesisVoice 0x978b670] Language: cs-CZ",
     "[AVSpeechSynthesisVoice 0x978b6c0] Language: en-ZA",
     "[AVSpeechSynthesisVoice 0x978aed0] Language: en-AU",
     "[AVSpeechSynthesisVoice 0x978af20] Language: da-DK",
     "[AVSpeechSynthesisVoice 0x978b810] Language: en-US",
     "[AVSpeechSynthesisVoice 0x978b860] Language: en-IE",
     "[AVSpeechSynthesisVoice 0x978b8b0] Language: hi-IN",
     "[AVSpeechSynthesisVoice 0x978b900] Language: el-GR",
     "[AVSpeechSynthesisVoice 0x978b950] Language: ja-JP" )
     
     */
    // 通过这个方法可以看到整个支持的会话的列表
    NSLog(@"目前支持的语音列表:%@",[AVSpeechSynthesisVoice speechVoices]);
    
}

- (void)finishRecording{
    
    self.writeState = FMRecordStateFinish;
    if (_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting) {
        
        dispatch_async(self.writingQueue, ^{
            
            [self.assetWriter finishWritingWithCompletionHandler:^{
                
                @synchronized( self )
                {
                    NSError * error = _assetWriter.error;
                    if(error){
                        
                        NSLog(@"AssetWriterFinishError:%@",error);
                    }else{
                        
                        NSLog(@"成功!");
                        [self saveVideoWithFilePath:self.dataDirectory];
                        
                    }
                }
            }];
        });
    }
}
    
#pragma mark --
#pragma mark -- 视频保存相册
    /*
     
     Photos框架简单介绍
     
     Photos框架基本类
     
     1.PHAsset : 一个PHAsset对象代表一张图片或者一个视频文件
     1> 负责查询一堆的PHAsset对象
     
     2.PHAssetCollection : 一个PHAssetCollection对象代表一个相册
     1> 负责查询一堆的PHAssetCollection对象
     
     3.PHAssetChangeRequest
     1> 负责执行对PHAsset(照片或视频)的【增删改】操作
     2> 这个类只能放在-[PHPhotoLibrary performChanges:completionHandler:] 或者 -[PHPhotoLibrary performChangesAndWait:error:]方法的block中使用
     
     4.PHAssetCollectionChangeRequest
     1> 负责执行对PHAssetCollection(相册)的【增删改】操作
     2> 这个类只能放在-[PHPhotoLibrary performChanges:completionHandler:] 或者 -[PHPhotoLibrary performChangesAndWait:error:]方法的block中使用
     
     */
    
- (void)saveVideoWithFilePath:(NSString *)filepath {
    
    PHPhotoLibrary * library =[PHPhotoLibrary sharedPhotoLibrary];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSError * error = nil;
        // 用来抓取PHAsset的字符串标识，理解这里其实标识的是你录制的视频
        __block NSString * assetID = nil;
        
        // 用来抓取PHAssetCollectin的字符串标识符
        __block NSString * assetCollectionID  = nil;
        
        // 保存视频到相机胶卷
        [library performChangesAndWait:^{
            
            // 保存之后给你一个该视频标识
            assetID =[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:filepath]].placeholderForCreatedAsset.localIdentifier;
            NSLog(@"视频标识：%@",assetID);
            
        } error:&error];
        
        // 获取曾经创建过的[*自定义相册*]名字
        PHAssetCollection * collectionAsset = nil;
        // fetch 取出
        // Album 相簿  Regular  定期的；有规律的；合格的；整齐的；普通的
        PHFetchResult <PHAssetCollection *> * assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        for (PHAssetCollection * assetCollection in assetCollections) {
            
            if ([assetCollection.localizedTitle isEqualToString:AssetCollectionName]) {
                
                NSLog(@"相簿中所有相册的名字:%@",assetCollection.localizedTitle);
                collectionAsset = assetCollection;
                break;
            }
        }
        
        // 要是没有你自己自定义的相册，下面就开始创建这个相册
        if (!collectionAsset) {
            
            [library performChangesAndWait:^{
                
                assetCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:AssetCollectionName].placeholderForCreatedAssetCollection.localIdentifier;
                NSLog(@"创建的相册标识：%@",assetCollectionID);
                
            } error:&error];
            
            // 根据assetCollectionID得到相册
            collectionAsset = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionID] options:nil].firstObject;
        }
        
        
        // 把你最先录制的视频保存在你自定义的相册里面去
        [library performChangesAndWait:^{
            
            // 相册改变请求
            PHAssetCollectionChangeRequest * request =[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collectionAsset];
            // 从相簿中按照LocalIdentifier取出asset添加到自定义的相册中
            [request addAssets:[PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil]];
            
        } error:&error];
        
        
        if (error) {
            
            NSLog(@"存储到相册出错了！");
        }else{
            
            NSLog(@"存储在相册成功了！");
        }
        
    });
}

#pragma mark --
#pragma mark -- initDispatchQueue
-(void)initDispatchQueue{
    
    // 视频队列
    self.videoDataOutputQueue = dispatch_queue_create(CAPTURE_SESSION_QUEUE_VIDEO, DISPATCH_QUEUE_SERIAL);
    /*
     解释:
     用到dispatch_set_target_queue是为了改变self.videoDataOutputQueue串行队列的优先级，要是我们不使用dispatch_set_target_queue
     我们创建的队列执行的优先级都与默认优先级的Global Dispatch queue相同
     */
    dispatch_set_target_queue(self.videoDataOutputQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    
    // 音频队列
    self.audioDataOutputQueue = dispatch_queue_create(CAPTURE_SESSION_QUEUE_AUDIO, DISPATCH_QUEUE_SERIAL);
    
    // WRITER队列
    self.writingQueue = dispatch_queue_create(CAPTURE_SESSION_QUEUE_ASSET_WRITER, DISPATCH_QUEUE_SERIAL );
    
}


#pragma mark --
#pragma mark -- 初始化AVCaptureSession 以及 AVCaptureDevice  AVCaptureDeviceInput
-(BOOL)SetSessioninputs:(NSError *)error{
    
    // 具体的为什么能这样写，以及代码里面一些变量的具体的含义参考LittieVideoController
    self.captureSession = ({
        
        AVCaptureSession * captureSession = [[AVCaptureSession alloc]init];
        if ([captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
            
            [captureSession canSetSessionPreset:AVCaptureSessionPresetMedium];
        }
        captureSession;
    });
    
    // capture 捕捉 捕获
    /*
     视频输入类
     AVCaptureDevice 捕获设备类
     AVCaptureDeviceInput 捕获设备输入类
     */
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice: videoDevice error: &error];
    
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

#pragma mark --
#pragma mark -- 初始化 AVCaptureVideoDataOutput AVCaptureAudioDataOutput

-(void)captureSessionAddOutputSession{
    
    // 视频videoDataOutput
    self.videoDataOutput = ({
//        AVMetadataItem
//        CMTime
        AVCaptureVideoDataOutput * videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
        videoDataOutput.videoSettings = nil;
        videoDataOutput.alwaysDiscardsLateVideoFrames = NO;//zengjia nei cun zhan yong
        videoDataOutput;
        
    });
    
    // Sample样品 Buffer 缓冲
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES; //立即丢弃旧帧，节省内存，默认YES
    
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        
        [self.captureSession addOutput:self.videoDataOutput];
    }
    // 音频audioDataOutput
    self.audioDataOutput = ({
        
        AVCaptureAudioDataOutput * audioDataOutput = [[AVCaptureAudioDataOutput alloc]init];
        audioDataOutput;
        
    });
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.audioDataOutputQueue];
    if ([self.captureSession canAddOutput:self.audioDataOutput]) {
        
        [self.captureSession addOutput:self.audioDataOutput];
    }
    /*
     用于展示录制的画面
     */
    self.captureVideoPreviewLayer = ({
        
        AVCaptureVideoPreviewLayer * preViewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        preViewLayer.frame = CGRectMake(10, 50, 355, 355);
        
        /*
         AVLayerVideoGravityResizeAspect:保留长宽比，未填充部分会有黑边
         AVLayerVideoGravityResizeAspectFill:保留长宽比，填充所有的区域
         AVLayerVideoGravityResize:拉伸填满所有的空间
         */
//        [preViewLayer connection].videoOrientation = AVCaptureVideoOrientationPortrait;
        preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:preViewLayer];
        self.view.layer.masksToBounds = YES;
        preViewLayer;
    });
    
    
        AVCaptureConnection * connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoMirroringSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            //预览图层和视频方向保持一致
            connection.videoOrientation = [self.captureVideoPreviewLayer connection].videoOrientation;
        }

}

#pragma mark --
#pragma mark -- 初始化AVAssetWriterInput
-(void)initAssetWriterInputAndOutput{
    
    NSError * error;
    self.assetWriter = ({
        
        AVAssetWriter * assetWrite = [[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:self.dataDirectory] fileType:AVFileTypeMPEG4 error:&error];
        NSParameterAssert(assetWrite);
        assetWrite;
    });
    
    //每像素比特
    CGSize outputSize = CGSizeMake(355, 355);
    NSInteger numPixels = outputSize.width * outputSize.height;
    CGFloat   bitsPerPixel = 6.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    // [NSNumber numberWithDouble:128.0*1024.0]
    
    /*
     AVVideoCompressionPropertiesKey   硬编码参数
     
     AVVideoAverageBitRateKey          视频尺寸*比率
     AVVideoMaxKeyFrameIntervalKey     关键帧最大间隔，1为每个都是关键帧，数值越大压缩率越高
     AVVideoExpectedSourceFrameRateKey 帧率
     
     */
    NSDictionary * videoCpmpressionDic = @{AVVideoAverageBitRateKey:@(bitsPerSecond),
                                           AVVideoExpectedSourceFrameRateKey:@(30),
                                           AVVideoMaxKeyFrameIntervalKey : @(30),
                                           AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    
    /*
     AVVideoScalingModeKey 填充模式 Scaling 缩放
     AVVideoCodecKey       编码格式
     */
    NSDictionary * videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                                 AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                                 AVVideoWidthKey  : @(outputSize.height),
                                                 AVVideoHeightKey : @(outputSize.width),
                                                 AVVideoCompressionPropertiesKey : videoCpmpressionDic };
    //Compression 压缩
    if ([self.assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
        
        self.videoWriterInput = ({
            
            AVAssetWriterInput * input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
            NSParameterAssert(input);
            //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
            input.expectsMediaDataInRealTime = YES;
            input.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
            input;
        });
        
        
        if ([self.assetWriter canAddInput:self.videoWriterInput]) {
            
            [self.assetWriter addInput:self.videoWriterInput];
        }
    }
    
    // 下面这些属性设置会影响到语音是否能被正常的录入
    // Channel 频道
    // AudioChannelLayout acl;
    
    // void * memset(void *s,int c,size_t n)总的作用：将已开辟内存空间 s 的首 n 个字节的值设为值 c
    // bzero() 会将内存块（字符串）的前n个字节清零，其原型为：void bzero(void *s, int n)
    
    //bzero(&acl, sizeof(acl));
    //AVChannelLayoutKey:[NSData dataWithBytes: &acl length: sizeof(acl)],
    /*
     
     AVAudioRecorder 录音类这个后面说
     可以设置的一些属性 :
     AVNumberOfChannelsKey    通道数
     AVSampleRateKey          采样率 一般用44100
     AVLinearPCMBitDepthKey   比特率 一般设16 32
     AVEncoderAudioQualityKey 质量
     AVEncoderBitRateKey      比特采样率 一般是128000
     AVChannelLayoutKey       通道布局值是一个包含AudioChannelLayout的NSData对象
     */
    NSDictionary * audioSettings = @{  AVFormatIDKey:@(kAudioFormatMPEG4AAC) ,
                                       AVEncoderBitRatePerChannelKey:@(64000),
                                       AVSampleRateKey:@(44100.0),
                                       AVNumberOfChannelsKey:@(1)};
    
    if ([self.assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio]) {
        
        self.audioWriterInput = ({
            
            AVAssetWriterInput * input = [[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
            
            //Parameter 参数 系数 参量
            //NSParameterAssert注意条件书写不支持逻辑或语法
            
            /*
             注意它和NSAssert的区别
             在NSAssert中你是可以写逻辑判断的语句的。比如：
             NSAssert(count>10, @"总数必须大于10"); 这条语句中要是count<=10 就会报错
             */
            
            NSParameterAssert(input);
            input.expectsMediaDataInRealTime = YES;
            input;
            
        });
        
        if ([self.assetWriter canAddInput:self.audioWriterInput]) {
            
            [self.assetWriter addInput:self.audioWriterInput];
        }
    }
    self.writeState = FMRecordStateRecording;
}

/*
 NOTE: 注意这里的 setSampleBufferDelegate 这个方法，
 通过这个方法有两点你就理解了，一是为什么我们需要队列。二就是为什么我们处理采集到的视频、音频数据的时候是在这个 AVCaptureVideoDataOutputSampleBufferDelegate协议的方法里面
 */
#pragma mark --
#pragma mrak - AVCaptureVideoDataOutputSampleBufferDelegate

/*!
 @method captureOutput:didOutputSampleBuffer:fromConnection:
 @abstract
 Called whenever an AVCaptureVideoDataOutput instance outputs a new video frame.
 
 @param output
 The AVCaptureVideoDataOutput instance that output the frame.
 @param sampleBuffer
 A CMSampleBuffer object containing the video frame data and additional information about the frame, such as its format and presentation time.
 @param connection
 The AVCaptureConnection from which the video was received.
 
 @discussion
 Delegates receive this message whenever the output captures and outputs a new video frame, decoding or re-encoding it as specified by its videoSettings property. Delegates can use the provided video frame in conjunction with other APIs for further processing. This method will be called on the dispatch queue specified by the output's sampleBufferCallbackQueue property. This method is called periodically, so it must be efficient to prevent capture performance problems, including dropped frames.
 
 Clients that need to reference the CMSampleBuffer object outside of the scope of this method must CFRetain it and then CFRelease it when they are finished with it.
 
 Note that to maintain optimal performance, some sample buffers directly reference pools of memory that may need to be reused by the device system and other capture inputs. This is frequently the case for uncompressed device native capture where memory blocks are copied as little as possible. If multiple sample buffers reference such pools of memory for too long, inputs will no longer be able to copy new samples into memory and those samples will be dropped. If your application is causing samples to be dropped by retaining the provided CMSampleBuffer objects for too long, but it needs access to the sample data for a long period of time, consider copying the data into a new buffer and then calling CFRelease on the sample buffer if it was previously retained so that the memory it references can be reused.
 */
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (sampleBuffer == NULL){
        
        NSLog(@"empty sampleBuffer");
        return;
    }
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    if (connection == [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo]) {
        
        if (self.outputVideoFormatDescription == nil) {
            
            self.outputVideoFormatDescription = formatDescription;
        }else{
            
            self.outputVideoFormatDescription = formatDescription;
            @synchronized (self) {
                
                [self appendVideoSampleBuffer:sampleBuffer];
                
            }
        }
    }else if (connection == [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio]){
        
        
        self.outputAudioFormatDescription = formatDescription;
        @synchronized (self) {
            
            [self appendAudioSampleBuffer:sampleBuffer];
        }
    }
}

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType{
    
    @synchronized(self){
        
        if (self.writeState < FMRecordStateRecording){
            
            NSLog(@"not ready yet");
            return;
        }
    }
    
    NSParameterAssert(sampleBuffer);
    CFRetain(sampleBuffer);
    // 写数据这一步要在异步线程中去操作，在异步串行队列中开始写
    // @autoreleasepool{} 作用是为了及时的释放掉不用的变量占用的内存，避免内存飙升
    dispatch_async(self.writingQueue, ^{
        
        @autoreleasepool {
            
            @synchronized(self) {
                
                if (self.writeState > FMRecordStateRecording){
                    
                    CFRelease(sampleBuffer);
                    return;
                }
            }
            
            if (!self.canWrite && mediaType == AVMediaTypeVideo) {
                
                [self.assetWriter startWriting];
                //Stamp 标记
                [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.canWrite = YES;
            }
            
            
            
            AVAssetWriterInput * input = (mediaType == AVMediaTypeVideo )? self.videoWriterInput:self.audioWriterInput;
            if (input.readyForMoreMediaData) {
                
                //
                BOOL success = [input appendSampleBuffer:sampleBuffer];
                if (!success) {
                    
                    [self finishRecording];
                    NSError *error = _assetWriter.error;
                    NSLog(@"input failure with error %@:",error);
                }
                
            }else{
                
                NSLog( @"%@ input not ready for more media data, dropping buffer", mediaType );
            }
            
            CFRelease(sampleBuffer);
        }
    });
    
}

/*!
 @method captureOutput:didDropSampleBuffer:fromConnection:
 @abstract
 Called once for each frame that is discarded.
 
 @param output
 The AVCaptureVideoDataOutput instance that dropped the frame.
 @param sampleBuffer
 A CMSampleBuffer object containing information about the dropped frame, such as its format and presentation time. This sample buffer will contain none of the original video data.
 @param connection
 The AVCaptureConnection from which the dropped video frame was received.
 
 @discussion
 Delegates receive this message whenever a video frame is dropped. This method is called once for each dropped frame. The CMSampleBuffer object passed to this delegate method will contain metadata about the dropped video frame, such as its duration and presentation time stamp, but will contain no actual video data. On iOS, Included in the sample buffer attachments is the kCMSampleBufferAttachmentKey_DroppedFrameReason, which indicates why the frame was dropped. This method will be called on the dispatch queue specified by the output's sampleBufferCallbackQueue property. Because this method will be called on the same dispatch queue that is responsible for outputting video frames, it must be efficient to prevent further capture performance problems, such as additional dropped video frames.
 */
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}
#pragma mark --
#pragma mrak -- AVCaptureAudioDataOutputSampleBufferDelegate


/*!
 @method captureOutput:didOutputSampleBuffer:fromConnection:
 @abstract
 Called whenever an AVCaptureAudioDataOutput instance outputs a new audio sample buffer.
 
 @param output
 The AVCaptureAudioDataOutput instance that output the samples.
 @param sampleBuffer
 A CMSampleBuffer object containing the audio samples and additional information about them, such as their format and presentation time.
 @param connection
 The AVCaptureConnection from which the audio was received.
 
 @discussion
 Delegates receive this message whenever the output captures and outputs new audio samples, decoding or re-encoding as specified by the audioSettings property. Delegates can use the provided sample buffer in conjunction with other APIs for further processing. This method will be called on the dispatch queue specified by the output's sampleBufferCallbackQueue property. This method is called periodically, so it must be efficient to prevent capture performance problems, including dropped audio samples.
 
 Clients that need to reference the CMSampleBuffer object outside of the scope of this method must CFRetain it and then CFRelease it when they are finished with it.
 */
//- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//
//}


#pragma mark --
#pragma mark --  AVCaptureMovieFileOutput 和 AVAssetWriter  方式比较
/**
 相同点：数据采集都在AVCaptureSession中进行，视频和音频的输入都一样，画面的预览一致。
 
 不同点：输出不一致
 
 AVCaptureMovieFileOutput 只需要一个输出即可，指定一个文件路后，视频和音频会写入到指定路径，不需要其他复杂的操作。
 
 AVAssetWriter 需要 AVCaptureVideoDataOutput 和 AVCaptureAudioDataOutput 两个单独的输出，拿到各自的输出数据后，然后自己进行相应的处理。可配参数不一致，AVAssetWriter可以配置更多的参数。
 
 视频剪裁不一致，AVCaptureMovieFileOutput 如果要剪裁视频，因为系统已经把数据写到文件中了，我们需要从文件中独到一个完整的视频，然后处理；而AVAssetWriter我们拿到的是数据流，还没有合成视频，对数据流进行处理，所以两则剪裁方式也是不一样。
 
 我们再说说第一种方式，在微信官方优化视频录制文章中有这样一段话：
 
 “于是用AVCaptureMovieFileOutput（640*480）直接生成视频文件，拍视频很流畅。然而录制的6s视频大小有2M+，再用MMovieDecoder+MMovieWriter压缩至少要7~8s，影响聊天窗口发小视频的速度。”
 
 这段话也反应出了第一种方式的缺点！然后在我看这类资料的时候，又看到这样一段话：
 
 “如果你想要对影音输出有更多的操作，你可以使用 AVCaptureVideoDataOutput 和 AVCaptureAudioDataOutput 而不是我们上节讨论的 AVCaptureMovieFileOutput。 这些输出将会各自捕获视频和音频的样本缓存，接着发送到它们的代理。代理要么对采样缓冲进行处理 (比如给视频加滤镜)，要么保持原样传送。使用 AVAssetWriter 对象可以将样本缓存写入文件”
 
 这样就把这两种之间的优劣进行了一个比较，希望看到这文章的每一个同行都能有收获吧
 */

@end
