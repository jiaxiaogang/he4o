//
//  AIActionReason.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/11.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIActionReason.h"
#import "ReasonDemandModel.h"
#import "AIMatchFoModel.h"
#import "AINetUtils.h"
#import "AIPort.h"
#import "TOFoModel.h"
#import "DemandManager.h"
#import "RSResultModelBase.h"
#import "AIThinkOut.h"
#import "AIThinkOutReason.h"

@implementation AIActionReason

/**
 *  MARK:--------------------RDemand行为化--------------------
 *  @version
 *      2021.11.13: 初版,废弃dsFo,并将reasonSubV5由TOR迁移至此RAction中 (参考24101-第3阶段);
 */
-(void) convert2Out_Demand:(ReasonDemandModel*)demand{
    //1. 根据demand取抽具象路径rs;
    NSArray *rs = [theTC.outModelManager getRDemandsBySameClass:demand];
    
    //2. 不应期 (可以考虑改为将整个demand.actionFoModels全加入不应期) (不应期源于反思评价为否 & 且反思子任务也失败的);
    NSArray *exceptFoModels = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOModelBase *item) {
        return item.status == TOModelStatus_ActNo || item.status == TOModelStatus_ScoreNo;
    }];
    NSMutableArray *except_ps = [TOUtils convertPointersFromTOModels:exceptFoModels];
    [except_ps addObject:demand.mModel.matchFo.pointer];
    
    //3. 从具象出抽象,逐一取conPorts (前3条) (参考24127-步骤1);
    NSMutableArray *sumConPorts = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < rs.count; i++) {
        ReasonDemandModel *baseDemand = ARR_INDEX_REVERSE(rs, i);
        NSArray *conPorts = [AINetUtils conPorts_All_Normal:baseDemand.mModel.matchFo];
        conPorts = ARR_SUB(conPorts, 0, 3);
        [sumConPorts addObjectsFromArray:conPorts];
    }
    
    //4. 对conPorts进行FRS稳定性竞争 (参考24127-步骤2);
    NSArray *frsResults = [AIScore FRS_PK:sumConPorts];
    
    //5. frsResults排除不应期;
    frsResults = [SMGUtils removeArr:frsResults checkValid:^BOOL(RSResultModelBase *item) {
        return [except_ps containsObject:item.baseFo.pointer];
    }];
    if (Log4DirecRef) NSLog(@"\n------- baseFo:%@ -------\n已有方案数:%ld 不应期数:%ld 还有方案数:%ld",Fo2FStr(demand.mModel.matchFo),demand.actionFoModels.count,except_ps.count,frsResults.count);
    
    //6. 转流程控制_有解决方案则转begin;
    RSResultModelBase *firstResult = ARR_INDEX(frsResults, 0);
    if (firstResult) {
        TOFoModel *foModel = [TOFoModel newWithFo_p:firstResult.baseFo.pointer base:demand];
        NSLog(@"------->>>>>> R- 新增一例解决方案: %@->%@ FRS_PK评分:%.2f",Fo2FStr(firstResult.baseFo),Mvp2Str(firstResult.baseFo.cmvNode_p),firstResult.score);
        [theTC.thinkOut.tOR singleLoopBackWithBegin:foModel];
    }else{
        //7. 转流程控制_无则转failure;
        demand.status = TOModelStatus_ActNo;
        [theTC.thinkOut.tOR singleLoopBackWithFailureModel:demand];
        NSLog(@"------->>>>>> R-无计可施");
    }
}

/**
 *  MARK:--------------------Fo行为化--------------------
 *  @desc 解决方案fo即(加工目标),转_Fo()行为化 (参考24132-行为化1);
 */
-(void) convert2Out_Fo:(AIFoNodeBase*)fo{
    //a. 对首条解决方案,进行行为化_Fo();
    
    //b. 在_Fo()中,进行反思;
    
    //c. 反思不通过的形成子任务;
    
    //d. 子任务再失败的,此解决方案改为actNo (计为不应期);
    
    //e. 反思通过的,直接转_Hav行为化;
}

@end
