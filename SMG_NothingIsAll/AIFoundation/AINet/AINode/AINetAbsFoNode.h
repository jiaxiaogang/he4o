//
//  AINetAbsFoNode.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/26.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------抽象时序节点--------------------
 */
@class AIKVPointer;
@interface AINetAbsFoNode : AIFoNodeBase

@property (strong, nonatomic) NSMutableArray *conPorts; //具象关联端口

@end
