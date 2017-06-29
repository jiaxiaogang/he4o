//
//  AILine.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------网线--------------------
 *  1,指向任何两个AIPointer
 *  2,形成"神经网络"的网络线
 *  3,自带强度及衰减强化策略
 *  4,单独存表
 *  5,销毁时,通知GC;GC去回收已经没有指向的数据;
 */
@class AILineStrong;
@interface AILine : NSObject

@property (strong,nonatomic) AILineStrong *strong;   //网络强度

@end
