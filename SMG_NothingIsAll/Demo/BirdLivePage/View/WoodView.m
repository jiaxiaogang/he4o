//
//  WoodView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/16.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "WoodView.h"
#import "UIView+Extension.h"

@interface WoodView ()

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) float aniBeginX;
@property (assign, nonatomic) float aniDeltaX;
@property (assign, nonatomic) double aniBeginTime;
@property (assign, nonatomic) double aniDeltaTime;
@property (assign, nonatomic) Act0 aniInvoked;

@end

@implementation WoodView

-(void) initView{
    [super initView];
    //self
    [self setFrame:CGRectMake(0, (ScreenHeight - 100) * 0.5f, 5, 100)];
    [self setBackgroundColor:UIColorWithRGBHex(0x825528)];
}

-(void) initDisplay{
    [super initDisplay];
    [self reset:true x:0];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

//复位
-(void) reset:(BOOL)hidden x:(CGFloat)x{
    self.x = x;
    self.alpha = hidden ? 0 : 1;
}

//复位
-(void) reset4StartAnimation:(CGFloat)throwX {
    //1. 扔出前复位 (并移除可能还在进行中的动画);
    [self reset:false x:throwX];
    [self removeDisplayLink];
}

//复位
-(void) reset4EndAnimation {
    [self reset:true x:0];
}



/**
 *  MARK:--------------------扔出--------------------
 *  @version
 *      2021.09.08: 支持两段动画,并在中段和尾段分别进行碰撞检测;
 *      2022.04.27: 调慢木棒动画 (参考25222);
 *      2022.06.04: 支持随机扔出点 (参考26196-方案2);
 *      2023.05.22: 迭代v4:动画结束时,调用下碰撞检测啥的 (参考29098-方案3);
 *      2023.07.26: 迭代v5:使用displayLink帧动画,使碰撞检查更加及时 (参考30087-分析2-todo1);
 */
-(void) throwV5:(CGFloat)throwX time:(CGFloat)time distance:(CGFloat)distance invoked:(void(^)())invoked {
    //1. 扔出前复位 (并移除可能还在进行中的动画);
    [self reset4StartAnimation:throwX];
    
    //2. 保留动画参数;
    self.aniBeginX = self.x;
    self.aniDeltaX = distance;
    self.aniBeginTime = CACurrentMediaTime();
    self.aniDeltaTime = time;
    self.aniInvoked = invoked;
    
    //3. 执行动画;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkFrame)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = NO;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    //NSLog(@"碰撞检测");
    [self.delegate woodView_SetFramed];
}

-(void) displayLinkFrame {
    //1. 动画进度计算
    double now = CACurrentMediaTime();
    double radio = (now - self.aniBeginTime) / self.aniDeltaTime;
    if (radio < 1.0) {
        //2. 动画中...
        self.x = self.aniBeginX + self.aniDeltaX * radio;
    } else {
        //3. 动画结束时,回调,执行block;
        self.x = self.aniBeginX + self.aniDeltaX;
        [self.delegate woodView_WoodAnimationFinish];
        [self reset4EndAnimation];
        self.aniInvoked();
        NSLog(@"扔木棒 动画结束");
        
        //4. 停止displayLink;
        [self removeDisplayLink];
    }
}

-(void) removeDisplayLink {
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end
