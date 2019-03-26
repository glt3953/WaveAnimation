//
//  ViewController.m
//  WaveAnimation
//
//  Created by Dustin on 17/4/1.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import "ViewController.h"
#import "WaveView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat originX = 20;
    WaveView *waveView = [[WaveView alloc] initWithFrame:CGRectMake(originX, (self.view.frame.size.height-self.view.frame.size.width/2)/2, self.view.frame.size.width - 2 * originX, self.view.frame.size.width/2)];
    waveView.layer.cornerRadius = 8;
    [self.view addSubview:waveView];
}

@end
