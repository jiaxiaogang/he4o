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
 *  MARK:--------------------topV2--------------------
 *  注:assExp联想经验(饿了找瓜)(递归)
 *  注:loopAssExp中本身已经是内心活动联想到的mv
 *  @desc
 *      1. 四种(2x2)TOP模式 (优先取同区工作模式,不行再以不同区工作模式);
 *      2. 调用者只管调用触发,模型生成,参数保留;
 *  @desc P决策模式 (框架: index -> mvNode -> foNode -> algNode -> action);
 *      3. 不指定model (从cmvCache取) (旧注释)
 *      4. 每一轮循环不仅是想下一个singleMvPort;也有可能在当前port上,进行二次思考; (旧注释)
 *      5. 从expCache下,根据可行性,选定一个解决方案; (旧注释)
 *      6. 有需求时,找出outMvModel,尝试决策并解决; (旧注释)
 *  @version
 *      20200430 : v2,四种工作模式版;
 *      20200824 : 将外循环输入推进中循环,改到上一步aiThinkIn_CommitNoMv2TC()中;
 *  @todo
 *      1. 集成活跃度的判断和消耗;
 *      2. 集成outModel;
 *      3. TODOTOMORROW: 下面传给四模式的代码,用bool方式直接返回finish的判断不妥,改之;
 *      2021.01.22: 对ActYes或者OutBack的Demand进行不应期处理 (未完成);
 *  @status
 *      1. R+模式: 废弃状态,此模式暂时用不着;
 *      2. R-模式: 启用状态;
 *      3. P+模式: 废弃状态,此模式暂时用不着;
 *      4. P-模式: 启用状态;
 */
+(void) solution{
    //1. 数据准备
    DemandModel *demand = [theTC.outModelManager getCanDecisionDemand];
    [self solution:demand];
    
    
    
    //----------TODOTOMORROW20211205:
    //3. 无论子任务是否解决,都回来判综合评分pk,比如子任务不解决我也要继续父任务;
    //4. 分析此从root出发,对各rootDemand的竞争,针对子任务,能否自动调用继续决策螺旋 (一个个一层层进行综合pk);
}

+(void) solution:(DemandModel*)demand{
    
    //2. 同区两个模式之R-;
    if (ISOK(demand, ReasonDemandModel.class)) {
        //a. R-
        ReasonDemandModel *rDemand = (ReasonDemandModel*)demand;
        
        //1. 数据检查
        if (!Switch4RS) return;
        AIFoNodeBase *matchFo = rDemand.mModel.matchFo;
        OFTitleLog(@"TOP.R-", @"\n任务:%@->%@,发生%ld",Fo2FStr(matchFo),Mvp2Str(matchFo.cmvNode_p),(long)rDemand.mModel.cutIndex2);
        
        //2. ActYes等待 或 OutBack反省等待 中时,不进行决策;
        NSArray *waitFos = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOFoModel *item) {
            return item.status == TOModelStatus_ActYes || item.status == TOModelStatus_OuterBack;
        }];
        if (ARRISOK(waitFos)) return;
        
        //3. 行为化;
        [self rSolution:rDemand];
    }else if(ISOK(demand, PerceptDemandModel.class)){
        
        //TODOTOMORROW20211201: 此处改为和R模式一样,全套从短时记忆树来触发和工作;
        //  a. 此处的mModels循环没啥用,后看该删就删了;
        
        //3. 不同区两个模式 (以最近的识别优先);
        for (NSInteger i = 0; i < theTC.inModelManager.models.count; i++) {
            AIShortMatchModel *mModel = ARR_INDEX_REVERSE(theTC.inModelManager.models, i);
            AIAlgNodeBase *matchAlg = mModel.matchAlg;
            
            //a. 识别有效性判断 (优先直接mv+,不行再mv-迂回);
            if (matchAlg) {
                //b. P-
                [self pSolution:demand];
            }
        }
    }else if(ISOK(demand, HDemandModel.class)){
        [self hSolution:demand];
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
        [TCAction rAction:foModel];
    }else{
        
        //-----TODOTOMORROW20211203:
        //0. 理一理rSolution之后的代码,看r决策的运行能不能预演顺利运行
        //1. rSolution要支持subDemand;
        //2. 解决方案反思子任务的失败,不表示解决方案失败,它还可以参与最终pk池竞争;
        //3. 解决此处failure无计可施后的逻辑;
        
        
        
        
        
        //7. 转流程控制_无则转failure;
        demand.status = TOModelStatus_ActNo;
        NSArray *baseDemands = [TOUtils getBaseDemands_AllDeep:demand];
        DemandModel *baseDemand = ARR_INDEX(baseDemands, 1);
        
        if (baseDemand) {
            //8. 向上一轮递归,继续base.下一解决方案;
            [TCSolution solution:baseDemand];
        }else{
            //9. 当前就是root了,开始清算;
            
            
            
        }
        
        
        //a. 子任务失败,则转向下一子任务
        //b. 所有子任务失败,则转向父任务下一解决方案 (不脱离场景的情况下,仅取三条);
        
        
        
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
                NSLog(@"------->>>>>> P-新增一例解决方案: %@->%@",Fo2FStr(fo),Mvp2Str(fo.cmvNode_p));
                [theTOR singleLoopBackWithBegin:toFoModel];
                
                //8. 只要有一次tryResult成功,中断回调循环;
                return;
            }
        }
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
    //4. 可将当前瞬时记忆序列做为mask进行cHav联想 (比如在家时,不会想到点外卖,在工作地就首先想到外卖);
    
    
    
    //5. 取不应期;
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:algModel.actionFoModels];
    
    //4. 第3级: 数据检查hAlg_根据type和value_p找ATHav
    AIKVPointer *relativeFo_p = [AINetService getInnerV3_HN:curAlg aAT:algModel.content_p.algsType aDS:algModel.content_p.dataSource type:ATHav except_ps:except_ps];
    if (Log4ActHav) NSLog(@"getInnerAlg(有): 根据:%@ 找:%@_%@ \n联想结果:%@ %@",Alg2FStr(curAlg),algModel.content_p.algsType,algModel.content_p.dataSource,Pit2FStr(relativeFo_p),relativeFo_p ? @"↓↓↓↓↓↓↓↓" : @"无计可施");
    
    //6. 只要有善可尝试的方式,即从首条开始尝试;
    if (relativeFo_p) {
        TOFoModel *foModel = [TOFoModel newWithFo_p:relativeFo_p base:hDemand];
        [TCAction hAction:foModel];
    }else{
        
        //10. 所有mModel都没成功行为化一条,则失败 (无计可施);
        hDemand.status = TOModelStatus_ActNo;
        //TODOTOMORROW20211128: 没有任何H经验时,递归到上一轮demand;
        
        
    }
}

@end
