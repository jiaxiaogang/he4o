//
//  NVHeader.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/29.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVView.h"
#import "NVHeUtil.h"

/**
 *  MARK:--------------------SMG内核中网络可视化项目--------------------
 *  1. 目前放这,随后立为单独项目;
 */

/**
 *  MARK:--------------------四个方向--------------------
 */
typedef NS_ENUM(NSInteger, DirectionType) {
    DirectionType_Top   = 0,
    DirectionType_Bottom= 1,
    DirectionType_Left  = 2,
    DirectionType_Right = 3
};
