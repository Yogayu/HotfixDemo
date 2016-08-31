//
//  PatchInfo.h
//  HotfixDemo
//
//  Created by youxinyu on 16/8/30.
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

@import Foundation;

@interface PatchInfo : NSObject

@property (nonatomic) NSString *downloadURL;
@property (nonatomic) NSString *md5;
@property (nonatomic) NSInteger version;
@property (nonatomic) BOOL patchEnable;

@end
