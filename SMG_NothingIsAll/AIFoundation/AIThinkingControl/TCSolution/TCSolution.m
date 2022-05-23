//
//  TCSolution.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCSolution.h"

@implementation TCSolution

/**
 *  MARK:--------------------新螺旋架构solution方法--------------------
 *  @desc 参考24203;
 *  @param endScore : 当传入endBranch为solutionFo时,endScore为:末枝S方案的综合评分;
 *  @version
 *      2021.12.28: 对首条S的支持 (参考25042);
 *      2021.12.28: 支持actYes时最优路径末枝为nil,并中止决策 (参考25042-3);
 */
+(void) solution:(TOModelBase*)endBranch endScore:(double)endScore{
    //1. 无末枝时 (可能正在ActYes等待状态),中断决策;
    if (!endBranch) return;
    //2. 尝试取更多S;
    Act1 runSolutionAct = ^(DemandModel *demand){
        if (ISOK(demand, ReasonDemandModel.class)) {
            //a. R任务继续取解决方案 (参考24203-2);
            [self rSolution:(ReasonDemandModel*)demand];
        }else if (ISOK(demand, PerceptDemandModel.class)) {
            //b. P任务继续取解决方案 (参考24203-2);
            [self pSolution:demand];
        }else if (ISOK(demand, HDemandModel.class)) {
            //c. H任务继续取解决方案 (参考24203-2);
            [self hSolution:(HDemandModel*)demand];
        }
    };
    
    //3. 传入solutionFo时;
    if (ISOK(endBranch, TOFoModel.class)) {
        DemandModel *baseDemand = (DemandModel*)endBranch.baseOrGroup;
        TOFoModel *solutionFo = (TOFoModel*)endBranch;
        
        //4. endBranch >= 0分时,执行TCAction (参考24203-1);
        if (endScore > 0) [TCAction action:solutionFo];
        
        //5. 无更多S时_直接TCAction行为化 (参考24203-2b);
        else if(baseDemand.status == TOModelStatus_WithOut) [TCAction action:solutionFo];
        
        //6. 末枝S达到3条时,则最优执行TCAction (参考24203-3);
        else if(baseDemand.actionFoModels.count >= cSolutionNarrowLimit) [TCAction action:solutionFo];
        
        //7. endBranch < 0分时,且末枝S小于3条,执行TCSolution取下一方案 (参考24203-2);
        else if (baseDemand.status != TOModelStatus_WithOut && baseDemand.actionFoModels.count < cSolutionNarrowLimit) runSolutionAct(baseDemand);
    }
    
    //8. 传入demand时,且demand还可继续时,尝试执行TCSolution取下一方案 (参考24203);
    if (ISOK(endBranch, DemandModel.class)) {
        if (endBranch.status != TOModelStatus_ActNo && endBranch.status != TOModelStatus_ActYes && endBranch.status != TOModelStatus_WithOut) {
            runSolutionAct((DemandModel*)endBranch);
        }
    }
}

/**
 *  MARK:--------------------rSolution--------------------
 *  @desc 参考24154-单轮;
 *  @version
 *      2021.11.13: 初版,废弃dsFo,并将reasonSubV5由TOR迁移至此RAction中 (参考24101-第3阶段);
 *      2021.11.15: R任务FRS稳定性竞争,评分越高的场景排越前 (参考24127-2);
 *      2021.11.25: 迭代为功能架构 (参考24154-单轮示图);
 *      2021.12.25: 将FRS稳定性竞争废弃,改为仅取bestSP评分,取最稳定的一条 (参考25032-4);
 *      2021.12.28: 将抽具象路径rs改为从pFos中取同标识mv部分 (参考25051);
 *      2022.01.07: 改为将整个demand.actionFoModels全加入不应期 (因为还在决策中的S会重复);
 *      2022.01.09: 达到limit条时的处理;
 *      2022.01.19: 将时间不急评价封装为FRS_Time() (参考25106);
 *      2022.03.06: 当稳定性综评为0分时,不做为解决方案 (参考25131-思路2);
 *      2022.03.09: 将conPorts取前3条改成15条 (参考25144);
 *      2022.05.01: 废弃从等价demands下取解决方案 (参考25236);
 *      2022.05.04: 树限宽也限深 (参考2523c-分析代码1);
 *      2022.05.18: 改成多个pFos下的解决方案进行竞争 (参考26042-TODO3);
 *      2022.05.20: 过滤掉负价值不做为解决方案 (参考26063);
 *      2022.05.21: 窄出排序方式,以效用分为准 (参考26077-方案);
 *      2022.05.21: 窄出排序方式,退回到以SP稳定性排序 (参考26084);
 *      2022.05.22: 窄出排序方式,改为有效率排序 (参考26095-9);
 *  @callers : 用于RDemand.Begin时调用;
 */
