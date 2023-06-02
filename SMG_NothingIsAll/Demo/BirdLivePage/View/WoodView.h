//
//  WoodView.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/16.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ThrowTime 8.0f //满屏飞过用时

@protocol WoodViewDelegate <NSObject>

-(void) woodView_SetFramed;
-(void) woodView_WoodAnimationFinish;

@end

@interface WoodView : HEView

@property (weak, nonatomic) id<WoodViewDelegate> delegate;

//复位
-(void) reset:(BOOL)hidden x:(CGFloat)x;
-(void) reset4StartAnimation:(CGFloat)throwX;
-(void) reset4EndAnimation;

/**
 *  MARK:--------------------扔出--------------------
 *  @param hitBlock : 碰撞检测 (碰撞时刻检测一次,如果没撞到到终点后再检测一次) notnull
 */
-(void) throwV4:(CGFloat)throwX time:(CGFloat)time distance:(CGFloat)distance invoked:(void(^)())invoked;

@end
