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

@interface PatchManager : NSObject
-(Boolean)needUpdate;
-(NSInteger)currentVersion;
-(void)loadJSPatch;
-(void)EvaluateScript;
@end
