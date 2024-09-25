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
+(NSArray*) rDemand:(AIShortMatchModel*)model protoFo:(AIFoNodeBase*)protoFo{
    //2. 预测处理_把mv加入到demandManager;
    [theTC updateOperCount:kFILENAME];
    Debug();
    OSTitleLog(@"rDemand");
    NSArray *newRoots = [theTC.outModelManager updateCMVCache_RMV:model protoFo:protoFo];
    dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
        [theTV updateFrame];
    });
    DebugE();
    return newRoots;
}

/**
 *  MARK:--------------------p任务--------------------
 *  @desc 功能说明:
 *      1. 更新energy值
 *      2. 更新需求池
 *      3. 进行dataOut决策行为化;
 */
+(void) pDemand:(AICMVNodeBase*)cmvNode{
    //1. 将联想到的cmv更新energy & 更新demandManager & decisionLoop
    [theTC updateOperCount:kFILENAME];
    Debug();
    OSTitleLog(@"pDemand");
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    [theTC.outModelManager updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta];
    dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
        [theTV updateFrame];
    });
    
    //2. 转向执行;
    DebugE();
    [TCPlan planFromIfTCNeed];
}

/**
 *  MARK:--------------------反思识别形成子任务--------------------
 *  @version
 *      2021.12.06: 反馈feedback后生成子任务,但并不触发solution决策 (参考24171-9de);
 *  @todo
 *      2022.03.11: 根据fos4Demand生成子任务后,根据它的mvScoreV2限制它的下辖分支数 (参考25142-TODO3);
 *      2022.05.18: 多pFos形成单个任务 (参考26042-TODO1);
 *      2023.07.07: 以前是反馈后反思识别,现在改成行为化前反思识别,但最终都由此处生成子任务 (参考30054-todo5);
 */
+(void) subDemand:(AIShortMatchModel*)model foModel:(TOFoModel*)foModel{
    //1. 识别结果pFos挂载到targetFoModel下做子任务 (好的坏的全挂载,比如做的饭我爱吃{MV+},但是又太麻烦{MV-});
    [theTC updateOperCount:kFILENAME];
    Debug();
    NSDictionary *fos4Demand = model.fos4Demand;
    NSArray *baseRDemands = [TOUtils getBaseRDemands_AllDeep:foModel];
    NSArray *baseRAlgsTypes = [SMGUtils convertArr:baseRDemands convertBlock:^id(ReasonDemandModel *obj) {
        return obj.algsType;
    }];
    OFTitleLog(@"subDemand",@"\n子任务数:%ld baseFo:%@",fos4Demand.count,Pit2FStr(foModel.content_p));
    
    //2. 每一帧重新反思时,都把旧的R子任务移除掉 (参考33075-TODO2);
    [foModel.subDemands removeAllObjects];
    
    for (NSString *atKey in fos4Demand.allKeys) {
        //2. 不创建自己同标识的R子任务 (参考33071-步骤1);
        if ([baseRAlgsTypes containsObject:atKey]) continue;
        
        //3. 别的非同标识的R子任务,可以生成R子任务 (参考33071-步骤2);
        NSArray *pFosValue = [fos4Demand objectForKey:atKey];
        ReasonDemandModel *newSubRRoot = [ReasonDemandModel newWithAlgsType:atKey pFos:pFosValue shortModel:model baseFo:foModel protoFo:model.protoFo];
        for (AIMatchFoModel *pFo in pFosValue) {
            AIFoNodeBase *pFoNode = [SMGUtils searchNode:pFo.matchFo];
            NSLog(@"\t pFo:%@->{%@%.2f}",Pit2FStr(pFo.matchFo),ClassName2Str(pFoNode.cmvNode_p.algsType),[AIScore score4MV_v2FromCache:pFo]);
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
        [theTV updateFrame];
    });
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
    NSString *fltLog1 = FltLog4HDemandOfWuPiGuo(2);
    NSString *fltLog2 = FltLog4XueQuPi(1);
    TOFoModel *targetFo = (TOFoModel*)algModel.baseOrGroup;
    OFTitleLog(@"hDemand",@"\n%@%@%@%@%@%@ from%@:%@ %d",fltLog1,fltLog2,FltLog4HDemandOfYouPiGuo(@"1"),FltLog4XueBanYun(1),FltLog4YonBanYun(1),Pit2FStr(algModel.content_p),targetFo.isH?@"H":@"R",Pit2FStr(targetFo.cansetTo),targetFo.isInfected);
    [HDemandModel newWithAlgModel:algModel];
    dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
        [theTV updateFrame];
    });
    
    //log
    //ReasonDemandModel *root = (ReasonDemandModel*)[TOUtils getRootDemandModelWithSubOutModel:algModel];
    //if (root) NSLog(@"fltx3生成HDemand成功 TCPlan从ROOT:%@ (%@) %@",Pit2FStr(root.protoFo),[SMGUtils date2Str:kHHmmss timeInterval:root.initTime],[TOModelVision cur2Sub:root]);
    
    //2. 调用TCScore继续决策;
    DebugE();
    [TCPlan planFromIfTCNeed];
}

@end