+(void) rSolution:(ReasonDemandModel*)demand {
    //0. S数达到limit时设为WithOut;
    OFTitleLog(@"rSolution", @"\n任务源:%@ 已有方案数:%ld",demand.algsType,demand.actionFoModels.count);
    
    //1. 树限宽且限深;
    NSInteger deepCount = [TOUtils getBaseDemandsDeepCount:demand];
    if (deepCount >= cDemandDeepLimit || demand.actionFoModels.count >= cSolutionNarrowLimit) {
        demand.status = TOModelStatus_WithOut;
        [TCScore score];
        NSLog(@">>>>>> rSolution 已达limit条 (S数:%ld 层数:%ld)",demand.actionFoModels.count,deepCount);
        return;
    }
    [theTC updateOperCount];
    Debug();
    
    //2. 不应期 (可以考虑) (源于:反思且子任务失败的 或 fo行为化最终失败的,参考24135);
    NSMutableArray *except_ps = [TOUtils convertPointersFromTOModels:demand.actionFoModels];
    [except_ps addObjectsFromArray:[SMGUtils convertArr:demand.pFos convertBlock:^id(AIMatchFoModel *obj) {
        return obj.matchFo;
    }]];
    
    //3. 取demand.conPorts (前15条) (参考24127-步骤1);
    AIFoNodeBase *bestResult = nil;
    CGFloat bestEffectScore = 0;
    AIFoNodeBase *bestDicFo = nil;//bestResult的有效率字典所在fo;
    for (AIMatchFoModel *pFo in demand.pFos) {
        
        //3. 每个pFo取10条候选解决方案;
        AIFoNodeBase *fo = [SMGUtils searchNode:pFo.matchFo];
        NSArray *conPorts = [AINetUtils conPorts_All_Normal:fo];
        conPorts = ARR_SUB(conPorts, 0, 10);
        
        //4. 从conPorts中找出最优秀的result (稳定性竞争) (参考24127-步骤2);
        for (AIPort *maskPort in conPorts) {
            //5. 排除不应期;
            if ([except_ps containsObject:maskPort.target_p]) continue;
            AIFoNodeBase *maskFo = [SMGUtils searchNode:maskPort.target_p];
            
            //6. 负价值不做为解决方案 (参考26063);
            if ([ThinkingUtils havDemand:maskFo.cmvNode_p]) continue;
            
            //6. 时间不急评价: 不急 = 解决方案所需时间 <= 父任务能给的时间 (参考:24057-方案3,24171-7);
            if (![AIScore FRS_Time:pFo solutionFo:maskFo]) continue;
            
            //6. 判断SP评分;
            CGFloat checkEffectScore = [TOUtils getEffectScore:fo effectIndex:fo.count solutionFo:maskFo.pointer];
            if (Log4Solution) NSLog(@"checkResult:(有效率:%.2f) %@ %@",checkEffectScore,Fo2FStr(maskFo),Mvp2Str(maskFo.cmvNode_p));
            
            //7. 当best为空 或 check评分比best更高时 => 将check赋值到best;
            if(!bestResult || checkEffectScore > bestEffectScore){
                bestResult = maskFo;
                bestDicFo = fo;
                bestEffectScore = checkEffectScore;
            }
        }
    }
    
    //6. 转流程控制_有解决方案则转begin;
    DebugE();
    if (bestResult) {
        //7. 消耗活跃度;
        if (![theTC energyValid]) return;
        [theTC updateEnergyDelta:-1];
        
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        TOFoModel *foModel = [TOFoModel newWithFo_p:bestResult.pointer base:demand];
        NSString *effectDesc = [TOUtils getEffectDesc:bestDicFo effectIndex:bestDicFo.count solutionFo:bestResult.pointer];
        NSLog(@">>>>>> rSolution 新增第%ld例解决方案: %@->%@ (有效率:%.2f = %@)",demand.actionFoModels.count, Fo2FStr(bestResult),Mvp2Str(bestResult.cmvNode_p),bestEffectScore,effectDesc);
        
        //a) 有效率
        [TCEffect rEffect:foModel];
        [theTV updateFrame];
        [TCAction action:foModel];
    }else{
        //b) 下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
        demand.status = TOModelStatus_WithOut;
        NSLog(@">>>>>> rSolution 无计可施");
        [TCScore score];
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
 *      2022.05.04: 树限宽也限深 (参考2523c-分析代码1);
 *  @bug
 *      1. 查点击马上饿,找不到解决方案的BUG,经查,MatchAlg与解决方案无明确关系,但MatchAlg.conPorts中,有与解决方案有直接关系的,改后解决 (参考20073)
 *      2020.07.09: 修改方向索引的解决方案不应期,解决只持续飞行两次就停住的BUG (参考n20p8-BUG1);
 */
+(void) pSolution:(DemandModel*)demandModel{
    //1. 数据准备;
    //TODO: 2021.12.29: 此处方向索引,可以改成和rh任务一样的从pFos&rFos中取具象得来 (因为方向索引应该算脱离场景);
    MVDirection direction = [ThinkingUtils getDemandDirection:demandModel.algsType delta:demandModel.delta];
    if (!Switch4PS || direction == MVDirection_None) return;
    OFTitleLog(@"pSolution", @"\n任务:%@,发生%ld,方向%ld,已有方案数:%ld",demandModel.algsType,(long)demandModel.delta,(long)direction,demandModel.actionFoModels.count);
    
    //1. 树限宽且限深;
    NSInteger deepCount = [TOUtils getBaseDemandsDeepCount:demandModel];
    if (deepCount >= cDemandDeepLimit || demandModel.actionFoModels.count >= cSolutionNarrowLimit) {
        demandModel.status = TOModelStatus_WithOut;
        [TCScore score];
        NSLog(@"------->>>>>> pSolution 已达limit条");
        return;
    }
    [theTC updateOperCount];
    Debug();
    
    //2. =======以下: 调用通用diff模式方法 (以下代码全是由diff模式方法迁移而来);
    //3. 不应期 (考虑改为所有actionFoModels都不应期);
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
                if (![theTC energyValid]) return;
                [theTC updateEnergyDelta:-1];
                AIFoNodeBase *fo = [SMGUtils searchNode:itemMV.foNode_p];
                
                //a. 构建TOFoModel
                TOFoModel *toFoModel = [TOFoModel newWithFo_p:fo.pointer base:demandModel];
                
                //b. 取自身,实现吃,则可不饿 (提交C给TOR行为化);
                //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
                NSLog(@">>>>>> pSolution 新增第%ld例解决方案: %@->%@",demandModel.actionFoModels.count,Fo2FStr(fo),Mvp2Str(fo.cmvNode_p));
                [theTV updateFrame];
                DebugE();
                [TCAction action:toFoModel];//[theTOR singleLoopBackWithBegin:toFoModel];
                
                //8. 只要有一次tryResult成功,中断回调循环;
                return;
            }
        }
    }
    
    //9. 无计可施,下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
    DebugE();
    demandModel.status = TOModelStatus_WithOut;
    NSLog(@">>>>>> pSolution 无计可施");
    [TCScore score];
}

