//
//  FrameView.m
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/16.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "FrameView.h"
#import <QuartzCore/QuartzCore.h>
@interface FrameView ()
@property (weak, nonatomic) IBOutlet UIImageView *frameImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

@end

@implementation FrameView

+ (id)frameViewWithFrame:(CGRect)frame {
    NSString * className = NSStringFromClass([self class]);
    UINib * nib = [UINib nibWithNibName:className bundle:nil];
    FrameView * view = [nib instantiateWithOwner:nil options:nil].firstObject;
    view.frame = frame;
    return view;
}

- (void)updateImage:(UIImage *)image currentTime:(NSString *)timeStr {
    if (image) {
        self.frameImageView.image = image;
    }
    if (timeStr.length) {
        self.currentTimeLabel.text = timeStr;
    }
}
- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    if (self.selectBlock && self.frameImageView.image) {
        self.selectBlock(self.frameImageView.image);
    }
}

- (void)changeAlertLabelStart:(BOOL)isStart {
    if (isStart == YES) {
        //开始动画
        self.alertLabel.hidden = NO;
        [self.alertLabel.layer addAnimation:[self alphaLight] forKey:@"Alpha"];
    } else {
        //消失动画
        self.alertLabel.hidden = YES;
        [self.alertLabel.layer removeAnimationForKey:@"Alpha"];
    }
}

/**
 呼吸光动画
 @return 动画
 */
- (CABasicAnimation *)alphaLight {
    CABasicAnimation * baseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    baseAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    baseAnimation.toValue = [NSNumber numberWithFloat:1.0];
    baseAnimation.autoreverses = YES;
    baseAnimation.duration = 1.5;
    baseAnimation.repeatCount = MAXFLOAT;
    baseAnimation.removedOnCompletion = NO;
    baseAnimation.fillMode = kCAFillModeForwards;
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return baseAnimation;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
