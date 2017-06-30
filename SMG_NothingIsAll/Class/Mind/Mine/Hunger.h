//
//  Hunger.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------饥饿程度--------------------
 */
typedef NS_ENUM(NSInteger, HungerStatus) {
    HungerStatus_Full           = 1,//饱
    HungerStatus_NotHunger      = 2,//不饿
    HungerStatus_LitterHunger   = 3,//有点饿
    HungerStatus_Hunger         = 4,//饿
    HungerStatus_VeryHunger     = 5,//非常饿
    HungerStatus_VeryVeryHunger = 6,//非常非常饿
};

@protocol HungerDelegate <NSObject>

-(void) hunger_HungerStateChanged:(HungerStatus)status;

/**
 *  MARK:--------------------MindValueChanged & 变化 & 状态--------------------
 *      1,充电中... & 电量变化+
 *      2,未充电中... & 电量变化-
 */
-(void) hunger_LevelChanged:(CGFloat)level State:(UIDeviceBatteryState)state mindValueDelta:(CGFloat)mVD;

/**
 *  MARK:--------------------MindValueChanged & 变化 & 状态--------------------
 *      1,开始充 & 当前电量
 *      2,结束充 & 当前电量
 */
-(void) hunger_StateChanged:(UIDeviceBatteryState)state level:(CGFloat)level mindValueDelta:(CGFloat)mVD;

@end


/**
 *  MARK:--------------------Mind元:饥饿--------------------
 */
@class MindStrategyModel;
@interface Hunger : NSObject

@property (weak, nonatomic) id<HungerDelegate> delegate;
+(HungerStatus) getHungerStatus;
-(MindStrategyModel*) getStrategyModel;

@end
