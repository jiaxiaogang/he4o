//
//  AIShortMatchModel_Simple.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/8/20.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "AIShortMatchModel_Simple.h"

@implementation AIShortMatchModel_Simple

+(AIShortMatchModel_Simple*) newWithAlg_p:(AIKVPointer*)alg_p inputTime:(NSTimeInterval)inputTime isTimestamp:(BOOL)isTimestamp{
    AIShortMatchModel_Simple *result = [[AIShortMatchModel_Simple alloc] init];
    result.alg_p = alg_p;
    result.inputTime = inputTime;
    result.isTimestamp = isTimestamp;
    return result;
}

@end
