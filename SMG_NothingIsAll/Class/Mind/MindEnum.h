//
//  MindEnum.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//



/**
 *  MARK:--------------------表情喜怒(外)--------------------
 */
typedef NS_ENUM(NSInteger, JoyAngerType) {
    JoyAngerType_Joy = 0,
    JoyAngerType_Anger = 1,
};

/**
 *  MARK:--------------------心情哀乐(内)--------------------
 */

/**
 *  MARK:--------------------MindType(最基础的需求)--------------------
 */
typedef NS_ENUM(NSInteger, MindType) {
    MindType_Hunger     =   0,//饥饿
    MindType_Curiosity  =   1,//好奇心
    MindType_Mood       =   2,//心情
    MindType_Angry      =   3,//生气....temp
    MindType_Happy      =   4,//开心....temp
};

/**
 *  MARK:--------------------心情--------------------
 */
typedef NS_ENUM(NSInteger, MoodType) {
    MoodType_Irritably2Calm  =   0,//急燥心静
};

/**
 *  MARK:--------------------充电状态--------------------
 */
typedef NS_ENUM(NSInteger, HungerState) {
    HungerState_Unknown     = 0,
    HungerState_Unplugged   = 1,//未充电
    HungerState_Charging    = 2,//充电中
};
