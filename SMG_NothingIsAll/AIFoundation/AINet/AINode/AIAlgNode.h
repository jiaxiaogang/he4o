//
//  AIAlgNode.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"

/**
 *  MARK:--------------------算法类型具象节点--------------------
 */
@interface AIAlgNode : AINodeBase

@property (strong, nonatomic) NSMutableArray *absPorts;
@property (strong, nonatomic) NSMutableArray *refPorts; //引用序列
@property (strong, nonatomic) NSArray *value_ps;        //微信息组 (以pointer默认排序)

@end
