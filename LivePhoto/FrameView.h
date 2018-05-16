//
//  FrameView.h
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/16.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectImageBlock)(UIImage *image);

@interface FrameView : UIView
@property(nonatomic,copy)SelectImageBlock selectBlock;

+ (id)frameViewWithFrame:(CGRect)frame;

- (void)updateImage:(UIImage *)image currentTime:(NSString *)timeStr;

- (void)changeAlertLabelStart:(BOOL)isStart;

@end
