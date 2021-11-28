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
+(void) rSolution:(ReasonDemandModel*)demand{
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

+(void) hSolution:(HDemandModel*)hDemand{
    //3. 数据检查curAlg
    TOAlgModel *algModel = hDemand.algModel;
    AIAlgNodeBase *curAlg = [SMGUtils searchNode:algModel.content_p];
    OFTitleLog(@"行为化_Hav", @"\nC:%@",Alg2FStr(curAlg));
    
    //TODOTOMORROW20211125: PM废弃 & HN暂不废弃;
    //1. 此处废除mIsC判断,因为PM废除,mIsC不再需要,而短时记忆树里的任何cutIndex已发生的部分,都可用于帮助cHav取解决方案;
    //2. cHav取到的结果sulutionFo做为理性子任务,然后将HNFo的末位,传到TO.regroup(),然后inReflect...
    //3. 此处HN内类比先不废弃,先这么写,等后面再考虑废弃之 (参考24171-3);
    
    
    
    //5. 去掉不应期 (以下两种用哪个留哪个);
    NSArray *except_ps = TOModels2Pits([SMGUtils filterArr:algModel.subModels checkValid:^BOOL(TOModelBase *item) {
        return item.status == TOModelStatus_ActNo;
    }]);
    NSArray *except_ps2 = [TOUtils convertPointersFromTOModels:algModel.actionFoModels];
    
    //4. 第3级: 数据检查hAlg_根据type和value_p找ATHav
    AIKVPointer *relativeFo_p = [AINetService getInnerV3_HN:curAlg aAT:algModel.content_p.algsType aDS:algModel.content_p.dataSource type:ATHav except_ps:except_ps];
    if (Log4ActHav) NSLog(@"getInnerAlg(有): 根据:%@ 找:%@_%@ \n联想结果:%@ %@",Alg2FStr(curAlg),algModel.content_p.algsType,algModel.content_p.dataSource,Pit2FStr(relativeFo_p),relativeFo_p ? @"↓↓↓↓↓↓↓↓" : @"无计可施");
    
    //6. 只要有善可尝试的方式,即从首条开始尝试;
    if (relativeFo_p) {
        TOFoModel *foModel = [TOFoModel newWithFo_p:relativeFo_p base:algModel];
        [self.delegate toAction_SubModelBegin:foModel];
        
        //TODOTOMORROW20211125: 将jump跳转到TI中做为新的输入流程 (并进行识别in反思);
        //1. jump通过后,此处转action();
        
        [TOAction action:foModel];
    }else{
        
        //10. 所有mModel都没成功行为化一条,则失败 (无计可施);
        hDemand.status = TOModelStatus_ActNo;
        //TODOTOMORROW20211128: 没有任何H经验时,递归到上一轮demand;
        
        
    }
}

@end
