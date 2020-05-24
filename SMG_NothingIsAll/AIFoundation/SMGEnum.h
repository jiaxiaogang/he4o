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
    MVDirection_None        =-1,//无
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
 *  MARK:--------------------类比类型(大小有无同异)--------------------
 */
typedef NS_ENUM(NSInteger,  AnalogyType) {
    ATDefault   = 0,            //默认
    ATGreater   = INT_MAX - 47, //内类比_变大 (greater)
    ATLess      = INT_MIN + 48, //内类比_变小 (less)
    ATHav       = INT_MAX,      //内类比_变有 (hav)
    ATNone      = INT_MIN,      //内类比_变无 (none)
    ATPlus      = INT_MAX - 147,//反向类比_mv+ (plus)
    ATSub       = INT_MIN + 148,//反向类比_mv- (sub)
    ATSame      = INT_MAX - 247,//正向类比
};

/**
 *  MARK:--------------------Output通知前后枚举--------------------
 */
typedef NS_ENUM(NSInteger,  OutputObserverType) {
    OutputObserverType_Front   = 0,//前
    OutputObserverType_Back    = 1,//后
};

/**
 *  MARK:--------------------识别类型--------------------
 *  @desc 优先级说明: self > fuzzy > abs > seem
 */
typedef NS_ENUM(NSInteger, MatchType) {
    MatchType_None  = 0,//无效
    MatchType_Seem  = 1,//仅相似
    MatchType_Abs   = 2,//全含
    MatchType_Fuzzy = 3,//模糊匹配
    MatchType_Self  = 4,//自身
};

/**
 *  MARK:--------------------LogHeaderMode--------------------
 */
typedef NS_ENUM(NSInteger, LogHeaderMode) {
    LogHeaderMode_None  = 0,//无header
    LogHeaderMode_First = 1,//仅首行
    LogHeaderMode_All   = 2,//所有行
};

/**
 *  MARK:--------------------TOModelStatus--------------------
 *  @title 输出模型
 */
typedef NS_ENUM(NSInteger, TOModelStatus) {
    TOModelStatus_Runing   = 0,//运行中
    TOModelStatus_Pause    = 1,//因理性不满足条件而暂停
    TOModelStatus_Stop     = 2,//因评价失败而中止
    TOModelStatus_Finish   = 3,//最终成功
};
