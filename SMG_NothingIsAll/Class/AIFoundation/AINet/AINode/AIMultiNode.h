//
//  AIMultiNode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINode.h"

/**
 *  MARK:--------------------多路神经元--------------------
 */
@interface AIMultiNode : AINode

@property (strong,nonatomic) NSMutableArray *nodes;  //指向的子节点(指针)数组;

@end
