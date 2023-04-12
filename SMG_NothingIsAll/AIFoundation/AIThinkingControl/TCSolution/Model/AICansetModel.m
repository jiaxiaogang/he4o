//
//  AICansetModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/11.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AICansetModel.h"

@implementation AICansetModel

+(AICansetModel*) newWithBase:(AICansetModel*)base type:(CansetType)type scene:(AIKVPointer*)scene {
    AICansetModel *result = [[AICansetModel alloc] init];
    result.type = type;
    if (base) [base.subs addObject:result];
    
    //TODOTOMORROW20230412: override (参考29069-todo5);
    //当前下面挂载的有效cansets (用父级优先级更高的 - 减去当前cansets);
    AIFoNodeBase *matchFo = [SMGUtils searchNode:pFo.matchFo];
    NSArray *protoCansets = [matchFo getConCansets:matchFo.count];
    if (base) {
        //casets = protoCansets - base.cansets;
        //其中优先级高,可能有两级,比如: 兄弟要同时 - 父类 & 自己;
    }
    
    return result;
}

@end
