//
//  PhotoLibrary.m
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/23.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "PhotoLibrary.h"
@interface PhotoLibrary ()
@property(nonatomic,copy)ResultBlock result;
@end
static PhotoLibrary * _photoLibrary = nil;

@implementation PhotoLibrary
+ (id)sharePhotoLibrary {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_photoLibrary == nil) {
            _photoLibrary = [[PhotoLibrary alloc] init];
        }
    });
    return _photoLibrary;
}
+ (void)getlibraryAuthorization {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
    }];
}

+ (BOOL)photoLibraryIsAuth {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)writeLivePhotoWithVideo:(NSURL *)videoPath image:(NSURL *)imagePath result:(void(^)(BOOL res))result {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest * request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypePhoto fileURL:imagePath options:nil];
        [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:videoPath options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //保存成功
            NSLog(@"保存成功");
        }
        if (result) {
            result(success);
        }
    }];
}

- (void)chooseVideoFromPhotoLibraryResult:(ResultBlock)result {
    UIImagePickerController *imagePick = [[UIImagePickerController alloc] init];
    imagePick.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePick.mediaTypes = @[@"public.movie"];//只获取视频数据
    imagePick.delegate = self;
    self.result = result;
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:imagePick animated:YES completion:nil];
}
// UIImagePickerController 的选择结果的代理方法。
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([[info[@"UIImagePickerControllerMediaURL"] absoluteString] length]) {
        if (self.result) {
            self.result(info[@"UIImagePickerControllerMediaURL"], YES);
        }
    }
}

@end
