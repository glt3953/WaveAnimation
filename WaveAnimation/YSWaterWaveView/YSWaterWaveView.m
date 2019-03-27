//
//  YSWaterWaveView.m
//  Wave
//
//  Created by moshuqi on 16/1/7.
//  Copyright © 2016年 msq. All rights reserved.
//

#import "YSWaterWaveView.h"

@interface YSWaterWaveView ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CAShapeLayer *firstWaveLayer;  // 绘制波形
@property (nonatomic, strong) CAGradientLayer *firstGradientLayer;   // 绘制渐变
@property (nonatomic, strong) CAShapeLayer *secondWaveLayer;  // 绘制波形
@property (nonatomic, strong) CAGradientLayer *secondGradientLayer;   // 绘制渐变
@property (nonatomic, strong) NSArray *colors;  // 渐变的颜色数组
@property (nonatomic, assign) CGFloat percent;  // 波浪上升的比例
// 绘制波形的变量定义，使用波形曲线y=Asin(ωx+φ)+k进行绘制
@property (nonatomic, assign) CGFloat waveAmplitudeA;  // 波纹振幅，A
@property (nonatomic, assign) CGFloat waveAmplitudeB;  // 波纹振幅，B
@property (nonatomic, assign) CGFloat waveCycle;      // 波纹周期，T = 2π/ω
@property (nonatomic, assign) CGFloat offsetXA;        // 波浪x位移，φ
@property (nonatomic, assign) CGFloat offsetXB;        // 波浪x位移，φ
@property (nonatomic, assign) CGFloat waveSpeedA;      // 波纹速度，用来累加到相位φ上，达到波纹水平移动的效果
@property (nonatomic, assign) CGFloat waveSpeedB;      // 波纹速度，用来累加到相位φ上，达到波纹水平移动的效果
@property (nonatomic, assign) CGFloat currentWavePointY;    // 当前波浪高度，k

@end

@implementation YSWaterWaveView

static const CGFloat kExtraHeight = 20;     // 保证水波波峰不被裁剪，增加部分额外的高度

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfig];
        
        self.backgroundColor = [self colorFromHexString:@"#1A1E33" alpha:0.75];
    }
    
    return self;
}

- (UIColor *)colorFromHexString:(NSString *)hexString alpha:(float)alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

- (void)setGradientColors:(NSArray *)colors {
    // 必须保证传进来的参数为UIColor*的数组
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor *color in colors) {
        [array addObject:(__bridge id)color.CGColor];
    }
    
    self.colors = array;
}

- (void)setColorsWithArray:(NSArray *)colors {
    self.colors = colors;
}

- (void)defaultConfig {
    // 默认设置一些属性
//    self.waveCycle = 1.66 * M_PI / CGRectGetWidth(self.frame);     // 影响波长
    //设置周期影响参数，2π/waveCycle是一个周期
    self.waveCycle = 1/30.0;
    self.currentWavePointY = CGRectGetHeight(self.frame) * self.percent;       // 波纹从下往上升起
    self.waveSpeedA = 0.2;
    self.waveSpeedB = 0.1;
    self.waveAmplitudeA = 10;
    self.waveAmplitudeB = 15;
    self.offsetXA = 0;
    self.offsetXB = 1;
}

- (void)resetProperty {
    // 重置属性
    self.currentWavePointY = CGRectGetHeight(self.frame) * self.percent;
}

- (void)resetFirstWaveLayer {
    // 动画开始之前重置layer
    if (self.firstWaveLayer) {
        [self.firstWaveLayer removeFromSuperlayer];
        self.firstWaveLayer = nil;
    }
    self.firstWaveLayer = [CAShapeLayer layer];
    self.firstWaveLayer.fillColor = [self colorFromHexString:@"#4DA6FF" alpha:0.6].CGColor;
    
    // 设置渐变
    if (self.firstGradientLayer) {
        [self.firstGradientLayer removeFromSuperlayer];
        self.firstGradientLayer = nil;
    }
    self.firstGradientLayer = [CAGradientLayer layer];
    self.firstGradientLayer.frame = [self gradientLayerFrame];
    [self setupGradientColor];
    [self.firstGradientLayer setMask:self.firstWaveLayer];
    [self.layer addSublayer:self.firstGradientLayer];
}

- (void)resetSecondWaveLayer {
    // 动画开始之前重置layer
    if (self.secondWaveLayer) {
        [self.secondWaveLayer removeFromSuperlayer];
        self.secondWaveLayer = nil;
    }
    self.secondWaveLayer = [CAShapeLayer layer];
    self.secondWaveLayer.fillColor = [self colorFromHexString:@"#4DC3FF" alpha:0.4].CGColor;
    
    // 设置渐变
    if (self.secondGradientLayer) {
        [self.secondGradientLayer removeFromSuperlayer];
        self.secondGradientLayer = nil;
    }
    self.secondGradientLayer = [CAGradientLayer layer];
    self.secondGradientLayer.frame = [self gradientLayerFrame];
    [self setupGradientColor];
    [self.secondGradientLayer setMask:self.secondWaveLayer];
    [self.layer addSublayer:self.secondGradientLayer];
}

