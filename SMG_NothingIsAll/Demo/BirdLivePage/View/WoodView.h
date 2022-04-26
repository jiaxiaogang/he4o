//
//  WoodView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/16.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ThrowTime 2.0f //满屏飞过用时

@interface WoodView : HEView

//复位
-(void) reset:(BOOL)hidden;

/**
 *  MARK:--------------------扔出--------------------
 *  @param hitBlock : 碰撞检测 (碰撞时刻检测一次,如果没撞到到终点后再检测一次) notnull
 */
-(void) throw:(CGFloat)hitTime hitBlock:(BOOL(^)())hitBlock;

@end
