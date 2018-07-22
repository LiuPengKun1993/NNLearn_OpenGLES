//
//  ViewController.m
//  NNLearn_OpenGLES_RoundPoint
//
//  Created by liupengkun on 2018/7/21.
//  Copyright © 2018年 以梦为马. All rights reserved.
//

#import "ViewController.h"
#import "NNView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:[[NNView alloc] initWithFrame:self.view.bounds]];
}

@end
