//
//  AISceneModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/4/11.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "AISceneModel.h"

@implementation AISceneModel

+(AISceneModel*) newWithBase:(AISceneModel*)base type:(SceneType)type scene:(AIKVPointer*)scene cutIndex:(NSInteger)cutIndex {
    AISceneModel *result = [[AISceneModel alloc] init];
    result.type = type;
    if (base) [base.subs addObject:result];
    result.base = base;
    result.scene = scene;
    result.cutIndex = cutIndex;
    return result;
}

-(NSMutableArray *)subs {
    if (!_subs) _subs = [[NSMutableArray alloc] init];
    return _subs;
}

-(AISceneModel*) getRoot {
    if (self.type == SceneTypeI) {
        return self;
    }
    return [self.base getRoot];
}

@end
