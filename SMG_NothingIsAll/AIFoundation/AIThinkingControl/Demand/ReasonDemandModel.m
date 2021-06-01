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
#import "AIMatchFoModel.h"
#import "AINetIndex.h"

@implementation ReasonDemandModel

/**
 *  MARK:--------------------newWith--------------------
 *  @version
 *      2021.03.28: 将at & delta & urgentTo也封装到此处取赋值;
 *      2021.06.01: 将子任务时的base也兼容入baseOrGroup中 (参考23094);
 */
+(ReasonDemandModel*) newWithMModel:(AIMatchFoModel*)mModel inModel:(AIShortMatchModel*)inModel baseFo:(TOFoModel*)baseFo{
    //1. 数据准备;
    ReasonDemandModel *result = [[ReasonDemandModel alloc] init];
    AICMVNodeBase *mvNode = [SMGUtils searchNode:mModel.matchFo.cmvNode_p];
    NSInteger delta = [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
    NSString *algsType = mvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
    urgentTo = (int)(urgentTo * mModel.matchFoValue);
    
    //2. 短时结构;
    if (baseFo) [baseFo.subDemands addObject:result];
    result.baseOrGroup = baseFo;
    
    //3. 属性赋值;
    result.algsType = algsType;
    result.delta = delta;
    result.urgentTo = urgentTo;
    result.mModel = mModel;
    result.inModel = inModel;
    return result;
}

@end
