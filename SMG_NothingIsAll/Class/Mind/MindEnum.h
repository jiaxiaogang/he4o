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
typedef NS_ENUM(NSInteger, MindType) {
    TimeCompareType_None        = 0,//未知
    TimeCompareType_Front       = 1,//早
    TimeCompareType_Same        = 2,//同时
    TimeCompareType_Back        = 3,//迟
};


/**
 *  MARK:--------------------心情哀乐(内)--------------------
 */
typedef NS_ENUM(NSInteger, TimeCompareType) {
    TimeCompareType_None        = 0,//未知
    TimeCompareType_Front       = 1,//早
    TimeCompareType_Same        = 2,//同时
    TimeCompareType_Back        = 3,//迟
};


