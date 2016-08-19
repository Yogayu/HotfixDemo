//
//  PatchManager.m
//  HotfixDemo
//
//  Created by youxinyu on 16/8/18.
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

#import "PatchManager.h"

@implementation PatchManager

#define FilePath ([[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil])
#define kJSPatchVersion(appVersion)   [NSString stringWithFormat:@"JSPatchVersion_%@", appVersion]

-(Boolean)needUpdate
{
  BOOL patchEnable = YES;
  BOOL isUpdate = YES;
  NSInteger minVersion = 0.0;
  NSInteger newVersion = 1.0;
  NSInteger *currentVersion = [self currentVersion];
//  http://127.0.0.1:5000/v2/fm/get_ios_patch
//  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//  [manager GET:@"https://raw.githubusercontent.com/yxytoday/demo/master/demo" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    
//  } failure:^(NSURLSessionTask *operation, NSError *error) {
//    NSLog(@"Error: %@", error);
//  
//  }];
  
  NSURL *URL = [NSURL URLWithString:@"https://raw.githubusercontent.com/yxytoday/demo/master/demo.json"];
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
  } failure:^(NSURLSessionTask *operation, NSError *error) {
    NSLog(@"Error: %@", error);
  }];
  
  
  
  return false;
}

-(void)loadJSPatch
{
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  NSURL *URL = [NSURL URLWithString:@"https://raw.githubusercontent.com/Yogayu/iOSYoga/master/hotfix_demo.js"];
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
    {
      NSURL *documentsDirectoryURL = FilePath;
      return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    }
      completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
    {
      NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}

-(void)EvaluateScript
{
  NSURL *p = FilePath;
  NSString *jsFile = [NSString stringWithContentsOfFile:[p.path stringByAppendingString:@"/hotfix_demo.js"] encoding:NSUTF8StringEncoding error:nil];

  if (jsFile.length > 0)
  {
    // TODO: decode the js content
    
    // run
    [JPEngine startEngine];
    [JPEngine evaluateScript:jsFile];
  }
}

- (NSInteger)currentVersion
{
  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  return [[NSUserDefaults standardUserDefaults] integerForKey:kJSPatchVersion(appVersion)];
}

@end
