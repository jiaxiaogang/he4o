//
//  TCSolution.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCSolution.h"
#import "DemandManager.h"
#import "ReasonDemandModel.h"
#import "AIMatchFoModel.h"
#import "AINetUtils.h"
#import "RSResultModelBase.h"

@implementation TCSolution

/**
 *  MARK:--------------------新螺旋架构solution方法--------------------
 *  @desc 参考24203;
 *  @param endScore : 末枝S方案的综合评分;
 */
+(void) solution:(TOFoModel*)endBranch endScore:(double)endScore{
    //1. 数据准备;
    DemandModel *endDemand = (DemandModel*)endBranch.baseOrGroup;
    
    //2. endBranch >= 0分时,执行TCAction (参考24203-1);
    if (endScore >= 0) {
        [TCAction action:endBranch];
    }else{
        //3. endBranch < 0分时,且末枝S小于3条,执行TCSolution取下一方案 (参考24203-2);
        if (endDemand.actionFoModels.count < cTCSolutionBranchLimit) {
            
            //4. 无更多S时_直接TCAction行为化 (参考24203-2b);
            if (endDemand.status == TOModelStatus_WithOut) {
                [TCAction action:endBranch];
            }else{
                //5. 尝试取更多S;
                if (ISOK(endDemand, ReasonDemandModel.class)) {
                    //6. R任务继续取解决方案 (参考24203-2);
                    [self rSolution:(ReasonDemandModel*)endDemand oldBestSolution:endBranch];
                }else if (ISOK(endDemand, PerceptDemandModel.class)) {
                    //7. P任务继续取解决方案 (参考24203-2);
                    [self pSolution:endDemand];
                }else if (ISOK(endDemand, HDemandModel.class)) {
                    //8. H任务继续取解决方案 (参考24203-2);
                    [self hSolution:endDemand];
                }
            }
        }else{
            //9. endBranch < 0分时,且末枝S达到3条时,则最优执行TCAction (参考24203-3);
            [TCAction action:endBranch];
        }
    }
}

/**
 *  MARK:--------------------rSolution--------------------
 *  @desc 参考24154-单轮;
 *  @version
 *      2021.11.13: 初版,废弃dsFo,并将reasonSubV5由TOR迁移至此RAction中 (参考24101-第3阶段);
 *      2021.11.25: 迭代为功能架构 (参考24154-单轮示图);
 *  @callers : 用于RDemand.Begin时调用;
 */
+(void) rSolution:(ReasonDemandModel*)demand oldBestSolution:(TOFoModel*)oldBestSolution{
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
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        TOFoModel *foModel = [TOFoModel newWithFo_p:firstResult.baseFo.pointer base:demand];
        NSLog(@"------->>>>>> R- 新增一例解决方案: %@->%@ FRS_PK评分:%.2f",Fo2FStr(firstResult.baseFo),Mvp2Str(firstResult.baseFo.cmvNode_p),firstResult.score);
        [TCAction rAction:foModel];
    }else{
        //b) 下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
        demand.status = TOModelStatus_WithOut;
        [TCScore score];
        NSLog(@"------->>>>>> R-无计可施");
    }
}

/**
 *  MARK:-------------------- pSolution --------------------
 *  @desc
 *      1. 简介: mv方向索引找正价值解决方案;
 *      2. 实例: 饿了,现有面粉,做面吃可以解决;
 *      3. 步骤: 用A.refPorts ∩ F.conPorts (参考P+模式模型图);
 *      4. 联想方式: 参考19192示图 (此行为后补注释);
 *  @todo :
 *      1. 集成原有的能量判断与消耗 T;
 *      2. 评价机制1: 比如土豆我超不爱吃,在mvScheme中评价,入不应期,并继续下轮循环;
 *      3. 评价机制2: 比如炒土豆好麻烦,在行为化中反思评价,入不应期,并继续下轮循环;
 *  @version
 *      2020.05.27: 将isOut=false时等待改成进行cHav行为化;
 *      2020.06.10: 索引解决方案:去除fo的不应期,因为不应期应针对mv,而fo的不应期是针对此处取得fo及其具象conPorts.fos的,所以将fo不应期前置了;
 *      2020.07.23: 联想方式迭代至V2_将19192示图的联想方式去掉,仅将方向索引除去不应期的返回,而解决方案到底是否实用,放到行为化中去判断;
 *      2020.09.23: 取消参数matchAlg (最近识别的M),如果今后还要使用短时优先功能,直接从theTC.shortManager取);
 *      2020.09.23: 只要得到解决方案,就返回true中断,因为即使行为化失败,也会交由流程控制继续决策,而非由此处处理;
 *      2020.12.17: 将此方法,归由流程控制控制 (跑下来逻辑与原来没啥不同);
 *  @bug
 *      1. 查点击马上饿,找不到解决方案的BUG,经查,MatchAlg与解决方案无明确关系,但MatchAlg.conPorts中,有与解决方案有直接关系的,改后解决 (参考20073)
 *      2020.07.09: 修改方向索引的解决方案不应期,解决只持续飞行两次就停住的BUG (参考n20p8-BUG1);
 */
