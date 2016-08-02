//
//  YXYViewController.m
//  HotfixDemo
//
//  Created by youxinyu on 16/7/31.
//  Copyright © 2016年 yogayu.github.io. All rights reserved.
//

#import "YXYViewController.h"

@interface YXYViewController ()

@end

@implementation YXYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)setUI {
    UIButton *showRandomNumberBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 50)];
    [showRandomNumberBtn setTitle:@"Make RandomNumber" forState:UIControlStateNormal];
    [showRandomNumberBtn addTarget:self action:@selector(handleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [showRandomNumberBtn setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:showRandomNumberBtn];
}

- (IBAction)YXYMakeRandomNumberBtn:(id)sender
{
    NSLog(@"origial yxy make random button");
}

- (void)handleBtn:(id)sender
{

}

@end
