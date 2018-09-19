//
//  SMGEnum.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

/**
 *  MARK:--------------------输出表情类型--------------------
 */
typedef NS_ENUM(NSInteger, OutputFaceType) {
    OutputFaceType_Cry      = 0,
    OutputFaceType_Smile    = 1,
};


/**
 *  MARK:--------------------表情喜怒(外)--------------------
 */
typedef NS_ENUM(NSInteger, JoyAngerType) {
    JoyAngerType_Joy = 0,
    JoyAngerType_Anger = 1,
};

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
 *  MARK:--------------------MV规则类型--------------------
 */
typedef NS_ENUM(NSInteger, MVRuleType) {
    MVRuleType_None           = 0,//None
    MVRuleType_Back           = 1,//归零
    MVRuleType_Loop           = 2,//重复
    MVRuleType_Add            = 3,//增涨
};

/**
 *  MARK:--------------------MVInput值与感受值的曲线算法类型--------------------
 */
typedef NS_ENUM(NSInteger, MVUpCurveType) {
    MVUpCurveType_LINEAR    = 1,//线性
    MVUpCurveType_AND       = 2,//越来越高
};

/**
 *  MARK:--------------------MVValue值与衰减曲线算法类型--------------------
 */
typedef NS_ENUM(NSInteger, MVDownCurveType) {
    MVDownCurveType_LINEAR     = 1,//线性
    MVDownCurveType_AND        = 2,//越来越低
};

/**
 *  MARK:--------------------IMVType(输入imv信号)--------------------
 */
typedef NS_ENUM(NSInteger, MVType) {
    MVType_None     = 0,
    MVType_Hunger   = 1,
    MVType_Anxious  = 2,
    MVType_Algesia  = 3,//痛觉
};

/**
 *  MARK:--------------------CustomInputType(自定义输入信号)--------------------
 */
typedef NS_ENUM(NSInteger, CustomInputType) {
    CustomInputType_Charge     = 1,
};


/**
 *  MARK:--------------------神经元类型(废弃)--------------------
 */
//typedef NS_ENUM(NSInteger, AINodeType) {
//    AINodeType_Data         = 0,//单路神经元
//    AINodeType_Func         = 1,//双路神经元
//    AINodeType_MultiFunc    = 2,//多路神经元
//};


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
