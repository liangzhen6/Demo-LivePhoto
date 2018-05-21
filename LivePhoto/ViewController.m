//
//  ViewController.m
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/14.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import <AVFoundation/AVFoundation.h>

#import "JPEG.h"
#import "QuickTimeMov.h"

#import "FrameView.h"

@interface ViewController ()
@property(nonatomic,assign)BOOL imageWriteRes;
@property(nonatomic,assign)BOOL videoWriteRes;
@property(nonatomic,copy)NSString *originVideoPath;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property(nonatomic,strong)AVPlayer *player;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIView *livePhotoBackView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property(nonatomic,strong)FrameView *frameView;
@property(nonatomic,strong)PHLivePhotoView *livePhotoView;
@end

@implementation ViewController
/* 只有6s以后的设备可以存储以及展示livePhoto  */
- (void)viewDidLoad {
    [super viewDidLoad];
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.originVideoPath]];
    AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer insertSublayer:playerLayer below:self.slider.layer];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [player play];
    self.player = player;
    CGFloat width = [UIScreen mainScreen].bounds.size.width/3;
    CGFloat height = width * 9/16;
    
    _frameView = [FrameView frameViewWithFrame:CGRectMake(0, self.playerView.bounds.size.height - height - 30, width, height)];
    [self.playerView addSubview:_frameView];
    __weak typeof (self)ws = self;

    //初始化 live photo
    PHLivePhotoView * livePhotoView = [[PHLivePhotoView alloc] initWithFrame:self.livePhotoBackView.bounds];
    [self.livePhotoBackView addSubview:livePhotoView];
    livePhotoView.hidden = YES;
    self.livePhotoView = livePhotoView;
    
    [_frameView setSelectBlock:^(UIImage *image) {
        ws.coverImage.image = image;
        //将处理的结果置空
        ws.imageWriteRes = NO;
        ws.videoWriteRes = NO;
        [ws.livePhotoView stopPlayback];
        ws.livePhotoView.livePhoto = nil;
        ws.livePhotoView.hidden = YES;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rePlayVideo) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    //监听进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //监听进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    //初始化
    [self sliderValue:self.slider];
    self.coverImage.image = [self getVideoImageWithTime:0.0 videoPath:[NSURL fileURLWithPath:self.originVideoPath]];
    //松手消失
    [self.slider addTarget:self action:@selector(touchAciton) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)sliderValue:(UISlider *)sender {
    self.frameView.hidden = NO;
    NSTimeInterval totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    NSTimeInterval currentTime = sender.value * totalTime;
    NSInteger currentTimeInteger = (NSInteger)currentTime;
    NSInteger minute = currentTimeInteger/60;
    NSInteger second = currentTimeInteger%60;
    
    UIImage * image = [self getVideoImageWithTime:currentTimeInteger videoPath:[NSURL fileURLWithPath:self.originVideoPath]];
    
    NSString *currentTimeStr;
    if (minute > 99) {
        currentTimeStr = [NSString stringWithFormat:@"%ld:%02ld",(long)minute,(long)second];
    } else {
        currentTimeStr = [NSString stringWithFormat:@"%02ld:%02ld",(long)minute,(long)second];
    }
    //更新图片 以及 时间
    [self.frameView updateImage:image currentTime:currentTimeStr];

    //更新 frameView 的 位置。
    CGFloat currentX = [UIScreen mainScreen].bounds.size.width * sender.value;
    CGFloat frameViewWidth = self.frameView.bounds.size.width;
    CGFloat maxX = [UIScreen mainScreen].bounds.size.width - frameViewWidth/2;
    CGFloat minX = frameViewWidth/2;
 
    if (currentX < minX ) {
        currentX = minX;
    } else if (currentX > maxX){
        currentX = maxX;
    }
    
    CGRect frame = self.frameView.frame;
    frame.origin.x = currentX - frameViewWidth/2;
    self.frameView.frame = frame;
    
    [self.frameView changeAlertLabelStart:NO];
    
}
- (void)touchAciton {
    [self.frameView changeAlertLabelStart:YES];
}

//进入前台
- (void)becomeActive {
    if (self.player.rate == 0.0) {
        [self.player play];//继续
     }
}
//进入后台
- (void)enterBackground {
    if (self.player.rate == 1.0) {
        //正在播
        [self.player pause];//暂停
    }
}

/**
 重复播放
 */
- (void)rePlayVideo {
    CMTime dragedCMTime = CMTimeMake(0, 1);
    [self.player seekToTime:dragedCMTime];
    [self.player play];
}


- (IBAction)saveLivePhoto:(UIButton *)sender {
    NSString * assetIdentifier = [[NSUUID UUID] UUIDString];
    NSString * imagePath = [self getFilePathWithKey:@"IMG.jpg"];
    NSString * videoPath = [self getFilePathWithKey:@"IMG.mov"];
    
    if (_videoWriteRes && _imageWriteRes) {
        //如果是 已经处理好了，那就直接存储。
        //存储live photo
        if (sender.tag == 1) {
            //存储live photo
            [self writeLive:[NSURL fileURLWithPath:videoPath] image:[NSURL fileURLWithPath:imagePath]];
        } else {
            //点击了预览 就播放
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }
        return;
    }
    
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
//    NSURL * URL = [NSURL fileURLWithPath:path];
//    UIImage * image = [self getVideoImageWithTime:5.0 videoPath:URL];
    if (self.coverImage) {
        NSData * imageData = UIImageJPEGRepresentation(self.coverImage.image, 1.0);
        BOOL isok = [imageData writeToFile:[self getFilePathWithKey:@"image.jpg"] atomically:YES];
        if (!isok) {
            NSLog(@"图片写入错误！！");
        }
        //1.先把旧文件移除
        [[NSFileManager defaultManager] removeItemAtPath:[self getFilePathWithKey:@"IMG.jpg"] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[self getFilePathWithKey:@"IMG.mov"] error:nil];
        
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t globle = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        __weak typeof (self)ws = self;
        //任务一 写入 图片
        dispatch_group_async(group, globle, ^{
            JPEG *jpeg = [[JPEG alloc] initWithPath:[self getFilePathWithKey:@"image.jpg"]];
            [jpeg writeDest:imagePath assetIdentifier:assetIdentifier result:^(BOOL res) {
                ws.imageWriteRes = res;
            }];
        });
        //任务二 写入 视频
        dispatch_group_async(group, globle, ^{
            QuickTimeMov *quickMov = [[QuickTimeMov alloc] initWithPath:self.originVideoPath];
            [quickMov write:videoPath assetIdentifier:assetIdentifier result:^(BOOL res) {
                ws.videoWriteRes = res;
            }];
        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (ws.videoWriteRes && ws.imageWriteRes) {
                // 展示出 live photo
                ws.livePhotoView.hidden = NO;
                [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[[NSURL fileURLWithPath:videoPath], [NSURL fileURLWithPath:imagePath]] placeholderImage:self.coverImage.image targetSize:self.coverImage.image.size contentMode:PHImageContentModeAspectFit resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
                    if (livePhoto) {
                        ws.livePhotoView.livePhoto = livePhoto;
                    }
                }];
                if (sender.tag == 1) {
                    //存储live photo
                    [ws writeLive:[NSURL fileURLWithPath:videoPath] image:[NSURL fileURLWithPath:imagePath]];
                } else {
                    //点击了预览 就播放
                    [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
                }
            }
        });
    }
}

/*
 参考文档
 https://blog.csdn.net/hmh007/article/details/54408764
 其实 live photo 可以拆解为一个jpg 图片 + 一个mov视频，但是是对这二者进行特殊的处理才可以。
 即对jpg + mov 加入一个数据，然后通过图片的PhotoLibrary 将两个文件一起存储即可得到 livephoto
 JPEG 与 QuickTimeMov 文件参考：
 OC:
 https://github.com/GUIYIVIEW/LivePhoto-master/tree/master/LivePhoto-master/LivePhoto-master
 Swift:
 https://github.com/genadyo/LivePhotoDemo
 */

- (void)writeLive:(NSURL *)videPath image:(NSURL *)imagePath {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest * request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypePhoto fileURL:imagePath options:nil];
        [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videPath options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //保存成功
            NSLog(@"保存成功");
        }
    }];
}


/**
 获取视频的 某一帧

 @param currentTime 某一时刻
 @param path 视频路径
 @return return 返回image
 */
- (UIImage *)getVideoImageWithTime:(Float64)currentTime videoPath:(NSURL *)path {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
//        float fps = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
//        NSLog(@"视频帧率%f",fps);
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        gen.requestedTimeToleranceAfter = kCMTimeZero;// 精确提取某一帧,需要这样处理
        gen.requestedTimeToleranceBefore = kCMTimeZero;// 精确提取某一帧,需要这样处理
    
        CMTime time = CMTimeMakeWithSeconds(currentTime, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *img = [[UIImage alloc] initWithCGImage:image];
        CMTimeShow(actualTime);
        CGImageRelease(image);
        return img;
}

/**
 获取沙盒路径

 @param key eg. im.jpg vo.mov
 @return 返回路径
 */
- (NSString *)getFilePathWithKey:(NSString *)key {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = paths.firstObject;
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (NSString *)originVideoPath {
    if (_originVideoPath == nil) {
        _originVideoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    }
    return _originVideoPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
