//
//  TCScore.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/19.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCScore.h"

@implementation TCScore

/**
 *  MARK:--------------------调用入口--------------------
 *  @version
 *      2023.07.21: 关闭TC各处调用,改为在TO线程调用 (参考30084-方案);
 */
+(void) scoreFromIfTCNeed{}
+(void) scoreFromTOQueue{
    [self score];
}

/**
 *  MARK:--------------------新螺旋架构score方法--------------------
 */
+(void) score{
    //1. 取当前任务 (参考24195-1);
    [theTC updateOperCount:kFILENAME];
    Debug();
    OSTitleLog(@"TCScore");
    DemandModel *demand = [theTC.outModelManager getCanDecisionDemand];
    
    //2. 对firstRootDemand取得分字典 (参考24195-2 & 24196示图);
    NSMutableDictionary *scoreDic = [[NSMutableDictionary alloc] init];
    TOFoModel *foModel = [self score_Multi:demand.actionFoModels scoreDic:scoreDic];
    
    //3. 转给TCPlan取最优路径;
    DebugE();
    [TCPlan plan:demand rootFo:foModel scoreDic:scoreDic];
}

//MARK:===============================================================
//MARK:                     < 综合评分 >
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
 *  @version
 *      2021.12.21: 支持状态为WithOut的处理 (只有WithOut状态的才可能理性淘汰,不然就有可能死灰复燃);
 *      2021.12.21: 支持状态为ActNo (如为时间不急淘汰掉) 的处理 (子解决方案全ActNo之后且WithOut的理性淘汰);
 *      2021.12.26: 支持当rDemand和hDemand已finish时不计分,并中断向子枝评分;
 *      2022.03.11: 升级支持mvScoreV2 (参考25142-TODO4);
 *      2022.06.02: 封装单demand评分方法 (顺便解决有时solutionFos全为ActNo时,直接判负分,而不尝试新方案);
 *  @param scoreDic : notnull;
 *
 *  _result 将model及其下有效的分枝评分计算,并收集到评分字典 <K=foModel,V=score>;
 */
+(void) score_Single:(TOFoModel*)model scoreDic:(NSMutableDictionary*)scoreDic{
    //1. 数据检查;
    double modelScore = 0;
    
    //2. ===== 第0部分: foModel自身理性淘汰判断 (比如时间不急评否后,为actNo状态) (参考24053);
    if (model.status == TOModelStatus_ActNo) {
        [scoreDic setObject:@(INT_MIN) forKey:TOModel2Key(model)];
        NSLog(@"评分1: 因actNo直接评最小分: K:%@",TOModel2Key(model));
        return;
    }
    
    //3. ===== 第一部分: HDemand在FoModel.subModels下 (有解决方案:参与求和 & 无解决方案:理性淘汰);
    //3. 用每个sa取sh子任务 (求和);
    for (TOAlgModel *sa in model.subModels) {
        
        //3. 取出sh (一条sa最多只能生成一个sh任务);
        HDemandModel *sh = ARR_INDEX(sa.subDemands, 0);
        if (sh) {
            CGFloat score = [self score_SingleDemand:sh scoreDic:scoreDic];
            modelScore += score;
        }
    }
    
    //4. ===== 第二部分: RDemand在AlgModel.subDemands下 (有解决方案:参与求和 & 无解决方案:R自身计入综合评分中);
    //4. 取出subRDemands子任务 (求和) 综合评价是否放弃当前父任务 (如又累又烦的活,赚钱也不干) (参考24195);
    for (ReasonDemandModel *sr in model.subDemands) {
        CGFloat score = [self score_SingleDemand:sr scoreDic:scoreDic];
        modelScore += score;
    }
    
    //5. 将求和得分,计入dic (当没有sr也没有sa子任务 = 0分);
    [scoreDic setObject:@(modelScore) forKey:TOModel2Key(model)];
    NSLog(@"评分3: K:%@ => V:%@分",TOModel2Key(model),[scoreDic objectForKey:TOModel2Key(model)]);
}

/**
 *  MARK:--------------------获取单demand的评分--------------------
 *  @desc 只返回不直接计入字典,因为demand评分是要"求和"后计入字典的;
 *  @version
 *      2022.09.24: 失效处理: 子任务失效时,不进行决策综评 (参考27123-问题2-todo3);
 */
+(CGFloat) score_SingleDemand:(DemandModel*)demand scoreDic:(NSMutableDictionary*)scoreDic{
    //1. 当demand在feedbackTOR已finish时,不计分;
    if (demand.status == TOModelStatus_Finish) return 0;
    
    //1. 当demand失效时,不计分;
    if (ISOK(demand, ReasonDemandModel.class) && ((ReasonDemandModel*)demand).isExpired) return 0;

    //2. 取出还未理性失败的解决方案;
    NSArray *validActionFos = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOFoModel *actionFo) {
        return actionFo.status != TOModelStatus_ActNo;
    }];

    //3. 当demand已经withOut状态,且其解决方案全部actNo时,则理性淘汰 (参考24192-H14);
    if (demand.status == TOModelStatus_WithOut && !ARRISOK(validActionFos)) {
        
        if (ISOK(demand, HDemandModel.class)) {
            //4. H无解决方案时,直接计min分计入modelScore;
            return INT_MIN;
        }else {
            //5. R无解决方案时,直接将sr评分计入modelScore;
            return [AIScore score4Demand:demand];
        }
    }else{
        //6. demand有解决方案时,对S竞争,并将最高分计入modelScore;
        TOFoModel *bestSS = [self score_Multi:validActionFos scoreDic:scoreDic];
        
        //7. 并将竞争最高分胜者计入modelScore;
        return [NUMTOOK([scoreDic objectForKey:TOModel2Key(bestSS)]) doubleValue];
    }
}

/**
 *  MARK:--------------------S解决方案竞争--------------------
 *  @desc 感性竞争 (参考24192-R9);
 *  @param foModels : 解决方案S数,single传入>=1条,plan传入可能为0条;
 *  @param scoreDic : notnull
 *  @result 将bestFo返回;
 */
+(TOFoModel*) score_Multi:(NSArray*)foModels scoreDic:(NSMutableDictionary*)scoreDic{
    //1. 取出子任务的每个解决方案S (竞争);
    TOFoModel *bestFoModel = nil;
    for (TOFoModel *foModel in foModels) {
        
        //2. 评分
        [self score_Single:foModel scoreDic:scoreDic];
        
        //3. 竞争
        if (!bestFoModel) {
            bestFoModel = foModel;
        }else{
            double oldScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(bestFoModel)]) doubleValue];
            double newScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(foModel)]) doubleValue];
            if (newScore > oldScore) {
                bestFoModel = foModel;
            }
        }
    }
    
    //4. 将最优S返回;
    return bestFoModel;
}

@end
