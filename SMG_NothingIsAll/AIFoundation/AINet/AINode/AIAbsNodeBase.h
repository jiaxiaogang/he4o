//
//  AIAbsNodeBase.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------抽象节点基类--------------------
 *  1. 可以作为抽象;
 */
@interface AIAbsNodeBase : AINodeBase

@property (strong, nonatomic) NSMutableArray *conPorts; //具象关联端口

@end
