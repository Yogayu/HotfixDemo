//
//  PatchManager.h
//  HotfixDemo
//
//  Created by youxinyu on 16/8/18.
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "JPEngine.h"

const static NSString *rootUrl = @"http://127.0.0.1:5000";

@interface PatchManager : NSObject
- (void)run;
- (void)runScript;
- (NSString *)fileMD5:(NSString *)filePath;
- (void)runTestScriptInBundle;
- (void)update:(NSInteger)version patchURL:(NSURL*)patchURL;
- (NSInteger)currentVersion;
@end
