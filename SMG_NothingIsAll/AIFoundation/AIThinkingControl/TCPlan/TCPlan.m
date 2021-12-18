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
 *  MARK:--------------------新螺旋架构plan方法--------------------
 *  @desc
 *  @todo
 *      2021.12.08: 后续solution行为化处理,根据>cutIndex筛选 (参考24185-方案1-代码);
 */
+(void) plan{
    //1. 取当前任务 (参考24195-1);
    DemandModel *demand = [theTC.outModelManager getCanDecisionDemand];
    
    //2. 对firstRootDemand取得分字典 (参考24195-2);
    NSMutableDictionary *scoreDic = [[NSMutableDictionary alloc] init];
    TOFoModel *foModel = [self score4Plan_Multi:demand.actionFoModels scoreDic:scoreDic];
    
    //3. 根据得分字典,从root向sub,取最优路径 (参考24195-3);
    double demandScore = [AIScore score4MV:demand.algsType urgentTo:demand.urgentTo delta:demand.delta ratio:1.0f];
    TOFoModel *endBranch = [self bestEndBranch4Plan:scoreDic baseFo:foModel demandScore:demandScore];
    
    //4. 从最优路径末枝的解决方案,转给TCSolution执行 (参考24195-4);
    [TCSolution hSolution:nil];
}

//MARK:===============================================================
//MARK:                     < 综合评分和最优路径 >
//MARK:===============================================================

/**
 *  MARK:--------------------短时记忆树综合评分--------------------
 *  @desc 对解决方案S进行综合评分 (参考24192);
 *  @desc
 *      1. 缩写说明: 1.sr=SubRDemand 2.ss=SubSolution 3.sa=SubAlgModel 4.sh=SubHDemand
 *      2. 每执行一次single方法,则scoreDic中收集一条model的得分 <foModel,score>;
 *      3. S竞争方法由_Best方法实现;
 *      4. R求和方法主要在_Single中实现;
 *      5. 先将所有得分算完后,再重新从root开始算最优路径,因为只有子枝算完,父枝才能知道怎么算最优路径;
 *  _result 将model及其下有效的分枝评分计算,并收集到评分字典 <K=foModel,V=score>;
 */
+(void) score4Plan_Single:(TOFoModel*)model scoreDic:(NSMutableDictionary*)scoreDic{
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
                TOFoModel *bestSS = [self score4Plan_Multi:sh.actionFoModels scoreDic:scoreDic];
                
                //b. 将竞争胜者计入modelScore;
                modelScore += [NUMTOOK([scoreDic objectForKey:bestSS.content_p]) doubleValue];
            }else{
                //5. H无解决方案时,则理性淘汰 (参考24192-H14);
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
            TOFoModel *bestSS = [self score4Plan_Multi:sr.actionFoModels scoreDic:scoreDic];
            
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
 *  @desc 感性竞争 (参考24192-R9);
 *  @param foModels : 解决方案S数,single传入>=1条,plan传入可能为0条;
 *  @param scoreDic : notnull
 *  @result 将bestFo返回;
 */
+(TOFoModel*) score4Plan_Multi:(NSArray*)foModels scoreDic:(NSMutableDictionary*)scoreDic{
    //1. 取出子任务的每个解决方案S (竞争);
    TOFoModel *bestFoModel = nil;
    for (TOFoModel *foModel in foModels) {
        
        //2. 评分
        [self score4Plan_Single:foModel scoreDic:scoreDic];
        
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
 *  MARK:--------------------取当前要执行的解决方案--------------------
 *  @desc 从最优路径的末尾取 (最优路径可能有在subRDemands处分叉口,那么依次解决叉口任务);
 */
+(TOFoModel*) bestEndBranch4Plan:(NSMutableDictionary*)scoreDic baseFo:(TOFoModel*)baseFo demandScore:(double)demandScore{
    //1. 只要直接对baseFo取得分;
    double baseScore = [NUMTOOK([scoreDic objectForKey:baseFo.content_p]) doubleValue];
    
    //2. 未感性淘汰,那么它的子R和H任务中,肯定就没有一个是"理性淘汰"的;
    if (baseScore > demandScore) {
        
        //3. 收集所有子需求;
        NSMutableArray *allSubDemands = [[NSMutableArray alloc] init];
        
        //4. 先解决子R任务 (副作用,磨刀不误砍柴功);
        [allSubDemands addObjectsFromArray:baseFo.subDemands];
        
        //5. 再解决子H任务,即推进时序跳下一帧 (磨完刀了去继续砍柴);
        NSArray *subHDemands = [SMGUtils convertArr:baseFo.subModels convertBlock:^id(TOAlgModel *item) {
            HDemandModel *hDemand = ARR_INDEX(item.subDemands, 0);
            return hDemand;
        }];
        [allSubDemands addObjectsFromArray:subHDemands];
        
        //6. 从R到H逐一尝试最优路径,并返回;
        for (DemandModel *subDemand in allSubDemands) {
            //7. 判断subDemand.status是否已finish;
            if (subDemand.status == TOModelStatus_Finish) {
                continue;
            }
            
            //8. 因为未感性淘汰,它的子解决方案中,必有至少一个是未"理性淘汰"的;
            for (TOFoModel *itemFo in subDemand.actionFoModels) {
                //9. 判断,任何S全先做感性淘汰判断;
                double itemScore = [NUMTOOK([scoreDic objectForKey:itemFo.content_p]) doubleValue];
                if (itemScore < demandScore) {
                    continue;
                }
                
                //10. 未感性淘汰的,一条路走到黑(递归循环),然后把最后的结果return返回;
                return [self bestEndBranch4Plan:scoreDic baseFo:itemFo demandScore:demandScore];
            }
        }
    }
    
    //11. 所有subDemands都决策完,或者感性就已经淘汰,那么直接返回baseFo;
    return baseFo;
}

/**
 *  MARK:--------------------旧有plan方法--------------------
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
+(void) plan_Old{
    //1. 取当前任务;
    DemandModel *demand = [theTC.outModelManager getCanDecisionDemand];
    
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
