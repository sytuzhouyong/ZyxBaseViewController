//
//  ViewController.m
//  TestZyxBaseVC
//
//  Created by zhouyong on 16/3/29.
//  Copyright © 2016年 zhouyong. All rights reserved.
//

#import "ViewController.h"
#import "MacroDefine.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"TestVC";
    self.titleLabel.textColor = [UIColor redColor];
    self.titleView.backgroundColor = [UIColor orangeColor];
    [self createLeftBarButtonWithTitle:@"返回"];
    [self createRightBarButtonWithTitle:@"右边" action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
