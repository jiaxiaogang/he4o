//
//  ReasonDemandModel.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/21.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "ReasonDemandModel.h"
#import "TOFoModel.h"
#import "AIShortMatchModel.h"

@implementation ReasonDemandModel

+(ReasonDemandModel*) newWithMModel:(AIMatchFoModel*)mModel inModel:(AIShortMatchModel*)inModel{
    ReasonDemandModel *result = [[ReasonDemandModel alloc] init];
    result.mModel = mModel;
    result.inModel = inModel;
    return result;
}

@end
