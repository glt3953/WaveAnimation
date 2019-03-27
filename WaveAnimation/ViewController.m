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

@property (nonatomic, strong) YSWaterWaveView *waterWaveView;
@property (nonatomic, strong) NSTimer *timerForRefresh;

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
    _waterWaveView = [[YSWaterWaveView alloc] initWithFrame:frame];
    _waterWaveView.layer.cornerRadius = 8;
    _waterWaveView.clipsToBounds = YES;
    [self.view addSubview:_waterWaveView];
    [_waterWaveView startWaveToPercent:0.5];

    //开启定时器刷新
    self.timerForRefresh = [NSTimer timerWithTimeInterval:0.8
                                                     target:self
                                                   selector:@selector(refreshWaveTimer:)
                                                   userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timerForRefresh forMode:NSRunLoopCommonModes];
}

- (void)refreshWaveTimer:(NSTimer *)timer {
    [_waterWaveView refreshWaveAmplitude:rand() / (double)(RAND_MAX / 30)];
}

@end
