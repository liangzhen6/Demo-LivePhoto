//
//  JPEG.h
//  LivePhoto
//
//  Created by shenzhenshihua on 2018/5/15.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPEG : NSObject

- (id)initWithPath:(NSString *)path;

- (void)writeDest:(NSString *)dest assetIdentifier:(NSString *)assetIdentifier result:(void(^)(BOOL res))result;

@end
