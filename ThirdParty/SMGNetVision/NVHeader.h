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

//指针转字符串
#define Pit2FStr(p) [NVHeUtil getLightStr:p simple:false]
#define Pits2FStr(ps) [NVHeUtil getLightStr4Ps:ps simple:false]

#define Pit2SStr(p) [NVHeUtil getLightStr:p simple:true]
#define Pits2SStr(ps) [NVHeUtil getLightStr4Ps:ps simple:true]

//节点转字符串
#define Alg2FStr(a) a ? STRFORMAT(@"A%ld(%@)",a.pointer.pointerId,[NVHeUtil getLightStr4Ps:a.content_ps simple:false]) : @"A()"
#define Fo2FStr(f) f ? STRFORMAT(@"F%ld[%@]",f.pointer.pointerId,[NVHeUtil getLightStr4Ps:f.content_ps simple:false]) : @"F[]"
#define Mvp2Str(m_p) m_p ? STRFORMAT(@"M%ld{%@}",m_p.pointerId,[NVHeUtil getLightStr:m_p]) : @"M{}"
