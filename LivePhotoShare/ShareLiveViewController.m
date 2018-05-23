//
//  ShareLiveViewController.m
//  LivePhotoShare
//
//  Created by shenzhenshihua on 2018/5/21.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "ShareLiveViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ShareLiveViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property(nonatomic,copy)NSString *lastAppending;
@end

@implementation ShareLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof (self) ws = self;
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.attachments enumerateObjectsUsingBlock:^(NSItemProvider *  _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:itemProvider.registeredTypeIdentifiers[0]]) {
                [itemProvider loadItemForTypeIdentifier:itemProvider.registeredTypeIdentifiers[0] options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    NSLog(@"%@",item);
                    if ([(NSObject *)item isKindOfClass:[NSURL class]]) {
                        NSString * lastAppending = [[[(NSURL*)item absoluteString] componentsSeparatedByString:@"/"] lastObject];
                        NSFileManager *fileManger = [NSFileManager defaultManager];
                        NSURL *groupFile = [fileManger containerURLForSecurityApplicationGroupIdentifier:@"group.com.livephoto"];
                        NSURL *fileUrl = [groupFile URLByAppendingPathComponent:lastAppending];
                        //移除旧的数据
                        [fileManger removeItemAtURL:fileUrl error:nil];
                        NSError *error = nil;
                        [fileManger copyItemAtURL:(NSURL *)item toURL:fileUrl error:&error];
                        if (!error) {
                            ws.lastAppending = lastAppending;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [ws initVideoWithPath:fileUrl];
                            });
                            NSLog(@"存入成功！！！");
                        }
                    }
                }];
                *stop = YES;
            }
        }];
        *stop = YES;
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)initVideoWithPath:(NSURL *)pathUrl {
    AVPlayer * player = [[AVPlayer alloc] initWithURL:pathUrl];
    AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.videoView.bounds;
    [self.videoView.layer addSublayer:playerLayer];
    [player play];
}

- (IBAction)cancelAction:(UIButton *)sender {
     [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"CustomShareError" code:NSUserCancelledError userInfo:nil]];
}
- (IBAction)handleVideo:(UIButton *)sender {
    UIResponder *responder = self;
    while (responder) {
        if ([responder respondsToSelector:@selector(openURL:)]) {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:[NSString stringWithFormat:@"livePhoto://data=%@",_lastAppending]]];
            break;
        }
        responder = [responder nextResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
