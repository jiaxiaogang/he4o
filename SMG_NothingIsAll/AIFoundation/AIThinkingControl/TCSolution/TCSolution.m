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
 *  @version
 *      2021.12.28: 对首条S的支持 (参考25042);
 *      2021.12.28: 支持actYes时最优路径末枝为nil,并中止决策 (参考25042-3);
 *      2022.06.02: 如果endBranch的末枝正在等待actYes,则继续等待,不进行决策 (参考26185-TODO4);
 *      2024.02.04: Cansets实时竞争放到TCPlan中了,此处实时竞争的代码删掉;
 */
+(TCResult*) solutionV2:(TOModelBase*)endBranch {
    if (ISOK(endBranch, ReasonDemandModel.class)) {
        //1. R任务继续取解决方案 (参考24203-2);
        return [self rSolution:(ReasonDemandModel*)endBranch];
    } else if (ISOK(endBranch, HDemandModel.class)) {
        //2. H任务继续取解决方案 (参考24203-2);
        return [self hSolution:(HDemandModel*)endBranch];
    } else if (ISOK(endBranch, TOFoModel.class)) {
        //3. 传入solutionFo时: 直接执行action();
        return [TCAction action:(TOFoModel*)endBranch];
    }
    return [[[TCResult new:false] mkMsg:@"solution的endBranch: 非R非H也非Canset"] mkStep:19];
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
        [TCPlan planFromIfTCNeed];
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
        NSLog(@"> newS 第%ld例: eff:%@ sp:%@ %@ scene:F%ld canset:F%ld",demand.actionFoModels.count,effDesc,CLEANSTR(cansetFo.spDic),SceneType2Str(bestResult.baseSceneModel.type),sceneFo.pId,cansetFo.pId);
        
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
        [TCPlan planFromIfTCNeed];
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
        [TCPlan planFromIfTCNeed];
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
    [TCPlan planFromIfTCNeed];
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
    OFTitleLog(@"hSolution", @"\n%@目标:%@ 已有S数:%ld 任务层级:%ld",FltLog4HDemandOfYouPiGuo(@"2"),Pit2FStr(hDemand.baseOrGroup.content_p),hDemand.actionFoModels.count,[TOUtils getBaseDemandsDeepCount:hDemand]);
    
    //1. 树限宽且限深;
    NSInteger deepCount = [TOUtils getBaseDemandsDeepCount:hDemand];
    if (deepCount >= cDemandDeepLimit || hDemand.actionFoModels.count >= cSolutionNarrowLimit) {
        [hDemand setStatus2WithOut];
        [TCPlan planFromIfTCNeed];
        NSLog(@"------->>>>>> hSolution 已达limit条");
        return [[[TCResult new:false] mkMsg:@"hSolution > limit"] mkStep:22];
    }
    [theTC updateOperCount:kFILENAME];
    Debug();
    
    //4. 快思考无果或后2条,再做求解;
    TOFoModel *bestResult = [TCSolutionUtil hSolutionV3:hDemand];
    
    
    //TODOTOMORROW20240707:
    if (ISOK(hDemand, HDemandModel.class) && [NVHeUtil algIsYouPiGuo:hDemand.baseOrGroup.content_p]) {
        NSLog(@"有皮果的hSolution执行了...");
    }
    //1. 此处有皮果动机,它有踢的经验,但却全都FRSTime来不及? (持续性任务不再做FRSTime判断);
    
    //2. 查下这些"踢"经验哪里生成的,为什么前段那么多多余帧?
    //分析: 不是所有的前段都那么多多余帧,那么我们在这种情况下,直接扔个距0皮果,应该可以推进一帧的胜出?然后触发踢行为,明天试下;
    //H0. I<F3994 F8632[↑饿-16,↑饿-16,4果,吃,4果皮,踢↑,4果皮]> {0 = 1;1 = 6;}  (null):(分:0.00) [CUT:1=>TAR:6]
    //H0. I<F3994 F8632[↑饿-16,↑饿-16,4果,吃,4果皮,踢↑,4果皮]> {0 = 1;1 = 6;}  (null):(分:0.00) [CUT:1=>TAR:6]
    //H2. I<F3994 F8638[↑饿-16,↑饿-16,4果,吃,4果皮,踢↑,4果皮,4棒]> {0 = 1;1 = 6;2 = 7;}  (null):(分:0.00) [CUT:1=>TAR:6]
    //H3. I<F3994 F8666[↑饿-16,↑饿-16,4果,吃,4果皮,踢↑,4果皮,4棒,4棒]> {0 = 1;3 = 8;2 = 7;1 = 6;}  (null):(分:0.00) [CUT:1=>TAR:6]
    //H4. I<F3994 F8671[↑饿-16,↑饿-16,4果,吃,4果皮,踢↑,4果皮,4棒,4棒,4果]> {0 = 1;3 = 8;2 = 7;1 = 6;4 = 9;}  (null):(分:0.00) [CUT:1=>TAR:6]
    
    //H0. I<F4130 F8238[↑饿-16,4果皮,4果皮,踢↑,4果皮,4棒,4棒,4果]> {0 = 0;}  (null):(分:0.00) [CUT:0=>TAR:7]
    //H1. I<F4130 F8241[↑饿-16,↑饿-16,↑饿-16,4果皮,4果皮,踢↑,4果皮,4棒,4棒,4果]> {0 = 2;}  (null):(分:0.00) [CUT:2=>TAR:9]
    //H2. I<F4130 F8252[↑饿-16,4果皮,4果皮,踢↑,4果皮,4棒,4棒,4果,飞↑]> {0 = 0;}  (null):(分:0.00) [CUT:0=>TAR:7]//3. 执行hDemand后,没执行hSolution的问题仍然存在;
    //H3. I<F4130 F8254[↑饿-16,↑饿-16,↑饿-16,4果皮,4果皮,踢↑,4果皮,4棒,4棒,4果,飞↑]> {0 = 2;}  (null):(分:0.00) [CUT:2=>TAR:9]//经查日志,有时hDemand生成后,在TCPlan中未胜出,导致它没执行...
    //H4. I<F4130 F8497[↑饿-16,4果皮,踢↑,4果皮,4果皮,4棒,飞↑,4棒,4果皮,4棒,4果皮,踢↑,4果皮,4棒,4棒,4果]> {0 = 0;}  (null):(分:0.00) [CUT:0=>TAR:15]
    
    //3. 问题1: 但又测到新的BUG: 目标饿的hSolution输出的canset的target全不是饿,如下:
    //目标:M1{↑饿-16} 已有S数:0
    //H0. I<F4115 F4348[↑饿-16,4果皮,4棒]> {}  (null):(分:0.00) [CUT:0=>TAR:2] //注: target2是棒,不是饿;
    
    //4. 问题2: HDemand生成后,不执行hSolution的问题: 如果hDemand在期间被反馈了,这个hDemand就激活不了了;
    //if ([NVHeUtil algIsYouPiGuo:algModel.content_p]) {
    //    //查明问题: 在HDemand有皮果后,它的父alg直接已经被反馈了,所以它被中断掉了,没继续这个hDemand是正常的;
    //}
    
    
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
        NSLog(@"> newH 第%ld例: eff:%@ sp:%@ %@ scene:F%ld canset:F%ld (cutIndex:%ld=>targetIndex:%ld)",hDemand.actionFoModels.count,effDesc,CLEANSTR(cansetFo.spDic),SceneType2Str(bestResult.baseSceneModel.type),sceneFo.pId,cansetFo.pId,bestResult.cansetCutIndex,bestResult.cansetTargetIndex);
        
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
        [TCPlan planFromIfTCNeed];
        return [[[TCResult new:false] mkMsg:@"hSolution无计可施"] mkStep:23];
    }
}

@end
