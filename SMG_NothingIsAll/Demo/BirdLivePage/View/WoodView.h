//
//  WoodView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/16.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ThrowTime 5.0f //满屏飞过用时

@interface WoodView : HEView

//复位
-(void) reset:(BOOL)hidden x:(CGFloat)x;
-(void) reset4StartAnimation:(CGFloat)throwX;
-(void) reset4EndAnimation;

/**
 *  MARK:--------------------扔出--------------------
 *  @param hitBlock : 碰撞检测 (碰撞时刻检测一次,如果没撞到到终点后再检测一次) notnull
 */
-(void) throw:(CGFloat)throwX frontTime:(CGFloat)frontTime backTime:(CGFloat)backTime speed:(CGFloat)speed hitBlock:(BOOL(^)())hitBlock invoked:(void(^)())invoked;

@end
