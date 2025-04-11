//
//  AIFeatureStep2Models.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/4/11.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep2Models.h"

@implementation AIFeatureStep2Models

-(NSMutableArray *)models {
    if (!_models) _models = [NSMutableArray new];
    return _models;
}

-(AIFeatureStep2Model*) getModelIfNullCreate:(NSInteger)conPId {
    //1. 优先找旧的。
    for (AIFeatureStep2Model *model in self.models) {
        if (model.conPId == conPId) return model;
    }
    
    //2. 找不到则新建。
    AIFeatureStep2Model *newModel = [AIFeatureStep2Model new:conPId];
    [self.models addObject:newModel];
    return newModel;
}

-(void) updateItem:(NSInteger)conPId absPId:(NSInteger)absPId absAtConRect:(CGRect)absAtConRect {
    AIFeatureStep2Model *model = [self getModelIfNullCreate:conPId];
    [model updateItem:absPId absAtConRect:absAtConRect];
}

@end
