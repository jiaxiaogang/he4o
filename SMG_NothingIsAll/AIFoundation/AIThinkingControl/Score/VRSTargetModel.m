//
//  VRSTargetModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "VRSTargetModel.h"

@implementation VRSTargetModel

+(VRSTargetModel*) newWithBaseFo:(AIFoNodeBase*)baseFo pScore:(double)pScore sScore:(double)sScore target:(AIKVPointer*)targetValue_p{
    VRSTargetModel *result = [[VRSTargetModel alloc] init];
    result.baseFo = baseFo;
    result.pScore = pScore;
    result.sScore = sScore;
    result.targetValue_p = targetValue_p;
    return result;
}

@end