/**
 *  MARK:--------------------hSolution--------------------
 *  @desc 找hSolution解决方案 (参考25014-H & 25015-6);
 *  _param endBranch : hDemand目标alg所在的fo (即hDemand.baseA.baseF);
 *  @version
 *      2021.11.25: 由旧有action._Hav第3级迁移而来;
 *      2021.12.25: 迭代hSolution (参考25014-H & 25015-6);
 *      2022.01.09: 达到limit条时的处理;
 *      2022.01.09: 首条就是HAlg不能做H解决方案 (参考25057);
 *      2022.05.04: 树限宽也限深 (参考2523c-分析代码1);
 *      2022.05.22: 窄出排序方式改为有效率为准 (参考26095-9);
 */
+(void) hSolution:(HDemandModel*)hDemand{
    //0. S数达到limit时设为WithOut;
    OFTitleLog(@"hSolution", @"\n目标:%@ 已有S数:%ld",Pit2FStr(hDemand.baseOrGroup.content_p),hDemand.actionFoModels.count);
    
    //1. 树限宽且限深;
    NSInteger deepCount = [TOUtils getBaseDemandsDeepCount:hDemand];
    if (deepCount >= cDemandDeepLimit || hDemand.actionFoModels.count >= cSolutionNarrowLimit) {
        hDemand.status = TOModelStatus_WithOut;
        [TCScore score];
        NSLog(@"------->>>>>> hSolution 已达limit条");
        return;
    }
    [theTC updateOperCount];
    Debug();
    
    //1. 数据准备;
    AIAlgNodeBase *targetAlg = [SMGUtils searchNode:hDemand.baseOrGroup.content_p];
    TOFoModel *targetFoModel = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoModel.content_p];
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:hDemand.actionFoModels];
    
    //2. 取自身 + 向抽象 + 向具象 (目前仅取一层,如果发现一层不够,可以改为取多层) (参考25014-H描述);
    NSMutableArray *maskFos = [[NSMutableArray alloc] init];
    [maskFos addObject:targetFo.pointer];
    [maskFos addObjectsFromArray:Ports2Pits([AINetUtils absPorts_All_Normal:targetFo])];
    [maskFos addObjectsFromArray:Ports2Pits([AINetUtils conPorts_All_Normal:targetFo])];
    
    //3. 从maskFos中找出最优秀的result;
    AIFoNodeBase *bestResult = nil;
    NSInteger bestSPIndex = 0;
    CGFloat bestEffectScore = 0;
    for (AIKVPointer *maskFo_p in maskFos) {
        
        //4. 排除不应期;
        if ([except_ps containsObject:maskFo_p]) continue;
        
        //5. 从maskFo中找targetAlg (找targetAlg 或 其抽具象概念);
        AIFoNodeBase *maskFo = [SMGUtils searchNode:maskFo_p];
        NSInteger spIndex = [TOUtils indexOfConOrAbsItem:targetAlg.pointer atContent:maskFo.content_ps layerDiff:1 startIndex:0 endIndex:NSUIntegerMax];
        
        //6. 如>0则找到 (HAlg不能是首条)_则判断SP评分 (参考25057);
        if (spIndex > 0) {
            CGFloat checkEffectScore = [TOUtils getEffectScore:targetFo effectIndex:targetFoModel.actionIndex solutionFo:maskFo_p];
            
            //7. 当best为空 或 check评分比best更高时 => 将check赋值到best;
            if(!bestResult || checkEffectScore > bestEffectScore){
                bestResult = maskFo;
                bestSPIndex = spIndex;
                bestEffectScore = checkEffectScore;
            }
        }
    }
    
    //8. 新解决方案_的结果处理;
    DebugE();
    if (bestResult) {
        //8. 消耗活跃度;
        if (![theTC energyValid]) return;
        [theTC updateEnergyDelta:-1];
        
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        TOFoModel *foModel = [TOFoModel newWithFo_p:bestResult.pointer base:hDemand];
        foModel.targetSPIndex = bestSPIndex;
        NSString *effectDesc = [TOUtils getEffectDesc:targetFo effectIndex:targetFoModel.actionIndex solutionFo:bestResult.pointer];
        NSLog(@">>>>>> hSolution 新增第%ld例解决方案: %@->%@ (有效率:%.2f = %@) targetSPIndex:%ld",hDemand.actionFoModels.count,Fo2FStr(bestResult),Mvp2Str(bestResult.cmvNode_p),bestEffectScore,effectDesc,foModel.targetSPIndex);
        
        //a) 有效率;
        [TCEffect hEffect:foModel];
        [theTV updateFrame];
        [TCAction action:foModel];
    }else{
        //b) 下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
        hDemand.status = TOModelStatus_WithOut;
        NSLog(@">>>>>> hSolution 无计可施");
        [TCScore score];
    }
}

@end
