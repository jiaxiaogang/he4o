//
//  AIAlgNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/3.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"

/**
 *  MARK:--------------------概念Base节点--------------------
 *  1. TODO: 将概念添加isOut,或将foNode.orders中添加每个元素的isOut;
 *  2. TODOv2.0: 将refPorts独立成文件;
 */
@interface AIAlgNodeBase : AINodeBase

@property (strong, nonatomic) NSMutableArray *refPorts; //引用序列

@end
