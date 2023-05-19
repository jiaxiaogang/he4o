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

/**
 *  MARK:--------------------扔出--------------------
 *  @param hitBlock : 碰撞检测 (碰撞时刻检测一次,如果没撞到到终点后再检测一次) notnull
 *  @version
 *      2021.09.08: 支持两段动画,并在中段和尾段分别进行碰撞检测;
 *      2022.04.27: 调慢木棒动画 (参考25222);
 *      2022.06.04: 支持随机扔出点 (参考26196-方案2);
 */
-(void) throw:(CGFloat)throwX frontTime:(CGFloat)frontTime backTime:(CGFloat)backTime speed:(CGFloat)speed hitBlock:(BOOL(^)())hitBlock invoked:(void(^)())invoked{
    //1. 扔出前复位 (并移除可能还在进行中的动画);
    [self reset:false x:throwX];
    [self.layer removeAllAnimations];
    
    //2. 前段动画,撞击前部分;
    [UIView animateWithDuration:frontTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.x += frontTime * speed;
    } completion:^(BOOL finished) {

        //3. 准时碰撞检测;
        BOOL hited = false;
        if (frontTime > 0) {
            NSLog(@"碰撞检测 (hitTime) ↓↓↓");
            hited = hitBlock();
        }

        ///4. 后段动画,撞击后部分;
        if (finished) {
            [UIView animateWithDuration:backTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.x += speed * backTime;
            } completion:^(BOOL finished) {

                //5. 收尾碰撞检测 (如果准时未撞到,到结尾再判断一次);
                if (!hited && frontTime > 0 && backTime > 0) {
                    NSLog(@"碰撞检测 (finishTime) ↓↓↓");
                    hitBlock();
                }
                if (finished) {
                    [self reset:true x:0];
                }

                //6. 标记执行完成;
                invoked();
            }];
        }else{
            invoked();
        }
    }];
}

@end
