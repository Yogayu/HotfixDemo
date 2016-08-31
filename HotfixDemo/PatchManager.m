//
//  PatchManager.m
//  HotfixDemo
//
//  Created by youxinyu on 16/8/18.
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

#import "PatchManager.h"
#import <CommonCrypto/CommonDigest.h>

#define kJSPatchVersion(appVersion)   [NSString stringWithFormat:@"JSPatchVersion_%@", appVersion]
#define FilePath ([[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil])

@implementation PatchManager
/**
 *  如果patch开启并且更新了，那么就run新的patch script
 *  存在着哪一些意外情况？
 */
- (void)run
{
  BOOL patchEnable = YES;
  NSInteger minVersion = 0.0;
  NSInteger newVersion = 5.0;
  NSInteger currentVersion = [self currentVersion];
  
  if (patchEnable) {
    if (currentVersion < newVersion) {
      
      NSURL *patchURL = [NSURL URLWithString:@"https://raw.githubusercontent.com/yxytoday/demo/master/main.js"];
      [self update:newVersion patchURL:patchURL];
      
    } else if (currentVersion > minVersion) {
      [self runScript];
    }
  }
}

- (void) update:(NSInteger)version patchURL:(NSURL *)patchURL
{
  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  NSURL *URL = patchURL;
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  
  NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
      {
        NSURL *documentsDirectoryURL = FilePath;
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
      }
      completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error){
      if (!error) {
        /*
        NSLog(@"File downloaded to: %@", filePath);
        NSString *md5 = [self fileMD5:FilePath];
        NSString *decryptMD5 = @"sifjiskadsvioasdfu0293rkdsjf";
        
        if (![decryptMD5 isEqualToString:md5]) {
        
        }
        
        [self runScript];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0.0 forKey:kJSPatchVersion(appVersion)];
        [[NSUserDefaults standardUserDefaults] synchronize];
        */
      } else {
        
      }
  }];
  
  [downloadTask resume];
  
}

- (void)runScript
{
  NSURL *p = FilePath;
  NSString *script = [NSString stringWithContentsOfFile:[p.path stringByAppendingString:@"/main.js"] encoding:NSUTF8StringEncoding error:nil];
  
  if (script.length > 0)
  {
    // TODO: decode the js content
    
    [JPEngine startEngine];
    [JPEngine evaluateScript:script];
  }
}

- (NSInteger)currentVersion
{
  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  return [[NSUserDefaults standardUserDefaults] integerForKey:kJSPatchVersion(appVersion)];
}

- (void)runTestScriptInBundle
{
  [JPEngine startEngine];
  
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"test" ofType:@"js"];
  NSAssert(path, @"can't find test.js");
  NSString *script = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
  [JPEngine evaluateScript:script];
}

#pragma mark utils

- (NSString *)fileMD5:(NSString *)filePath
{
  NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
  if(!handle)
  {
    return nil;
  }
  
  CC_MD5_CTX md5;
  CC_MD5_Init(&md5);
  BOOL done = NO;
  while (!done)
  {
    NSData *fileData = [handle readDataOfLength:256];
    CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
    if([fileData length] == 0)
      done = YES;
  }
  
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  CC_MD5_Final(digest, &md5);
  
  NSString *result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                      digest[0], digest[1],
                      digest[2], digest[3],
                      digest[4], digest[5],
                      digest[6], digest[7],
                      digest[8], digest[9],
                      digest[10], digest[11],
                      digest[12], digest[13],
                      digest[14], digest[15]];
  return result;
}

@end
