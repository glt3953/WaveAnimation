//
//  WaveView.m
//  WaveAnimation
//
//  Created by Dustin on 17/4/1.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import "WaveView.h"
#import "UIColor+NingXia.h"

@interface WaveView()

@property (nonatomic, strong) CADisplayLink *waveDisplaylink;
@property (nonatomic, strong) CAShapeLayer *firstWaveLayer; //一个本身没有形状的图层，他的形状来源于你给定的Path，它依附于Path
@property (nonatomic, strong) CAShapeLayer *secondWaveLayer;
@property (nonatomic, strong) CAShapeLayer *thirdWaveLayer;
@property (nonatomic, strong) CAGradientLayer *thirdGradientLayer;   // 绘制渐变
@property (nonatomic, copy) NSArray *wavesArray;

@end

@implementation WaveView
{
    CGFloat waveAmplitudeA;//第一个波浪图层的水纹振幅A
    CGFloat waveAmplitudeB;//第二个波浪图层的水纹振幅B
    CGFloat waveAmplitudeC;//第三个波浪图层的水纹振幅C
    CGFloat waveCycle;//水纹周期
    CGFloat offsetXA;//第一个波浪图层的位移A
    CGFloat offsetXB;//第二个波浪图层的位移B
    CGFloat offsetXC;//第三个波浪图层的位移C
    CGFloat currentK; //当前波浪高度Y
    CGFloat waveSpeedA;//第一个波浪图层的水纹速度A
    CGFloat waveSpeedB;//第二个波浪图层的水纹速度B
    CGFloat waveSpeedC;//第三个波浪图层的水纹速度C
    CGFloat waterWaveWidth; //水纹宽度
} //注：属性和基础变量都写在了自定义的WaveView的.m文件中，如果你想将它作为工具类，随时改变波纹的一些属性和变量，你可以将其暴露在头文件中，以便在需要引入它的地方方便修改。

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorFromHexString:@"#1A1E33" alpha:0.75];
        self.layer.masksToBounds  = YES;
        [self setUp];
        
//        _wavesArray = @[@{@"waveLayer":_firstWaveLayer, @"fillColor":[UIColor colorFromHexString:@"#4DE1FF" alpha:0.5], @"speed":@0.3, @"amplitude":@10, @"offsetX":@0}];
    }
    
    return self;
}

- (void)setUp {
    //设置波浪的宽度
    waterWaveWidth = self.frame.size.width;
    //设置周期影响参数，2π/waveCycle是一个周期
    waveCycle = 1/30.0;
    //设置波浪纵向位置
    currentK = self.frame.size.height*0.5;//屏幕居中
    
    /*
     *初始化第一个波纹图层
     */
    _firstWaveLayer = [CAShapeLayer layer];
    //设置填充颜色
    _firstWaveLayer.fillColor = [UIColor colorFromHexString:@"#4DE1FF" alpha:0.2].CGColor;
    //添加到view的layer上
    [self.layer addSublayer:_firstWaveLayer];
    //设置波纹流动速度
    waveSpeedA = 0.4;
    //设置波纹振幅
    waveAmplitudeA = 2;
    //初始化偏移量影响参数，平移的单位为offsetXA/waveCycle,而不是offsetXA
    offsetXA = 0;
    
    /*
     *初始化第二个波纹图层
     */
    _secondWaveLayer = [CAShapeLayer layer];
    //设置填充颜色
    _secondWaveLayer.fillColor = [UIColor colorFromHexString:@"#4DC3FF" alpha:0.4].CGColor;
    //添加到view的layer上
    [self.layer addSublayer:_secondWaveLayer];
    //设置波纹流动速度
    waveSpeedB = 0.3;
    //设置波纹振幅
    waveAmplitudeB = 6;
    //初始化偏移量影响参数，平移的单位为offsetXB/waveCycle,而不是offsetXB
    offsetXB = 1;

    /*
     *初始化第三个波纹图层
     */
    _thirdWaveLayer = [CAShapeLayer layer];
    //设置填充颜色
    _thirdWaveLayer.fillColor = [UIColor colorFromHexString:@"#4DA6FF" alpha:0.6].CGColor;
    //添加到view的layer上
    [self.layer addSublayer:_thirdWaveLayer];
//    [self setupThirdGradientLayer];
    //设置波纹流动速度
    waveSpeedC = 0.2;
    //设置波纹振幅
    waveAmplitudeC = 10;
    //初始化偏移量影响参数，平移的单位为offsetXC/waveCycle,而不是offsetXC
    offsetXC = 1.5;
    
    /*
     *启动定时器，适用于UI的不停刷新
     */
    _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    _waveDisplaylink.frameInterval = 2;//设置定时器刷新的频率，屏幕刷新两帧定时器才会触发一次（iOS设备的默认刷新频率是60HZ也就是60帧，即每秒刷新60次）
    [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];//添加到RunLoop中
}

