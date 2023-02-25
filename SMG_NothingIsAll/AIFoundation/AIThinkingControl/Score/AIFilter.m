//
//  AIFilter.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/2/25.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AIFilter.h"

@implementation AIFilter

+(NSArray*) recognitonAlgFilter:(NSArray*)matchAlgModels {
    NSArray *sort = [SMGUtils sortBig2Small:matchAlgModels compareBlock:^double(AIMatchAlgModel *obj) {
        return obj.matchValue;
    }];
    return ARR_SUB(sort, 0, MAX(10, sort.count * 0.2f));
}

+(NSArray*) recognitonFoFilter:(NSArray*)matchModels {
    NSArray *sort = [SMGUtils sortBig2Small:matchModels compareBlock:^double(AIMatchFoModel *obj) {
        return obj.strongValue;
    }];
    return ARR_SUB(sort, 0, MAX(10, sort.count * 0.2f));
}

@end
