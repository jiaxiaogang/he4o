//
//  AIFeatureStep1Models.m
//  SMG_NothingIsAll
//
//  Created by jia on 2025/5/7.
//  Copyright © 2025 XiaoGang. All rights reserved.
//

#import "AIFeatureStep1Models.h"

@implementation AIFeatureStep1Models

+(id) new:(NSInteger)hash {
    AIFeatureStep1Models *result = [AIFeatureStep1Models new];
    result.protoTHash = hash;
    return result;
}

-(NSMutableArray *)models {
    if (!_models) _models = [NSMutableArray new];
    return _models;
}

@end
