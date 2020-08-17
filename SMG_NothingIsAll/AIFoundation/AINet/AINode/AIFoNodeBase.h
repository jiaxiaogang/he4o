//
//  AIFoNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/10/19.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------时序节点基类--------------------
 *  @name 前因序列
 *  1. 是frontOrderNode和absNode的基类;
 */
@interface AIFoNodeBase : AINodeBase

/**
 *  MARK:--------------------cmvNode_p结果--------------------
 *  @desc 指向mv基本模型的价值影响节点;
 */
@property (strong, nonatomic) AIKVPointer *cmvNode_p;

/**
 *  MARK:--------------------兄弟节点--------------------
 *  @desc 目前用于反向反馈类比的结果,表示cPFo和cSFo之间的互指向关系;
 */
@property (strong, nonatomic) AIKVPointer *brother_p;

/**
 *  MARK:--------------------生物钟时间间隔记录--------------------
 *  @desc
 *      1. 功能: 用于记录时序中,每元素间的生物钟间隔;
 *      2. 比如: [我,打,豆豆]->{mv+},记录成deltaTime后为[1,100,0];
 *      3. 表示: 我用1ms打了,100ms豆豆,0ms内就感受到了爽;
 */
@property (strong, nonatomic) NSMutableArray *deltaTimes;

@end
