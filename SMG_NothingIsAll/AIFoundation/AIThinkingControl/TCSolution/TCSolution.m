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
 *      2022.06.02: 如果endBranch的末枝正在等待actYes,则继续等待,不进行决策 (参考26185-TODO4);
 *      2024.02.04: Cansets实时竞争放到TCPlan中了,此处实时竞争的代码删掉;
 */
+(TCResult*) solution:(TOModelBase*)endBranch endScore:(double)endScore{
    //1. 无末枝时 (可能正在ActYes等待状态),中断决策;
    if (!endBranch) return [[[TCResult new:false] mkMsg:@"无末枝"] mkStep:11];
    
    //2. 判断endBranch如果是actYes状态,则不处理,继续静默;
    BOOL endHavActYes = [TOUtils endHavActYes:endBranch];
    if (endHavActYes) return [[[TCResult new:false] mkMsg:@"末枝ActYes状态"] mkStep:12];
    
    //3. 传入solutionFo时: 直接执行action();
    if (ISOK(endBranch, TOFoModel.class)) {
        TOFoModel *actionFo = (TOFoModel*)endBranch;
        return [TCAction action:actionFo];
    }
    
    //4. 传入demand时,且demand还可继续时,尝试执行TCSolution取下一方案 (参考24203);
    if (ISOK(endBranch, DemandModel.class)) {
        //5. 任务状态已失败不应再决策
        if (endBranch.status == TOModelStatus_ActNo || endBranch.status == TOModelStatus_ActYes || endBranch.status == TOModelStatus_WithOut) {
            return [[[TCResult new:false] mkMsg:@"任务状态已失败不应再决策"] mkStep:13];
        }
        
        //6. 分发到xSolution(): 初始化Cansets & 行为化;
        if (ISOK(endBranch, ReasonDemandModel.class)) {
            //a. R任务继续取解决方案 (参考24203-2);
            return [self rSolution:(ReasonDemandModel*)endBranch];
        }else if (ISOK(endBranch, PerceptDemandModel.class)) {
            //b. P任务继续取解决方案 (参考24203-2);
            return [self pSolution:(PerceptDemandModel*)endBranch];
        }else if (ISOK(endBranch, HDemandModel.class)) {
            //c. H任务继续取解决方案 (参考24203-2);
            return [self hSolution:(HDemandModel*)endBranch];
        }
        return [[[TCResult new:false] mkMsg:@"solution 任务类型不同RPH任一种"] mkStep:14];
    }
    return [[[TCResult new:false] mkMsg:@"solution末枝非foModel也非demandModel"] mkStep:15];
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
 *      2022.05.27: 集成新的取S的方法 (参考26128);
 *      2022.05.27: 新解决方案从cutIndex开始行为化,而不是-1 (参考26127-TODO9);
 *      2022.05.29: 前3条优先取快思考,后2条或快思考无效时,再取求解 (参考26143-TODO2);
 *      2024.01.23: bestResult由虚转实 (参考31073-TODO2c);
 *  @callers : 用于RDemand.Begin时调用;
 */
+(TCResult*) rSolution:(ReasonDemandModel*)demand {
    //0. S数达到limit时设为WithOut;
    if (![theTC energyValid]) return [[[TCResult new:false] mkMsg:@"rSolution 能量不足"] mkStep:21];
    OFTitleLog(@"rSolution", @"\n任务源:%@ protoFo:%@ 已有方案数:%ld 任务分:%.2f",ClassName2Str(demand.algsType),Pit2FStr(demand.protoOrRegroupFo),demand.actionFoModels.count,[AIScore score4Demand:demand]);
    
    //1. 树限宽且限深;
    NSInteger deepCount = [TOUtils getBaseDemandsDeepCount:demand];
    NSInteger bestCount = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOFoModel *item) {
        return item.cansetStatus == CS_Bested || item.cansetStatus == CS_Besting;
    }].count;
    if (deepCount >= cDemandDeepLimit || bestCount >= cSolutionNarrowLimit) {
        demand.status = TOModelStatus_WithOut;
        [TCScore scoreFromIfTCNeed];
        NSLog(@">>>>>> rSolution 已达limit条 (S数:%ld 层数:%ld)",demand.actionFoModels.count,deepCount);
        return [[[TCResult new:false] mkMsg:@"rSolution > limit"] mkStep:22];
    }
    [theTC updateOperCount:kFILENAME];
    Debug();
    
    //4. 快思考无果或后2条,再做求解;
    TOFoModel *bestResult = [TCSolutionUtil rSolution:demand];

    //6. 转流程控制_有解决方案则转begin;
    DebugE();
    if (bestResult) {
        //7. 消耗活跃度;
        [theTC updateEnergyDelta:-1];
        
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        //c) 调试;
        AIFoNodeBase *sceneFo = [SMGUtils searchNode:bestResult.sceneFo];
        AIEffectStrong *effStrong = [TOUtils getEffectStrong:sceneFo effectIndex:sceneFo.count solutionFo:bestResult.cansetFo];
        NSString *effDesc = effStrong ? effStrong.description : @"";
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:bestResult.cansetFo];
        NSLog(@"> newS 第%ld例: eff:%@ sp:%@ %@ scene:F%ld canset:F%ld (前%.2f 中%.2f 后%.2f)",demand.actionFoModels.count,effDesc,CLEANSTR(cansetFo.spDic),SceneType2Str(bestResult.baseSceneModel.type),sceneFo.pId,cansetFo.pId,bestResult.frontMatchValue,bestResult.midStableScore,bestResult.backMatchValue);
        
        //a) 有效率
        [TCEffect rEffect:bestResult];
        dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
            [theTV updateFrame];
        });
        return [TCAction action:bestResult];
    }else{
        //b) 下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
        demand.status = TOModelStatus_WithOut;
        NSLog(@">>>>>> rSolution 无计可施");
        [TCScore scoreFromIfTCNeed];
        return [[[TCResult new:false] mkMsg:@"rSolution 无计可施"] mkStep:23];
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
+(TCResult*) pSolution:(DemandModel*)demandModel{
    //1. 数据准备;
    //TODO: 2021.12.29: 此处方向索引,可以改成和rh任务一样的从pFos&rFos中取具象得来 (因为方向索引应该算脱离场景);
    MVDirection direction = [ThinkingUtils getDemandDirection:demandModel.algsType delta:demandModel.delta];
    if (!Switch4PS || direction == MVDirection_None) return [[[TCResult new:false] mkMsg:@"pSolution 开关关闭"] mkStep:20];
    if (![theTC energyValid]) return [[[TCResult new:false] mkMsg:@"pSolution 能量不足"] mkStep:21];
    OFTitleLog(@"pSolution", @"\n任务:%@,发生%ld,方向%ld,已有方案数:%ld",demandModel.algsType,(long)demandModel.delta,(long)direction,demandModel.actionFoModels.count);
    
    //1. 树限宽且限深;
    NSInteger deepCount = [TOUtils getBaseDemandsDeepCount:demandModel];
    if (deepCount >= cDemandDeepLimit || demandModel.actionFoModels.count >= cSolutionNarrowLimit) {
        demandModel.status = TOModelStatus_WithOut;
        [TCScore scoreFromIfTCNeed];
        NSLog(@"------->>>>>> pSolution 已达limit条");
        return [[[TCResult new:false] mkMsg:@"pSolution > limit"] mkStep:22];
    }
    [theTC updateOperCount:kFILENAME];
    Debug();
    
    //2. =======以下: 调用通用diff模式方法 (以下代码全是由diff模式方法迁移而来);
    if (Log4DirecRef) NSLog(@"------->>>>>> Fo已有方案数:%lu",(long)demandModel.actionFoModels.count);
    
    //3. =======以下: 调用方向索引,找解决方案代码
    //2. 方向索引,用方向索引找normalFo解决方案 (P例:饿了,该怎么办 S例:累了,肿么肥事);
    NSArray *mvRefs = [theNet getNetNodePointersFromDirectionReference:demandModel.algsType direction:direction filter:nil];
    
    //4. debugLog
    if (Log4DirecRef){
        for (NSInteger i = 0; i < 10; i++) {
            AIPort *item = ARR_INDEX(mvRefs, i);
            AICMVNodeBase *itemMV = [SMGUtils searchNode:item.target_p];
            AIPort *firstFoPort = ARR_INDEX(itemMV.foPorts, 0);
            if (item && itemMV && firstFoPort) NSLog(@"item-> 强度:%ld 方案:%@->%@",(long)item.strong.value,FoP2FStr(firstFoPort.target_p),Mv2FStr(itemMV));
        }
    }
    
    //3. 逐个返回;
    for (AIPort *item in mvRefs) {
        //a. analogyType处理 (仅支持normal的fo);
        AICMVNodeBase *itemMV = [SMGUtils searchNode:item.target_p];
        AIPort *firstFoPort = ARR_INDEX(itemMV.foPorts, 0);
        if (Log4DirecRef) NSLog(@"方向索引_尝试_索引强度:%ld 方案:%@",item.strong.value,FoP2FStr(firstFoPort.target_p));
        
        //5. 方向索引找到一条normalFo解决方案 (P例:吃可以解决饿; S例:运动导致累);
        //8. 消耗活跃度;
        [theTC updateEnergyDelta:-1];
        AIFoNodeBase *fo = [SMGUtils searchNode:firstFoPort.target_p];
        
        //a. 构建TOFoModel
        TOFoModel *toFoModel = nil;//[TOFoModel newWithFo_p:fo.pointer base:demandModel basePFoOrTargetFoModel:nil];
        
        //b. 取自身,实现吃,则可不饿 (提交C给TOR行为化);
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        NSLog(@">>>>>> pSolution 新增第%ld例解决方案: %@->%@",demandModel.actionFoModels.count,Fo2FStr(fo),Mvp2Str(fo.cmvNode_p));
        dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
            [theTV updateFrame];
        });
        DebugE();
        
        //8. 只要有一次tryResult成功,中断回调循环;
        return [TCAction action:toFoModel];//[theTOR singleLoopBackWithBegin:toFoModel];
    }
    
    //9. 无计可施,下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
    DebugE();
    demandModel.status = TOModelStatus_WithOut;
    NSLog(@">>>>>> pSolution 无计可施");
    [TCScore scoreFromIfTCNeed];
    return [[[TCResult new:false] mkMsg:@"pSolution 无计可施"] mkStep:23];
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
 *      2022.05.31: 支持快慢思考 (参考26161 & 26162);
 *      2024.01.23: bestResult由虚转实 (参考31073-TODO2c);
 *      2024.01.30: hDemand在WithOut时,向父级和兄弟传染 (参考31073-TODO8b & TODO8c);
 */