+(void) pSolution:(DemandModel*)demandModel{
    //1. 数据准备;
    MVDirection direction = [ThinkingUtils getDemandDirection:demandModel.algsType delta:demandModel.delta];
    if (!Switch4PS || direction == MVDirection_None) return;
    OFTitleLog(@"TOP.P-", @"\n任务:%@,发生%ld,方向%ld",demandModel.algsType,(long)demandModel.delta,(long)direction);
    
    //2. =======以下: 调用通用diff模式方法 (以下代码全是由diff模式方法迁移而来);
    //3. 不应期
    NSArray *exceptFoModels = [SMGUtils filterArr:demandModel.actionFoModels checkValid:^BOOL(TOModelBase *item) {
        return item.status == TOModelStatus_ActNo || item.status == TOModelStatus_ScoreNo || item.status == TOModelStatus_ActYes;
    }];
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:exceptFoModels];
    if (Log4DirecRef) NSLog(@"------->>>>>> Fo已有方案数:%lu 不应期数:%lu",(long)demandModel.actionFoModels.count,(long)except_ps.count);
    
    //3. =======以下: 调用方向索引,找解决方案代码
    //2. 方向索引,用方向索引找normalFo解决方案 (P例:饿了,该怎么办 S例:累了,肿么肥事);
    NSArray *mvRefs = [theNet getNetNodePointersFromDirectionReference:demandModel.algsType direction:direction isMem:false filter:nil];
    
    //4. debugLog
    if (Log4DirecRef){
        for (NSInteger i = 0; i < 10; i++) {
            AIPort *item = ARR_INDEX(mvRefs, i);
            AICMVNodeBase *itemMV = [SMGUtils searchNode:item.target_p];
            if (item && itemMV && itemMV.foNode_p) NSLog(@"item-> 强度:%ld 方案:%@->%@",(long)item.strong.value,FoP2FStr(itemMV.foNode_p),Mv2FStr(itemMV));
        }
    }
    
    //3. 逐个返回;
    for (AIPort *item in mvRefs) {
        //a. analogyType处理 (仅支持normal的fo);
        AICMVNodeBase *itemMV = [SMGUtils searchNode:item.target_p];
        AnalogyType foType = itemMV.foNode_p.type;
        if (ATPlus != foType && ATSub != foType) {
            if (Log4DirecRef) NSLog(@"方向索引_尝试_索引强度:%ld 方案:%@",item.strong.value,FoP2FStr(itemMV.foNode_p));
            
            //5. 方向索引找到一条normalFo解决方案 (P例:吃可以解决饿; S例:运动导致累);
            if (![except_ps containsObject:itemMV.foNode_p]) {
                //8. 消耗活跃度;
                [theTC updateEnergy:-2];
                AIFoNodeBase *fo = [SMGUtils searchNode:itemMV.foNode_p];
                
                //a. 构建TOFoModel
                TOFoModel *toFoModel = [TOFoModel newWithFo_p:fo.pointer base:demandModel];
                
                //b. 取自身,实现吃,则可不饿 (提交C给TOR行为化);
                //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
                NSLog(@"------->>>>>> P-新增一例解决方案: %@->%@",Fo2FStr(fo),Mvp2Str(fo.cmvNode_p));
                [TCAction action:toFoModel];//[theTOR singleLoopBackWithBegin:toFoModel];
                
                //8. 只要有一次tryResult成功,中断回调循环;
                return;
            }
        }
    }
    
    //9. 无计可施,下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
    demandModel.status = TOModelStatus_WithOut;
    [TCScore score];
}

/**
 *  MARK:--------------------hSolution--------------------
 *  @version
 *      2021.11.25: 由旧有action._Hav第3级迁移而来;
 */
+(void) hSolution:(HDemandModel*)hDemand{
    //3. 数据检查curAlg
    TOAlgModel *algModel = (TOAlgModel*)hDemand.baseOrGroup;
    AIAlgNodeBase *curAlg = [SMGUtils searchNode:algModel.content_p];
    OFTitleLog(@"行为化_Hav", @"\nC:%@",Alg2FStr(curAlg));
    
    //-------TODOTOMORROW20211125: PM废弃 & HN暂不废弃;
    //1. 此处废除mIsC判断,因为PM废除,mIsC不再需要,而短时记忆树里的任何cutIndex已发生的部分,都可用于帮助cHav取解决方案;
    //2. cHav取到的结果sulutionFo做为理性子任务,然后将HNFo的末位,传到TO.regroup(),然后inReflect...
    //3. 此处HN内类比先不废弃,先这么写,等后面再考虑废弃之 (参考24171-3);
    //4. 可将当前瞬时记忆序列做为mask进行cHav联想 (比如在家时,不会想到点外卖,在工作地就首先想到外卖);
    
    
    
    //5. 取不应期;
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:algModel.actionFoModels];
    
    //4. 第3级: 数据检查hAlg_根据type和value_p找ATHav
    AIKVPointer *relativeFo_p = [AINetService getInnerV3_HN:curAlg aAT:algModel.content_p.algsType aDS:algModel.content_p.dataSource type:ATHav except_ps:except_ps];
    if (Log4ActHav) NSLog(@"getInnerAlg(有): 根据:%@ 找:%@_%@ \n联想结果:%@ %@",Alg2FStr(curAlg),algModel.content_p.algsType,algModel.content_p.dataSource,Pit2FStr(relativeFo_p),relativeFo_p ? @"↓↓↓↓↓↓↓↓" : @"无计可施");
    
    //6. 只要有善可尝试的方式,即从首条开始尝试;
    if (relativeFo_p) {
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        TOFoModel *foModel = [TOFoModel newWithFo_p:relativeFo_p base:hDemand];
        [TCAction hAction:foModel];
    }else{
        //b) 无计可施,下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
        hDemand.status = TOModelStatus_WithOut;
        [TCScore score];
    }
}

@end