- (void)setupGradientColor {
    NSArray *colorsA = @[(__bridge id)[self colorFromHexString:@"#4DE1FF" alpha:0.5].CGColor, (__bridge id)[self colorFromHexString:@"#4DC3FF" alpha:0.3].CGColor, (__bridge id)[self colorFromHexString:@"#4DA6FF" alpha:0.1].CGColor];
    NSArray *colorsB = @[(__bridge id)[self colorFromHexString:@"#4DA6FF" alpha:0.5].CGColor, (__bridge id)[self colorFromHexString:@"#4DC3FF" alpha:0.3].CGColor, (__bridge id)[self colorFromHexString:@"#4DE1FF" alpha:0.1].CGColor];
    self.firstGradientLayer.colors = colorsA;
    self.secondGradientLayer.colors = colorsB;
    
    //设定颜色分割点
    NSInteger count = [colorsA count];
    CGFloat d = 1.0 / count;
    
    NSMutableArray *locations = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        NSNumber *num = @(d + d * i);
        [locations addObject:num];
    }
    NSNumber *lastNum = @(1.0f);
    [locations addObject:lastNum];
    
    self.firstGradientLayer.locations = locations;
    self.secondGradientLayer.locations = locations;
    
    // 设置渐变方向，从上往下
    self.firstGradientLayer.startPoint = CGPointMake(0, 0);
    self.firstGradientLayer.endPoint = CGPointMake(0, 1);
    
    self.secondGradientLayer.startPoint = CGPointMake(0, 0);
    self.secondGradientLayer.endPoint = CGPointMake(0, 1);
}

- (CGRect)gradientLayerFrame {
    // firstGradientLayer在上升完成之后的frame值，如果firstGradientLayer在上升过程中不断变化frame值会导致一开始绘制卡顿，所以只进行一次赋值
    
    CGFloat gradientLayerHeight = CGRectGetHeight(self.frame) * self.percent + kExtraHeight;
    
    if (gradientLayerHeight > CGRectGetHeight(self.frame)) {
        gradientLayerHeight = CGRectGetHeight(self.frame);
    }
    
    CGRect frame = CGRectMake(0, CGRectGetHeight(self.frame) - gradientLayerHeight, CGRectGetWidth(self.frame), gradientLayerHeight);
    
    return frame;
}

- (void)startWaveToPercent:(CGFloat)percent {
    self.percent = percent;
    
    [self resetProperty];
    [self resetFirstWaveLayer];
    [self resetSecondWaveLayer];
    
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
    // 启动同步渲染绘制波纹
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setCurrentWave:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setCurrentWave:(CADisplayLink *)displayLink {
    self.offsetXA += self.waveSpeedA;
    [self setFirstWaveLayerPath];
    
    self.offsetXB += self.waveSpeedB;
    [self setSecondWaveLayerPath];
}

- (void)setFirstWaveLayerPath {
    // 通过正弦曲线来绘制波浪形状
    CGMutablePathRef pathA = CGPathCreateMutable();
    CGFloat y = self.currentWavePointY;
    
    CGPathMoveToPoint(pathA, nil, 0, y);
    CGFloat width = CGRectGetWidth(self.frame);
    for (float x = 0.0f; x <= width; x++) {
        // 正弦波浪公式
        y = self.waveAmplitudeA * sin(self.waveCycle * x + self.offsetXA) + self.currentWavePointY  / 2;
        CGPathAddLineToPoint(pathA, nil, x, y);
    }
    
    CGPathAddLineToPoint(pathA, nil, width, CGRectGetHeight(self.frame));
    CGPathAddLineToPoint(pathA, nil, 0, CGRectGetHeight(self.frame));
    CGPathCloseSubpath(pathA);
    
    self.firstWaveLayer.path = pathA;
    CGPathRelease(pathA);
}

- (void)setSecondWaveLayerPath {
    // 通过正弦曲线来绘制波浪形状
    CGMutablePathRef pathB = CGPathCreateMutable();
    CGFloat y = self.currentWavePointY;
    
    CGPathMoveToPoint(pathB, nil, 0, y);
    CGFloat width = CGRectGetWidth(self.frame);
    for (float x = 0.0f; x <= width; x++) {
        // 正弦波浪公式
        y = self.waveAmplitudeB * sin(self.waveCycle * x + self.offsetXB) + self.currentWavePointY  / 3;
        CGPathAddLineToPoint(pathB, nil, x, y);
    }
    
    CGPathAddLineToPoint(pathB, nil, width, CGRectGetHeight(self.frame));
    CGPathAddLineToPoint(pathB, nil, 0, CGRectGetHeight(self.frame));
    CGPathCloseSubpath(pathB);
    
    self.secondWaveLayer.path = pathB;
    CGPathRelease(pathB);
}

@end