+(TCResult*) hSolution:(HDemandModel*)hDemand{
    //0. S数达到limit时设为WithOut;
    if (![theTC energyValid]) return [[[TCResult new:false] mkMsg:@"hSolution能量不足"] mkStep:21];
    OFTitleLog(@"hSolution", @"\n目标:%@ 已有S数:%ld",Pit2FStr(hDemand.baseOrGroup.content_p),hDemand.actionFoModels.count);
    
    //1. 树限宽且限深;
    NSInteger deepCount = [TOUtils getBaseDemandsDeepCount:hDemand];
    if (deepCount >= cDemandDeepLimit || hDemand.actionFoModels.count >= cSolutionNarrowLimit) {
        [hDemand setStatus2WithOut];
        [TCScore scoreFromIfTCNeed];
        NSLog(@"------->>>>>> hSolution 已达limit条");
        return [[[TCResult new:false] mkMsg:@"hSolution > limit"] mkStep:22];
    }
    [theTC updateOperCount:kFILENAME];
    Debug();
    
    //4. 快思考无果或后2条,再做求解;
    TOFoModel *bestResult = [TCSolutionUtil hSolutionV3:hDemand];
    
    //8. 新解决方案_的结果处理;
    DebugE();
    if (bestResult) {
        //8. 消耗活跃度;
        [theTC updateEnergyDelta:-1];
        
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        //c) 调试;
        AIFoNodeBase *sceneFo = [SMGUtils searchNode:bestResult.sceneFo];
        AIEffectStrong *effStrong = [TOUtils getEffectStrong:sceneFo effectIndex:sceneFo.count solutionFo:bestResult.cansetFo];
        NSString *effDesc = effStrong ? effStrong.description : @"";
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:bestResult.cansetFo];
        NSLog(@"> newH 第%ld例: eff:%@ sp:%@ %@ scene:F%ld canset:F%ld (cutIndex:%ld=>targetIndex:%ld) (前%.2f 中%.2f 后%.2f)",hDemand.actionFoModels.count,effDesc,CLEANSTR(cansetFo.spDic),SceneType2Str(bestResult.baseSceneModel.type),sceneFo.pId,cansetFo.pId,bestResult.cansetCutIndex,bestResult.targetIndex,bestResult.frontMatchValue,bestResult.midStableScore,bestResult.backMatchValue);
        
        //a) 有效率
        [TCEffect hEffect:bestResult];
        dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
            [theTV updateFrame];
        });
        return [TCAction action:bestResult];
    }else{
        //b) 下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
        [hDemand setStatus2WithOut];
        NSLog(@">>>>>> hSolution 无计可施");
        [TCScore scoreFromIfTCNeed];
        return [[[TCResult new:false] mkMsg:@"hSolution无计可施"] mkStep:23];
    }
}

@end
