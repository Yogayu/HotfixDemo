//
//  JPLoader.m
//  HotfixDemo
//
//  Created by youxinyu on 16/8/29.
//  modified form JPLoader
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

#import "JPLoader.h"
#import "JPEngine.h"
#import <CommonCrypto/CommonDigest.h>

#define MinVersion -1
#define kJSPatchVersion(appVersion)   [NSString stringWithFormat:@"JSPatchVersion_%@", appVersion]
#define kJSPatchEnabled(appVersion)   [NSString stringWithFormat:@"JSPatchEnabled_%@", appVersion]

void (^JPLogger)(NSString *log);

#pragma mark - Extension

@interface JPLoaderInclude : JPExtension

@end

@implementation JPLoaderInclude

+ (void)main:(JSContext *)context
{
  context[@"include"] = ^(NSString *filePath) {
    if (!filePath.length || [filePath rangeOfString:@".js"].location == NSNotFound) {
      return;
    }
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *scriptPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"JSPatch/%@/%@", appVersion, filePath]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
      [JPEngine startEngine];
      [JPEngine evaluateScriptWithPath:scriptPath];
    }
  };
}

@end

@interface JPLoaderTestInclude : JPExtension

@end

@implementation JPLoaderTestInclude

+ (void)main:(JSContext *)context
{
  context[@"include"] = ^(NSString *filePath) {
    NSArray *component = [filePath componentsSeparatedByString:@"."];
    if (component.count > 1) {
      NSString *testPath = [[NSBundle bundleForClass:[self class]] pathForResource:component[0] ofType:component[1]];
      [JPEngine evaluateScriptWithPath:testPath];
    }
  };
}

@end

#pragma mark - Loader

@implementation JPLoader

+ (void)runPatch
{
  NSInteger currentVersion = [self currentVersion];
  __block BOOL patchEnabled = [self isPatchEnabled];
  
  NSURL *downloadURL = [NSURL URLWithString:@"https://api.douban.com/v2/fm/get_ios_patch"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
  [request setHTTPMethod:@"POST"];
  
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse *response, NSError *error) {
    if (!error) {
      
      NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
      NSDictionary *patch_info = dic[@"patch"];
      NSString *downloadURL = patch_info[@"download_url"];
      NSString *md5 = patch_info[@"md5"];
      NSInteger newVersion = [patch_info[@"version"] integerValue];
      
      if ((patchEnabled = dic[@"patch_enabled"])) {
        if (currentVersion < newVersion) {
          
          NSURL *patchURL = [NSURL URLWithString:downloadURL];
          [self updateToVersion:newVersion patchURL:patchURL fileMD5: md5 callback:^(NSError *error) {
            if (!error){
              [self runScript];
            }
          }];
          
        } else if (currentVersion > MinVersion) {
          [self runScript];
        }
        
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [[NSUserDefaults standardUserDefaults] setBool:patchEnabled forKey:kJSPatchEnabled(appVersion)];
        [[NSUserDefaults standardUserDefaults] synchronize];
      }
      
    } else {
      
      if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: request error %@", error]);
      if (patchEnabled) {
        [self runScript];
      }
    }
    
  }];
  [task resume];
}

+ (BOOL)runScript
{
  if (JPLogger) JPLogger(@"JSPatch: runScript");
  
  NSString *scriptDirectory = [self fetchScriptDirectory];
  NSString *scriptPath = [scriptDirectory stringByAppendingPathComponent:@"main.js"];
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
    [JPEngine startEngine];
    [JPEngine addExtensions:@[@"JPLoaderInclude"]];
    [JPEngine evaluateScriptWithPath:scriptPath];
    if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: evaluated script %@", scriptPath]);
    return YES;
  } else {
    return NO;
  }
}

+ (void)updateToVersion:(NSInteger)version patchURL:(NSURL *)patchURL fileMD5: (NSString*)fileMD5 callback:(JPUpdateCallback)callback
{
  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  
  if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: updateToVersion: %@", @(version)]);
  
  NSURL *downloadURL = patchURL;
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
  [request setHTTPMethod:@"POST"];
  
  if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: request file %@", downloadURL]);
  
  NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (!error) {
      if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: request file success, data length:%@", @(data.length)]);
      
      NSString *scriptDirectory = [self fetchScriptDirectory];
      
      // 1 Download
      NSString *downloadTmpPath = [NSString stringWithFormat:@"%@patch_%@_%@.js", NSTemporaryDirectory(), appVersion, @(version)];
      [data writeToFile:downloadTmpPath atomically:YES];
      
      BOOL isFailed = NO;
      
      // 2 Verify md5 file
      if (!isFailed) {
        NSString *md5 = [self fileMD5:downloadTmpPath];
        
        if (![fileMD5 isEqualToString:md5]) {
          if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: decompress error, md5 didn't match, decrypt:%@ md5:%@", fileMD5, md5]);
          isFailed = YES;
          
          if (callback) {
            callback([NSError errorWithDomain:@"org.jspatch" code:JPUpdateErrorVerifyFailed userInfo:nil]);
          }
        }
      }
      
      // 3 Save
      if (!isFailed) {
        NSString *filePath = downloadTmpPath;
        NSString *filename = @"main.js";
        if ([[filename pathExtension] isEqualToString:@"js"]) {
          [[NSFileManager defaultManager] createDirectoryAtPath:scriptDirectory withIntermediateDirectories:YES attributes:nil error:nil];
          NSString *newFilePath = [scriptDirectory stringByAppendingPathComponent:filename];
          [[NSData dataWithContentsOfFile:filePath] writeToFile:newFilePath atomically:YES];
        }
      }
      
      // 4 Success
      if (!isFailed) {
        if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: updateToVersion: %@ success", @(version)]);
        
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:kJSPatchVersion(appVersion)];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (callback) callback(nil);
      }
      
      [[NSFileManager defaultManager] removeItemAtPath:downloadTmpPath error:nil];
      
    } else {
      if (JPLogger) JPLogger([NSString stringWithFormat:@"JSPatch: request error %@", error]);
      
      if (callback) callback(error);
    }
    
  }];
  
  [task resume];
}

/**
 *  local test
 */
+ (void)runTestScriptInBundle
{
  [JPEngine startEngine];
  [JPEngine addExtensions:@[@"JPLoaderTestInclude"]];
  
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"main" ofType:@"js"];
  NSAssert(path, @"can't find main.js");
  NSString *script = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
  [JPEngine evaluateScript:script];
}

+ (void)setLogger:(void (^)(NSString *))logger {
  JPLogger = [logger copy];
}

+ (BOOL)isPatchEnabled
{
  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  return [[NSUserDefaults standardUserDefaults] boolForKey:kJSPatchEnabled(appVersion)];
}

+ (NSInteger)currentVersion
{
  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  return [[NSUserDefaults standardUserDefaults] integerForKey:kJSPatchVersion(appVersion)];
}

+ (NSString *)fetchScriptDirectory
{
  NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
  NSString *scriptDirectory = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"JSPatch/%@/", appVersion]];
  return scriptDirectory;
}

#pragma mark utils

+ (NSString *)fileMD5:(NSString *)filePath
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