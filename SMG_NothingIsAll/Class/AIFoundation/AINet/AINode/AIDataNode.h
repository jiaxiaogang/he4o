//
//  AIDataNode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/26.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINode.h"

/**
 *  MARK:--------------------单路神经元--------------------
 */
@interface AIDataNode : AINode

@property (strong,nonatomic) NSMutableArray *ports;     //item为AILine.pointer
@property (strong,nonatomic) AIKVPointer *dataPointer;  //数据指针

@end
