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
    return [self filterTwice:matchAlgModels scoreBlock1:^double(AIMatchAlgModel *item) {
        return item.matchValue;
    } scoreBlock2:^double(AIMatchAlgModel *item) {
        return item.strongValue;
    }];
}

+(NSArray*) recognitonFoFilter:(NSArray*)matchModels {
    return [self filterTwice:matchModels scoreBlock1:^double(AIMatchFoModel *item) {
        return item.matchFoValue;
    } scoreBlock2:^double(AIMatchFoModel *item) {
        return item.strongValue;
    }];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------同时符合两项过滤器的前xx% (参考28152-方案3)--------------------
 *  @version
 *      2023.03.06: 过滤前20%改为35% (参考28152-方案3-todo2);
 */
+(NSArray*) filterTwice:(NSArray*)protoArr scoreBlock1:(double(^)(id item))scoreBlock1 scoreBlock2:(double(^)(id item))scoreBlock2 {
    //1. 分别按1和2过滤前35%;
    NSArray *filter1 = ARR_SUB([SMGUtils sortBig2Small:protoArr compareBlock:scoreBlock1], 0, protoArr.count * 0.35f);
    NSArray *filter2 = ARR_SUB([SMGUtils sortBig2Small:protoArr compareBlock:scoreBlock2], 0, protoArr.count * 0.35f);
    
    //2. 过滤出同时符合二项的,并返回 (参考28152-方案3-todo3);
    NSArray *filterTwice = [SMGUtils filterArr:protoArr checkValid:^BOOL(id item) {
        return [filter1 containsObject:item] && [filter2 containsObject:item];
    }];
    return filterTwice;
}


@end
