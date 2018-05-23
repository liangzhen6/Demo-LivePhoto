//
//  PhotoLibrary.h
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/23.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
typedef void(^ResultBlock)(NSURL *path, BOOL success);
@interface PhotoLibrary : NSObject<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
+ (id)sharePhotoLibrary;

+ (void)getlibraryAuthorization;

+ (BOOL)photoLibraryIsAuth;

+ (void)writeLivePhotoWithVideo:(NSURL *)videoPath image:(NSURL *)imagePath result:(void(^)(BOOL res))result;

- (void)chooseVideoFromPhotoLibraryResult:(ResultBlock)result;
@end
