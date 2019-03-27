//
//  ViewController.m
//  WaveAnimation
//
//  Created by Dustin on 17/4/1.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import "ViewController.h"
#import "WaveView.h"
#import "YSWaterWaveView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat originX = 20;
    CGFloat originY = 20 + 44 + 20;
    WaveView *waveView = [[WaveView alloc] initWithFrame:CGRectMake(originX, originY, self.view.frame.size.width - 2 * originX, self.view.frame.size.width/2)];
    waveView.layer.cornerRadius = 8;
    [self.view addSubview:waveView];
    
    CGRect frame = waveView.frame;
    frame.origin.y += frame.size.height + 50;
    YSWaterWaveView *waterWaveView = [[YSWaterWaveView alloc] initWithFrame:frame];
    waterWaveView.layer.cornerRadius = 8;
    waterWaveView.clipsToBounds = YES;
    [self.view addSubview:waterWaveView];
    [waterWaveView startWaveToPercent:0.3];
//    [waterWaveView setGrowthSpeed:0.1];
}

@end
