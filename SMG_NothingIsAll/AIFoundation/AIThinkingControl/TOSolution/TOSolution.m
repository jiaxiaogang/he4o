//
//  TOSolution.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TOSolution.h"
#import "DemandManager.h"
#import "ReasonDemandModel.h"
#import "AIMatchFoModel.h"
#import "AINetUtils.h"
#import "RSResultModelBase.h"

@implementation TOSolution


/**
 *  MARK:--------------------solution--------------------
 *  @desc 参考24154-单轮;
 *  @version
 *      2021.11.13: 初版,废弃dsFo,并将reasonSubV5由TOR迁移至此RAction中 (参考24101-第3阶段);
 *      2021.11.25: 迭代为功能架构 (参考24154-单轮示图);
 *  @callers : 用于RDemand.Begin时调用;
 */
-(void) solution:(ReasonDemandModel*)demand{
    //1. 根据demand取抽具象路径rs;
    NSArray *rs = [theTC.outModelManager getRDemandsBySameClass:demand];
    
    //2. 不应期 (可以考虑改为将整个demand.actionFoModels全加入不应期) (源于:反思且子任务失败的 或 fo行为化最终失败的,参考24135);
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
        [TOAction action:foModel];
    }else{
        //7. 转流程控制_无则转failure;
        demand.status = TOModelStatus_ActNo;
        [theTC.thinkOut.tOR singleLoopBackWithFailureModel:demand];
        
        //TODOTOMORROW20211125: 向base上一轮递归,
        
        
        
        NSLog(@"------->>>>>> R-无计可施");
    }
}

@end
