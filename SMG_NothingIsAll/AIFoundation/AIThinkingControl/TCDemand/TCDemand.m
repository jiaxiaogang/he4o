//
//  TCDemand.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCDemand.h"

@implementation TCDemand

/**
 *  MARK:--------------------r预测--------------------
 *  @version
 *      2021.12.05: 原本只有tor受阻时才执行solution,现改为不依赖tor,因为tor改到概念识别之后了 (参考24171-9);
 */
+(void) rDemand:(AIShortMatchModel*)model{
    //2. 预测处理_把mv加入到demandManager;
    OSTitleLog(@"rDemand");
    [theTC.outModelManager updateCMVCache_RMV:model];
    
    //6. 此处推进不成功,则运行TOP四模式;
    [TCScore score];
}

/**
 *  MARK:--------------------p任务--------------------
 *  @desc 功能说明:
 *      1. 更新energy值
 *      2. 更新需求池
 *      3. 进行dataOut决策行为化;
 */
+(void) pDemand:(AICMVNode*)cmvNode{
    //1. 将联想到的cmv更新energy & 更新demandManager & decisionLoop
    OSTitleLog(@"pDemand");
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    [theTC.outModelManager updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta];
    
    //2. 转向执行;
    [TCScore score];
}

/**
 *  MARK:--------------------反馈生成子任务--------------------
 *  @version
 *      2021.12.06: 反馈feedback后生成子任务,但并不触发solution决策 (参考24171-9de);
 */
+(void) feedbackDemand:(AIShortMatchModel*)model foModel:(TOFoModel*)foModel{
    //1. 识别结果pFos挂载到targetFoModel下做子任务 (好的坏的全挂载,比如做的饭我爱吃{MV+},但是又太麻烦{MV-});
    OFTitleLog(@"subDemand",@"\n子任务数:%ld baseFo:%@",model.fos4Demand.count,Pit2FStr(foModel.content_p));
    for (AIMatchFoModel *item in model.fos4Demand) {
        [ReasonDemandModel newWithMModel:item inModel:model baseFo:foModel];
    }
}

/**
 *  MARK:--------------------hDemand--------------------
 *  @version
 *      2021.12.19: 改为调用TCScore而不是hSolution;
 */
+(void) hDemand:(TOAlgModel*)algModel{
    //1. 对algModel生成H任务,并挂载在当前短时记忆分支下;
    OFTitleLog(@"hDemand",@"\n%@",Pit2FStr(algModel.content_p));
    [HDemandModel newWithAlgModel:algModel];
    
    //2. 调用TCScore继续决策;
    [TCScore score];//[TCSolution hSolution:hDemand];
}

@end