- (void)setupThirdGradientLayer {
    /*
     *初始化第三个渐变
     */
    _thirdGradientLayer = [CAGradientLayer layer];
    // gradientLayer在上升完成之后的frame值，如果gradientLayer在上升过程中不断变化frame值会导致一开始绘制卡顿，所以只进行一次赋值
    //    CGFloat gradientLayerHeight = waveAmplitudeC * sin(waveCycle * 1+ offsetXC)+currentK;
    //    _thirdGradientLayer.frame = CGRectMake(0, CGRectGetHeight(self.frame) - gradientLayerHeight, CGRectGetWidth(self.frame), gradientLayerHeight);
    CGFloat gradientLayerY = currentK + 40;
    _thirdGradientLayer.frame = CGRectMake(0, gradientLayerY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - gradientLayerY);
    // 默认的渐变色
    NSArray *colors = @[(__bridge id)[UIColor colorFromHexString:@"#4DE1FF" alpha:0.5].CGColor, (__bridge id)[UIColor colorFromHexString:@"#4DA6FF" alpha:0.1].CGColor];
    _thirdGradientLayer.colors = colors;
    //设定颜色分割点
    NSInteger count = [colors count];
    CGFloat d = 1.0 / count;
    NSMutableArray *locations = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        NSNumber *num = @(d + d * i);
        [locations addObject:num];
    }
    NSNumber *lastNum = @(1.0f);
    [locations addObject:lastNum];
    _thirdGradientLayer.locations = locations;
    // 设置渐变方向，从上往下
    _thirdGradientLayer.startPoint = CGPointMake(0, 0);
    _thirdGradientLayer.endPoint = CGPointMake(0, 1);
    [_thirdGradientLayer setMask:_thirdWaveLayer];
    //添加到view的layer上
    [self.layer addSublayer:_thirdGradientLayer];
}

#pragma mark - 实现波纹动画
- (void)getCurrentWave:(CADisplayLink *)displayLink {
    //实时的位移：waveSpeedA/waveCycle
    offsetXA += waveSpeedA;
    offsetXB += waveSpeedB;
    offsetXC += waveSpeedC;
    [self setCurrentWaveLayerPath];
}

