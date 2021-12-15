//
//  TCPlan.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/15.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCPlan.h"

@implementation TCPlan

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
+(void) plan{
    //1. 数据准备
    DemandModel *demand = [theTC.outModelManager getCanDecisionDemand];
    [self plan:demand];
    
    
    //----------TODOTOMORROW20211208: solution代码规划 (参考24192);
    //1. 从root出发,逐层综评;
    //2. 综评之: 理性淘汰的判断;
    //3. 综评之: 感性pk,并继续向sub深入;
    //4. 逐层综评pk,深入到最终节点 (当最终枝点S超过3条时,向前1节,取nextSolution);
    //5. 最终所有层全取完3条solution后,可以做感性淘汰;
    //6. 最终未淘汰且竞争在首位的枝点: 继续solution推进行为化: 取解决方案或输出行为;
    
    
    //后续solution行为化处理:
    //1. 根据>cutIndex筛选 (参考24185-方案1-代码);
    //2. ...
    
    
    
    //TODOTOMORROW20211216:
    //方案1:
    //1. 把任务树捋顺,有几个root根取出来;
    //2. 写个PlanFo虚foModel,把所有root根挂在它下面;
    //3. 到getPlanSolution取出来最优路径,执行之;
    //  a. 从rootFo.sub出发取出RootDemands;
    //  b. 判断rootDemand和其下S的评分对比,做感性淘汰;
    //  c. 再找出最高分的路径,进行行为化;
    
    //方案2:
    //1. 从任务树取出几个root;
    //2. 对每个root,分别进行single综合评分;
    //  a. root无解决方案时,rootDemand自身就是迫切度评分;
    //  b. root有解决方案时,分别对root的解决方案评分找出最优方案;
    //  c. 对每个root各自判断最优方案是否感性淘汰;
    //  d. 没淘汰的root们,竞争哪个更有效,执行之;
    
    //方案3:
    //1. 从任务树取出几个root;
    //2. 对每个root,直接进行迫切度竞争,取出老大进行行为化;
    //  a. 对firstRoot进行single综合评分,并取最优路径;
    //  b. 判断最优路径是否感性淘汰->淘汰的话继续下一个secondRoot,尝试第a步;
    //  c. 判断最优路径是否感性淘汰->未淘汰的话继续行为化;
    
    
    
    
    
    
    
}

/**
 *  MARK:--------------------对toModel综合评分--------------------
 *  @desc 对解决方案S进行综合评分 (参考24192);
 *  @result 将rootModel及其下分枝评分全部计算,并存为字典返回 <K=foModel,V=score>;
 */
+(NSArray*) getPlanSolution:(TOFoModel*)rootFo{
    //1. 数据准备;
    NSMutableDictionary *scoreDic = [[NSMutableDictionary alloc] init];
    
    //2. 算出得分字典;
    [self score4Solution_Single:rootFo scoreDic:scoreDic];
    
    //3. 得出最优路径;
    NSArray *bestWay = [self bestWay:scoreDic rootFo:rootFo];
    return bestWay;
}

/**
 *  MARK:--------------------短时记忆树综合评分--------------------
 *  @desc
 *      1. 缩写说明: 1.sr=SubRDemand 2.ss=SubSolution 3.sa=SubAlgModel 4.sh=SubHDemand
 *      2. 每执行一次single方法,则scoreDic中收集一条model的得分 <foModel,score>;
 *      3. S竞争方法由_Best方法实现;
 *      4. R求和方法主要在_Single中实现;
 *      5. 先将所有得分算完后,再重新从root开始算最优路径,因为只有子枝算完,父枝才能知道怎么算最优路径;
 */
+(void) score4Solution_Single:(TOFoModel*)model scoreDic:(NSMutableDictionary*)scoreDic{
    //1. 数据检查;
    if (!scoreDic) scoreDic = [[NSMutableDictionary alloc] init];
    double modelScore = 0;
    
    //===== 第一部分: RDemand在FoModel.subDemands下 (有解决方案:参与求和 & 无解决方案:理性淘汰);
    //2. 用每个sa取sh子任务 (求和);
    for (TOAlgModel *sa in model.subModels) {
        
        //3. 取出sh (一条sa最多只能生成一个sh任务);
        HDemandModel *sh = ARR_INDEX(sa.subDemands, 0);
        if (sh) {
            //4. H有解决方案时,对S竞争,并将最高分计入modelScore;
            if (ARRISOK(sh.actionFoModels)) {
                
                //a. 对S竞争;
                TOFoModel *bestSS = [self score4Solution_Best:sh.actionFoModels scoreDic:scoreDic];
                
                //b. 将竞争胜者计入modelScore;
                modelScore += [NUMTOOK([scoreDic objectForKey:bestSS.content_p]) doubleValue];
            }else{
                //5. H无解决方案时,则理性淘汰;
                [scoreDic setObject:@(INT_MIN) forKey:model.content_p];
                return;
            }
        }
    }
    
    //===== 第二部分: HDemand在AlgModel.subDemands下 (有解决方案:参与求和 & 无解决方案:R自身计入综合评分中);
    //10. 取出subRDemands子任务 (求和);
    for (ReasonDemandModel *sr in model.subDemands) {
        
        //11. R有解决方案时,对S竞争,并将最高分计入modelScore;
        if (ARRISOK(sr.actionFoModels)) {
            
            //a. 对S竞争;
            TOFoModel *bestSS = [self score4Solution_Best:sr.actionFoModels scoreDic:scoreDic];
            
            //b. 将竞争胜者计入modelScore;
            modelScore += [NUMTOOK([scoreDic objectForKey:bestSS.content_p]) doubleValue];
        }else{
            //12. R无解决方案时,直接将sr评分计入modelScore;
            double score = [AIScore score4MV:sr.algsType urgentTo:sr.urgentTo delta:sr.delta ratio:1.0f];
            modelScore += score;
        }
    }
    
    //13. 将求和得分,计入dic (当没有sr也没有sa子任务 = 0分);
    [scoreDic setObject:@(modelScore) forKey:model.content_p];
}

/**
 *  MARK:--------------------S解决方案竞争--------------------
 *  @param foModels : 解决方案S数,必须>=1条;
 *  @param scoreDic : notnull
 *  @result 将bestFo返回;
 */
+(TOFoModel*) score4Solution_Best:(NSArray*)foModels scoreDic:(NSMutableDictionary*)scoreDic{
    //1. 取出子任务的每个解决方案S (竞争);
    TOFoModel *bestFoModel = nil;
    for (TOFoModel *foModel in foModels) {
        
        //2. 评分
        [self score4Solution_Single:foModel scoreDic:scoreDic];
        
        //3. 竞争
        if (!bestFoModel) {
            bestFoModel = foModel;
        }else{
            double oldScore = [NUMTOOK([scoreDic objectForKey:bestFoModel.content_p]) doubleValue];
            double newScore = [NUMTOOK([scoreDic objectForKey:foModel.content_p]) doubleValue];
            if (newScore > oldScore) {
                bestFoModel = foModel;
            }
        }
    }
    
    //4. 将最优S返回;
    return bestFoModel;
}

/**
 *  MARK:--------------------取最优路径--------------------
 */
+(NSArray*) bestWay:(NSMutableDictionary*)scoreDic rootFo:(TOFoModel*)rootFo{

    return nil;
}

+(void) plan:(DemandModel*)demand{
    
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
        [TCSolution rSolution:rDemand];
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
                [TCSolution pSolution:demand];
            }
        }
    }else if(ISOK(demand, HDemandModel.class)){
        [TCSolution hSolution:demand];
    }
}

@end
