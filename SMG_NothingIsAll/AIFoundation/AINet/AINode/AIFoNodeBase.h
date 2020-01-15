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

@property (strong, nonatomic) AIKVPointer *cmvNode_p;        //cmvNode_p结果;

@end
