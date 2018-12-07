//
//  AIAbsAlgNode.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/7.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINodeBase.h"

@interface AIAbsAlgNode : AINodeBase

@property (strong, nonatomic) NSMutableArray *conPorts;
@property (strong, nonatomic) AIKVPointer *value_p;

@end
