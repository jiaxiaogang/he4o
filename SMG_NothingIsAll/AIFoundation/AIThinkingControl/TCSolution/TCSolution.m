//
//  TCSolution.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCSolution.h"
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
    
    //TODOTOMORROW20211225: 对第1条hSolution的支持;
    //  a. 此处对endBranch的baseDemand有支持;
    //  b. 但如果endBranch本来就有subModels且正在进行RDemand,但还没有解决方案;则还没支持这种情况;
    //  c. 即: hDemand = endBranch.subModels.subDemand[0];
    //  d. 各情况支持:
    //      1. 如果hDemand有endBranch>=0的直接执行
    //      2. 如果无则hSolution取新方案;
    //      3. 如果无h方案,则endBranch可能才是hDemand,此时也要进行支持 (现不支持);
    
    
    //PRH三个任务生成后,都转向了TCScore;
    //方案2. 前面scoreDic只收集S,然后在此处判断subDemand
    
    //子subDemands中,finish和without的不做处理,actYes状态的继续等待,其它的就以先HDemand后RDemands的优先级处理;
    //这个就不用竞争路径了,best竞争不了这些,这些就是死规则优先级;
    
    
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
                    [self hSolution:(HDemandModel*)endDemand];
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
 *      2021.11.15: R任务FRS稳定性竞争,评分越高的场景排越前 (参考24127-2);
 *      2021.11.25: 迭代为功能架构 (参考24154-单轮示图);
 *      2021.12.25: 将FRS稳定性竞争废弃,改为仅取bestSP评分,取最稳定的一条 (参考25032-4);
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
    
    //4. 从conPorts中找出最优秀的result (稳定性竞争) (参考24127-步骤2);
    RSResultModelBase *bestRSResult = nil;
    for (AIPort *maskPort in sumConPorts) {
        //5. 排除不应期;
        if ([except_ps containsObject:maskPort.target_p]) continue;
        
        //6. 判断SP评分;
        AIFoNodeBase *maskFo = [SMGUtils searchNode:maskPort.target_p];
        AISPStrong *spStrong = [maskFo.spDic objectForKey:@(maskFo.count)];
        RSResultModelBase *checkResult = [RSResultModelBase newWithBaseFo:maskFo spIndex:maskFo.count pScore:spStrong.pStrong sScore:spStrong.sStrong];
        
        //7. 当best为空 或 check评分比best更高时 => 将check赋值到best;
        if(!bestRSResult || checkResult.score > bestRSResult.score){
            bestRSResult = checkResult;
        }
    }
    if (Log4DirecRef) NSLog(@"\n------- baseFo:%@ -------\n已有方案数:%ld 不应期数:%ld",Fo2FStr(demand.mModel.matchFo),demand.actionFoModels.count,except_ps.count);
    
    //6. 转流程控制_有解决方案则转begin;
    if (bestRSResult) {
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        TOFoModel *foModel = [TOFoModel newWithFo_p:bestRSResult.baseFo.pointer base:demand];
        NSLog(@"------->>>>>> R- 新增一例解决方案: %@->%@ FRS_PK评分:%.2f",Fo2FStr(bestRSResult.baseFo),Mvp2Str(bestRSResult.baseFo.cmvNode_p),bestRSResult.score);
        [TCAction action:foModel];
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
 *  @desc 找hSolution解决方案 (参考25014-H & 25015-6);
 *  _param endBranch : hDemand目标alg所在的fo (即hDemand.baseA.baseF);
 *  @version
 *      2021.11.25: 由旧有action._Hav第3级迁移而来;
 *      2021.12.25: 迭代hSolution (参考25014-H & 25015-6);
 */
+(void) hSolution:(HDemandModel*)hDemand{
    //1. 数据准备;
    AIAlgNodeBase *targetAlg = [SMGUtils searchNode:hDemand.baseOrGroup.content_p];
    AIFoNodeBase *targetFo = [SMGUtils searchNode:hDemand.baseOrGroup.baseOrGroup.content_p];
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:hDemand.actionFoModels];
    OFTitleLog(@"hSolution", @"\n目标:%@",Alg2FStr(targetAlg));
    
    //2. 取自身 + 向抽象 + 向具象 (目前仅取一层,如果发现一层不够,可以改为取多层) (参考25014-H描述);
    NSMutableArray *maskFos = [[NSMutableArray alloc] init];
    [maskFos addObject:targetFo.pointer];
    [maskFos addObjectsFromArray:Ports2Pits([AINetUtils absPorts_All_Normal:targetFo])];
    [maskFos addObjectsFromArray:Ports2Pits([AINetUtils conPorts_All_Normal:targetFo])];
    
    //3. 从maskFos中找出最优秀的result;
    RSResultModelBase *bestRSResult = nil;
    for (AIKVPointer *maskFo_p in maskFos) {
        
        //4. 排除不应期;
        if ([except_ps containsObject:maskFo_p]) continue;
        
        //5. 从maskFo中找targetAlg (找targetAlg 或 其抽具象概念);
        AIFoNodeBase *maskFo = [SMGUtils searchNode:maskFo_p];
        NSInteger spIndex = [TOUtils indexOfConOrAbsItem:targetAlg.pointer atContent:maskFo.content_ps layerDiff:1 startIndex:1 endIndex:NSUIntegerMax];
        
        //6. 如找到_则判断SP评分;
        if (spIndex != -1) {
            AISPStrong *spStrong = [maskFo.spDic objectForKey:@(spIndex)];
            RSResultModelBase *checkResult = [RSResultModelBase newWithBaseFo:maskFo spIndex:spIndex pScore:spStrong.pStrong sScore:spStrong.sStrong];
            
            //7. 当best为空 或 check评分比best更高时 => 将check赋值到best;
            if(!bestRSResult || checkResult.score > bestRSResult.score){
                bestRSResult = checkResult;
            }
        }
    }
    
    //8. 新解决方案_的结果处理;
    if (bestRSResult) {
        //a) 下一方案成功时,并直接先尝试Action行为化,下轮循环中再反思综合评价等 (参考24203-2a);
        TOFoModel *foModel = [TOFoModel newWithFo_p:bestRSResult.baseFo.pointer base:hDemand];
        foModel.targetSPIndex = bestRSResult.spIndex;
        NSLog(@"------->>>>>> HDemand 新增一例解决方案: %@->%@ FRS_PK评分:%.2f",Fo2FStr(bestRSResult.baseFo),Mvp2Str(bestRSResult.baseFo.cmvNode_p),bestRSResult.score);
        [TCAction action:foModel];
    }else{
        //b) 下一方案失败时,标记withOut,并下轮循环 (竞争末枝转Action) (参考24203-2b);
        hDemand.status = TOModelStatus_WithOut;
        [TCScore score];
        NSLog(@"------->>>>>> HDemand 无计可施");
    }
}

@end
