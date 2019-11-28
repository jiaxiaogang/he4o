//
//  SMGEnum.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

/**
 *  MARK:--------------------充电状态--------------------
 */
typedef NS_ENUM(NSInteger, HungerState) {
    HungerState_Unknown     = 0,
    HungerState_Unplugged   = 1,//未充电
    HungerState_Charging    = 2,//充电中
};


typedef NS_ENUM(NSInteger, AIMoodType) {
    AIMoodType_Anxious      = 1,//焦急
    AIMoodType_Satisfy      = 2,//满意
};

/**
 *  MARK:--------------------IMVType(输入imv信号)--------------------
 */
typedef NS_ENUM(NSInteger, MVType) {
    MVType_None     = 0,
    MVType_Hunger   = 1,
    MVType_Anxious  = 2,
    MVType_Hurt  = 3,//痛觉
};

/**
 *  MARK:--------------------CustomInputType(自定义输入信号)--------------------
 */
typedef NS_ENUM(NSInteger, CustomInputType) {
    CustomInputType_Charge     = 1,
};

/**
 *  MARK:--------------------MV目标类型--------------------
 */
typedef NS_ENUM(NSInteger, AITargetType) {
    AITargetType_None   = 0,//不变
    AITargetType_Up     = 1,//增涨(欲望)
    AITargetType_Down   = 2,//下降(饥饿,焦急)
    AITargetType_Repeat = 3,//重复(快乐)
};


/**
 *  MARK:--------------------顺逆方向--------------------
 */
typedef NS_ENUM(NSInteger, MVDirection) {
    MVDirection_Negative    = 0,//负
    MVDirection_Positive    = 1,//正
};

/**
 *  MARK:--------------------顺心类型--------------------
 */
typedef NS_ENUM(NSInteger, MindHappyType) {
    MindHappyType_None    = 0,//没影响
    MindHappyType_Yes    = 1,//顺心
    MindHappyType_No    = 2,//不顺心
};

/**
 *  MARK:--------------------内类比变化与有无--------------------
 */
typedef NS_ENUM(NSInteger,  AnalogyInnerType) {
    AnalogyInnerType_Default=-1,//默认
    AnalogyInnerType_Greater= 0,//变大
    AnalogyInnerType_Less   = 1,//变小
    AnalogyInnerType_Hav    = 2,//变有
    AnalogyInnerType_None   = 3,//变无
};
