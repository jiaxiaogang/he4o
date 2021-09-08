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
    [self reset:true];
}

//MARK:===============================================================
//MARK:                     < method >
//MARK:===============================================================

//复位
-(void) reset:(BOOL)hidden{
    self.x = 0;
    self.alpha = hidden ? 0 : 1;
}

/**
 *  MARK:--------------------扔出--------------------
 *  @param hitBlock : 碰撞检测 (碰撞时刻检测一次,如果没撞到到终点后再检测一次) notnull
 *  @version
 *      2021.09.08: 支持两段动画,并在中段和尾段分别进行碰撞检测;
 */
-(void) throw:(CGFloat)hitTime hitBlock:(BOOL(^)())hitBlock{
    //1. 扔出前复位 (并移除可能还在进行中的动画);
    [self reset:false];
    [self.layer removeAllAnimations];
    
    //2. 前段动画,撞击前部分;
    [UIView animateWithDuration:hitTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.x += ScreenWidth * (hitTime / 2.0f);
    } completion:^(BOOL finished) {
        
        //3. 准时碰撞检测;
        NSLog(@"碰撞检测 (hitTime) ↓↓↓");
        BOOL hited = hitBlock();
        
        ///4. 后段动画,撞击后部分;
        if (finished) {
            [UIView animateWithDuration:2.0f - hitTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.x += ScreenWidth * ((2.0f - hitTime) / 2.0f);
            } completion:^(BOOL finished) {
                
                //5. 收尾碰撞检测 (如果准时未撞到,到结尾再判断一次);
                if (!hited) {
                    NSLog(@"碰撞检测 (finishTime) ↓↓↓");
                    hitBlock();
                }
                if (finished) {
                    [self reset:true];
                }
            }];
        }
    }];
}

@end
