//
//  ViewController.m
//  NNLearnOpenGLES06
//
//  Created by 刘朋坤 on 2018/7/28.
//  Copyright © 2018年 刘朋坤. All rights reserved.
//

#import "ViewController.h"
#import "NNView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[[NNView alloc] initWithFrame:CGRectMake(100, 200, 100, 100)]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
