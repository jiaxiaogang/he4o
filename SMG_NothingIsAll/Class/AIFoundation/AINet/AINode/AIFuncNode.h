//
//  AIFuncNode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINode.h"

/**
 *  MARK:--------------------双路神经元--------------------
 *  1. 由组指向
 *  2. 指向单路神经元(存value)
 */
@interface AIFuncNode : AINode

+(AIFuncNode*) newWithFuncPointer:(AIKVPointer*)funcPointer singleNodePointer:(AIKVPointer*)singleNodePointer;
@property (strong,nonatomic) AIKVPointer *funcPointer;      //算法数据指针
@property (strong,nonatomic) AIKVPointer *singleNodePointer;//存结果_单神经元节点指针


@end
