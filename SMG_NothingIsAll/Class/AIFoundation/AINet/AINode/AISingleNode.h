//
//  AISingleNode.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/10/17.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINode.h"

@interface AISingleNode : AINode

@property (strong,nonatomic) NSMutableArray *dataNodePointers;  //指向数据节点指针(存一次,加一个)

@end
