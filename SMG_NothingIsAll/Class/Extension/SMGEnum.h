//
//  SMGEnum.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/4/8.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//


/**
 *  MARK:--------------------存储数据类型--------------------
 */
typedef NS_ENUM(NSInteger, StoreType) {
    StoreType_Mem    = 0,
    StoreType_Do     = 1,
    StoreType_Obj    = 2,
    StoreType_Text   = 3,
    StoreType_Logic  = 4,
};

/**
 *  MARK:--------------------输出表情类型--------------------
 */
typedef NS_ENUM(NSInteger, OutputFaceType) {
    OutputFaceType_Cry      = 0,
    OutputFaceType_Smile    = 1,
};

/**
 *  MARK:--------------------输出类型--------------------
 */
typedef NS_ENUM(NSInteger, OutputType) {
    OutputType_Face     = 0,
    OutputType_Text     = 1,
};


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
    MindType_Algesia    =   5,//痛觉
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

/**
 *  MARK:--------------------DemandNavigation--------------------
 */
typedef NS_ENUM(NSInteger, DemandStatus) {
    DemandStatus_None       = 0,
    DemandStatus_IO         = 1,//IO
    DemandStatus_NoMain     = 2,
    DemandStatus_MainWait   = 3,//主任务生成等待
    DemandStatus_MainCommit = 4,//主任务提交
    DemandStatus_NoSub      = 5,
    DemandStatus_SubCommit  = 6,//次任务提交
    DemandStatus_Finish     = 7,//finish
};
