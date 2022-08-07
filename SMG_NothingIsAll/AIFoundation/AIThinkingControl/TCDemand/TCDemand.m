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
    [theTC updateOperCount:kFILENAME];
    Debug();
    OSTitleLog(@"rDemand");
    [theTC.outModelManager updateCMVCache_RMV:model];
    [theTV updateFrame];
    
    //6. 此处推进不成功,则运行TOP四模式;
    DebugE();
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
    [theTC updateOperCount:kFILENAME];
    Debug();
    OSTitleLog(@"pDemand");
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    [theTC.outModelManager updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta];
    [theTV updateFrame];
    
    //2. 转向执行;
    DebugE();
    [TCScore score];
}

/**
 *  MARK:--------------------反馈生成子任务--------------------
 *  @version
 *      2021.12.06: 反馈feedback后生成子任务,但并不触发solution决策 (参考24171-9de);
 *  @todo
 *      2022.03.11: 根据fos4Demand生成子任务后,根据它的mvScoreV2限制它的下辖分支数 (参考25142-TODO3);
 *      2022.05.18: 多pFos形成单个任务 (参考26042-TODO1);
 */
+(void) feedbackDemand:(AIShortMatchModel*)model foModel:(TOFoModel*)foModel{
    //1. 识别结果pFos挂载到targetFoModel下做子任务 (好的坏的全挂载,比如做的饭我爱吃{MV+},但是又太麻烦{MV-});
    [theTC updateOperCount:kFILENAME];
    Debug();
    NSDictionary *fos4Demand = model.fos4Demand;
    OFTitleLog(@"subDemand",@"\n子任务数:%ld baseFo:%@",fos4Demand.count,Pit2FStr(foModel.content_p));
    for (NSString *atKey in fos4Demand.allKeys) {
        NSArray *pFosValue = [fos4Demand objectForKey:atKey];
        [ReasonDemandModel newWithAlgsType:atKey pFos:pFosValue inModel:model baseFo:foModel];
        for (AIMatchFoModel *pFo in pFosValue) NSLog(@"\t pFo:%@->{%.2f}",Pit2FStr(pFo.matchFo),[AIScore score4MV_v2:pFo]);
    }
    [theTV updateFrame];
    DebugE();
}

/**
 *  MARK:--------------------hDemand--------------------
 *  @version
 *      2021.12.19: 改为调用TCScore而不是hSolution;
 */
+(void) hDemand:(TOAlgModel*)algModel{
    //1. 对algModel生成H任务,并挂载在当前短时记忆分支下;
    [theTC updateOperCount:kFILENAME];
    Debug();
    OFTitleLog(@"hDemand",@"\n%@",Pit2FStr(algModel.content_p));
    [HDemandModel newWithAlgModel:algModel];
    [theTV updateFrame];
    
    //2. 调用TCScore继续决策;
    DebugE();
    [TCScore score];
}

@end