//重新绘制波浪图层
- (void)setCurrentWaveLayerPath {
    //创建一个路径，绘图路径，带有Ref后缀的类型是Core Graphics中用来模拟面向对象机制的C结构，必须在使用完之后手动释放。
    CGMutablePathRef pathA = CGPathCreateMutable();
    CGFloat y = currentK;
    //将点移动到 x=0,y=currentK的位置
    CGPathMoveToPoint(pathA, nil, 0, y);
    for (NSInteger x = 0.0f; x<=waterWaveWidth; x++) {
        //正弦波浪公式：y =Asin（ωx+φ）+C
        y = waveAmplitudeA * sin(waveCycle * x+ offsetXA)+currentK;
        //将点连成线
        CGPathAddLineToPoint(pathA, nil, x, y);
    }
    CGPathAddLineToPoint(pathA, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(pathA, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(pathA);
    _firstWaveLayer.path = pathA;
    CGPathRelease(pathA);
    
    //创建一个路径
    CGMutablePathRef pathB = CGPathCreateMutable();
    //将点移动到 x=offsetXB/waveCycle=30,y=currentK的位置
    CGPathMoveToPoint(pathB, nil, 0, y);
    for (NSInteger x = 0.0f; x<=waterWaveWidth; x++) {
        //正弦波浪公式
        y = waveAmplitudeB * sin(waveCycle * x+ offsetXB)+currentK;
        y += 20;
        //将点连成线
        CGPathAddLineToPoint(pathB, nil, x, y);
    }
    CGPathAddLineToPoint(pathB, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(pathB, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(pathB);
    _secondWaveLayer.path = pathB;
    CGPathRelease(pathB);
    
    //创建一个路径
    CGMutablePathRef pathC = CGPathCreateMutable();
    //将点移动到 x=offsetXC/waveCycle=30,y=currentK的位置
    CGPathMoveToPoint(pathC, nil, 0, y);
    for (NSInteger x = 0.0f; x<=waterWaveWidth; x++) {
        //正弦波浪公式
        y = waveAmplitudeC * sin(waveCycle * x+ offsetXC)+currentK;
        y += 40;
        //将点连成线
        CGPathAddLineToPoint(pathC, nil, x, y);
    }
    CGPathAddLineToPoint(pathC, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(pathC, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(pathC);
    _thirdWaveLayer.path = pathC;
//    _thirdGradientLayer.shadowPath = pathC;
    CGPathRelease(pathC);
    
//    /*
//     *渐变
//     */
//    //保存渐变之前的绘画状态
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(currentContext);
//    //绘制渐变剪切路径
//    UIBezierPath *path1 = [[UIBezierPath alloc] init];
//    [path1 moveToPoint:CGPointMake(100, 450)];
//    [path1 addLineToPoint:CGPointMake(250, 450)];
//    [path1 addLineToPoint:CGPointMake(250, 650)];
//    [path1 addLineToPoint:CGPointMake(100, 650)];
//    [path1 closePath];
//    //是用剪切路径剪裁图形上下文
//    [path1 addClip];
//    _thirdWaveLayer.accessibilityPath = path1;
//    //绘制渐变
//    CGFloat locations[4] = {0.0,0.4,0.7,1.0};//三个颜色节点
//    CGFloat components[16] = {1.0,0.3,0.0,1.0,//起始颜色
//        0.2,0.8,0.2,1.0,//中间颜色
//        1.0,1.0,0.5,1.0,//中间颜色
//        0.8,0.3,0.4,1.0};//终止颜色
//    //创建RGB色彩空间对象
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 4);
//    /*线性渐变
//     *参数1:当前上下文
//     *参数2:渐变指针
//     *参数3，4:渐变的起始和终止位置
//     *参数5:CGGradientDrawingOptions枚举
//     typedef CF_OPTIONS (uint32_t, CGGradientDrawingOptions) {
//     kCGGradientDrawsBeforeStartLocation = (1 << 0),//扩展整个渐变到渐变的起点之前的所有点
//     kCGGradientDrawsAfterEndLocation = (1 << 1)//扩展整个渐变到渐变的终点之后的所有点
//     };
//     0表示既不往前扩展也不往后扩展
//     */
//    //渐变的起点(渐变效果在以起点和终点为轴的直线周边)
//    CGPoint startPoint = CGPointMake(100, 450);
//    //渐变的终点
//    CGPoint endPoint = CGPointMake(100, 650);
//    CGContextDrawLinearGradient(currentContext, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
//    //释放创建的C结构对象
//    CGGradientRelease(gradient);
//    CGColorSpaceRelease(colorSpace);
//    //恢复绘画状态
//    CGContextRestoreGState(currentContext);
}

#pragma mark - 销毁定时器
- (void)dealloc {
    [_waveDisplaylink invalidate];
}


@end
