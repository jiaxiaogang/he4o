//
//  Hunger.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HungerDelegate <NSObject>

/**
 *  MARK:--------------------MindValueChanged & 变化 & 状态--------------------
 *      1,充电中... & 电量变化+
 *      2,未充电中... & 电量变化-
 */
-(void) hunger_LevelChanged:(AIHungerLevelChangedModel*)model;

/**
 *  MARK:--------------------MindValueChanged & 变化 & 状态--------------------
 *      1,开始充 & 当前电量
 *      2,结束充 & 当前电量
 */
-(void) hunger_StateChanged:(AIHungerStateChangedModel*)model;

@end


/**
 *  MARK:--------------------Mind元:饥饿--------------------
 */
@class MindStrategyModel;
@interface Hunger : NSObject



@property (weak, nonatomic) id<HungerDelegate> delegate;
-(HungerState) getState;
-(CGFloat) getLevel;
-(void) setLevel:(CGFloat)level;

-(void) tmpTest_Add;
-(void) tmpTest_Sub;
-(void) tmpTest_Start;
-(void) tmpTest_Stop;

@end
