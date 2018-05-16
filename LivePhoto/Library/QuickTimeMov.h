//
//  QuickTimeMov.h
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/15.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickTimeMov : NSObject
- (id)initWithPath:(NSString *)path;

- (void)write:(NSString *)dest assetIdentifier:(NSString *)assetIdentifier result:(void(^)(BOOL res))result;
@end
