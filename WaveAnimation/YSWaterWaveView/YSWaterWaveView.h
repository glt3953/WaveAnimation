//
//  YSWaterWaveView.h
//  Wave
//
//  Created by moshuqi on 16/1/7.
//  Copyright © 2016年 msq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSWaterWaveView : UIView

- (void)startWaveToPercent:(CGFloat)percent;
- (void)setGradientColors:(NSArray *)colors;    // 设置渐变色
- (void)refreshWaveAmplitude:(CGFloat)amplitude;

@end
