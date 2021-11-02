//
//  VRSResultModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/10/29.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "VRSResultModel.h"

@implementation VRSResultModel

+(VRSResultModel*) newWithBaseFo:(AIFoNodeBase*)baseFo pScore:(double)pScore sScore:(double)sScore proto:(AIKVPointer*)protoValue_p{
    VRSResultModel *result = [[VRSResultModel alloc] init];
    result.baseFo = baseFo;
    result.pScore = pScore;
    result.sScore = sScore;
    result.protoValue_p = protoValue_p;
    return result;
}

@end
