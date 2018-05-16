//
//  JPEG.m
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/15.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "JPEG.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
static NSString * const kFigAppleMakerNote_AssetIdentifier = @"17";

@interface JPEG ()
@property(nonatomic,copy)NSString *path;

@end

@implementation JPEG

- (id)initWithPath:(NSString *)path {
    if (self = [super init]) {
        self.path = path;
    }
    return self;
}

- (NSString *)read {
    NSDictionary *met = [self metadata];
    if (!met) {
        return nil;
    }
    NSDictionary *dict = [met objectForKey:(__bridge NSString *)kCGImagePropertyMakerAppleDictionary];
    NSString *str = [dict objectForKey:kFigAppleMakerNote_AssetIdentifier];
    return str;
}

- (void)writeDest:(NSString *)dest assetIdentifier:(NSString *)assetIdentifier result:(void(^)(BOOL res))result {
    CGImageDestinationRef ref = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:dest], kUTTypeJPEG, 1, nil);
    if (!ref) {
        if (result) {
            result(NO);
        }
        return;
    }
    CGImageSourceRef imageSource = [self imageSource];
    if (!imageSource) {
        if (result) {
            result(NO);
        }
        return;
    }
    NSMutableDictionary * metadata = [[self metadata] mutableCopy];
    if (!metadata) {
        if (result) {
            result(NO);
        }
        return;
    }
    //存储image
    NSMutableDictionary * makerNote = [[NSMutableDictionary alloc] init];
    [makerNote setObject:assetIdentifier forKey:kFigAppleMakerNote_AssetIdentifier];
    [metadata setObject:makerNote forKey:(__bridge NSString *)kCGImagePropertyMakerAppleDictionary];
    //存储图片 并设置一些属性
    CGImageDestinationAddImageFromSource(ref, imageSource, 0, (__bridge CFDictionaryRef)metadata);
    CFRelease(imageSource);
    CGImageDestinationFinalize(ref);
    if (result) {
        result(YES);
    }
}

- (NSDictionary *)metadata {
    CGImageSourceRef ref = [self imageSource];
    NSDictionary * dict = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(ref, 0, nil));
    CFRelease(ref);
    return dict;
}

- (CGImageSourceRef)imageSource {
    return CGImageSourceCreateWithData((__bridge CFDataRef)[self data], nil);
}

- (NSData *)data {
    return [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.path]];
}

@end
