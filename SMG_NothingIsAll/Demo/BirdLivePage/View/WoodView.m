//
//  WoodView.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/16.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "WoodView.h"
#import "UIView+Extension.h"

@implementation WoodView

-(id) init {
    self = [super init];
    if(self != nil){
        [self initView];
        [self initDisplay];
    }
    return self;
}

-(void) initView{
    //self
    [self setFrame:CGRectMake(0, (ScreenHeight - 100) * 0.5f, 5, 100)];
    [self setBackgroundColor:UIColorWithRGBHex(0x825528)];
}

-(void) initDisplay{
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
    [self.layer removeAllAnimations];
}

//复位
-(void) reset4EndAnimation {
    [self reset:true x:0];
}



/**
 *  MARK:--------------------扔出--------------------
 *  @param hitBlock : 碰撞检测 (碰撞时刻检测一次,如果没撞到到终点后再检测一次) notnull
 *  @version
 *      2021.09.08: 支持两段动画,并在中段和尾段分别进行碰撞检测;
 *      2022.04.27: 调慢木棒动画 (参考25222);
 *      2022.06.04: 支持随机扔出点 (参考26196-方案2);
 *      2023.05.22: 迭代v4:动画结束时,调用下碰撞检测啥的 (参考29098-方案3);
 */
-(void) throwV4:(CGFloat)throwX time:(CGFloat)time distance:(CGFloat)distance invoked:(void(^)())invoked {
    //1. 扔出前复位 (并移除可能还在进行中的动画);
    [self reset4StartAnimation:throwX];
    
    //2. 执行动画;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.x += distance;
    } completion:^(BOOL finished) {
        [self.delegate woodView_WoodAnimationFinish];
        [self reset4EndAnimation];
        invoked();
    }];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.delegate woodView_SetFramed];
}

@end
