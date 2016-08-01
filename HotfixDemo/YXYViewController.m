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
- (void)viewWillAppear:(BOOL)animated {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 50)];
    [btn setTitle:@"Push JPTableViewController" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(YXYhandleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor brownColor]];
    [self.view addSubview:btn];
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

IBOutlet UILabel *numberLabel;

- (IBAction)YXYMakeRandomNumberBtn:(id)sender
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
