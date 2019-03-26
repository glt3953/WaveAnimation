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
    CGPathRelease(pathC);
}

#pragma mark - 销毁定时器
- (void)dealloc {
    [_waveDisplaylink invalidate];
}


@end
