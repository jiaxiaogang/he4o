//
//  AIFeatureZenTiModels.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureZenTiModels.h"

@implementation AIFeatureZenTiModels

-(NSMutableArray *)models {
    if (!_models) _models = [NSMutableArray new];
    return _models;
}

-(AIFeatureZenTiModel*) getModelIfNullCreate:(AIKVPointer*)conT {
    //1. 优先找旧的。
    for (AIFeatureZenTiModel *model in self.models) {
        if ([model.conT isEqual:conT]) return model;
    }
    
    //2. 找不到则新建。
    AIFeatureZenTiModel *newModel = [AIFeatureZenTiModel new:conT];
    [self.models addObject:newModel];
    return newModel;
}

-(void) updateItem:(AIKVPointer*)conT absT:(AIKVPointer*)absT absAtConRect:(CGRect)absAtConRect {
    AIFeatureZenTiModel *model = [self getModelIfNullCreate:conT];
    [model updateRectItem:absT absAtConRect:absAtConRect];
}

/**
 *  MARK:--------------------跑出位置符合度--------------------
 */
-(void) run4MatchDegree:(AIKVPointer*)protoT {
    //1. 求出比例。
    AIFeatureZenTiModel *protoModel = [self getModelIfNullCreate:protoT];
    
    //2. 把两个rect缩放一致（归一化），将absAtAssRect缩放成absAtProtoRect。
    for (AIFeatureZenTiModel *assModel in self.models) {
        if ([assModel.conT isEqual:protoT]) continue;
        
        //3. 计算assModel的位置符合度。
        [assModel run4MatchDegree:protoModel];
    }
}

/**
 *  MARK:--------------------跑出综合匹配度--------------------
 */
-(void) run4MatchValue:(AIKVPointer*)protoT {
    for (AIFeatureZenTiModel *conModel in self.models) {
        [conModel run4MatchValue:protoT];
    }
}

@end
