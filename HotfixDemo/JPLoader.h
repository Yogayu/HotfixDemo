//
//  JPLoader.h
//  HotfixDemo
//
//  Created by youxinyu on 16/8/29.
//  modified form JPLoader
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

#import <Foundation/Foundation.h>

//const static NSString *rootUrl = @"https://img3.doubanio.com/dae/fm/ios_patchs";

typedef void (^JPUpdateCallback)(NSError *error);

typedef enum {
  JPUpdateErrorVerifyFailed = -1002,
} JPUpdateError;

@interface JPLoader : NSObject
+ (void)runPatch;
+ (BOOL)runScript;
+ (void)updateToVersion:(NSInteger)version patchURL:(NSURL *)patchURL fileMD5: (NSString*)fileMD5 callback:(JPUpdateCallback)callback;
+ (void)runTestScriptInBundle;
+ (void)setLogger:(void(^)(NSString *log))logger;
+ (NSInteger)currentVersion;
@end
