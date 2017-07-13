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
