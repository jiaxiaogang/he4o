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
 *  --------------------旧有plan方法--------------------
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
 *      2021.01.22: 对ActYes或者OutBack的Demand进行不应期处理 (未完成);
 *  @status
 *      1. R+模式: 废弃状态,此模式暂时用不着;
 *      2. R-模式: 启用状态;
 *      3. P+模式: 废弃状态,此模式暂时用不着;
 *      4. P-模式: 启用状态;
 *
 *  MARK:--------------------新螺旋架构plan入口--------------------
 *  @param rootDemand   : 当前执行的根任务;
 *  @version
 *      2022.03.11: 将demand综合评分,改为score4Demand方法 (参考25142-TODO4);
 *  @todo
 *      2021.12.08: 后续solution行为化处理,根据>cutIndex筛选 (参考24185-方案1-代码);
 */
+(TCResult*) plan:(DemandModel*)rootDemand scoreDic:(NSMutableDictionary*)scoreDic{
    //1. 根据得分字典,从root向sub,取最优路径 (参考24195-3);
    [theTC updateOperCount:kFILENAME];
    Debug();
    double demandScore = [AIScore score4Demand:rootDemand];
    TOModelBase *endBranch = [self bestEndBranch4Plan:scoreDic curDemand:rootDemand demandScore:demandScore];
    
    //2. 从最优路径末枝的解决方案,转给TCSolution执行 (参考24195-4);
    double endBranchScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(endBranch)]) doubleValue];
    DebugE();
    return [TCSolution solution:endBranch endScore:endBranchScore];
}

/**
 *  MARK:--------------------取当前要执行的解决方案--------------------
 *  @desc 从最优路径的末尾取 (最优路径可能有在subRDemands处分叉口,那么依次解决叉口任务);
 *  @version
 *      2021.12.28: 工作记忆树任务下_首条S的支持 (参考25042);
 *      2021.12.28: 重新整理整个方法,参考评分字典数据结构做最优路径 (参考24196-示图);
 *      2022.06.02: 中层为actYes时,不向下传染,继续找路径 (参考26185-TODO7);
 *      2022.06.02: BUG_过滤掉actNo的结果,不然给solution一个actNo的最佳路径尴尬了;
 *      2023.02.28: R子任务不求解 (参考28135-2);
 *      2023.07.09: 打开子任务开关,因为明明有子任务却不激活的话,有可能它的父任务不断反思出子任务再回来又激活父任务,不断生成子任务,导致死循环 (参考30055);
 *      2023.08.21: 调整子任务的优先级: 反思通过时子H任务优先,反思不通过时子R任务优先 (参考30114-todo2);
 *  @result
 *      1. 返回空S的Demand时,执行solution找解决方案;
 *      2. 返回路径末枝BestFo时,执行action行为化;
 *      3. 返回nil时,中止决策继续等待;
 */
+(TOModelBase*) bestEndBranch4Plan:(NSMutableDictionary*)scoreDic curDemand:(DemandModel*)curDemand demandScore:(double)demandScore{
    //1. 如果curDemand未初始化Cansets,则直接返回 => 返回后会进行solution初始化Cansets和竞争求解;
    if (!curDemand.alreadyInitCansetModels) {
        return curDemand;
    }
    
    //2. 从actionFoModels找出最好的分支继续 (参考24196-示图 & 25042-6);
    TOFoModel *bestFo = nil;
    for (TOFoModel *itemFo in curDemand.bestCansets) {
        double itemScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(itemFo)]) doubleValue];
        double bestScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(bestFo)]) doubleValue];
        if (!bestFo || itemScore > bestScore) bestFo = itemFo;
    }
    
    //TODOTOMORROW20240131:
    //===== 现逻辑 =====
    //1. 本方法本来就有的逻辑: 实在感性淘汰时: (bestScore < demandScore)
    //      > 会直接返回curDemand,即在solution()可以从actionFoModels中重新竞争一个新的出来;
    //2. 然后: 只要还可以接受,就去先解决它的子任务;
    //3. 再然后: 子任务都完成或无解了,可以返回best最高分的方案,继续推进action去;
    
    //===== 迭代点 =====
    //4. bestScore > 0时: 才继续递归推进它的子任务什么的;
    //5. bestScore = 0时: 要实时竞争下;然后推进胜者的子任务;
    //6. bestScore < 0时: 优先重新实时竞争一个新方案出来;
    //7. 如果没新方案了;
    //      a. 则尝试解决负作用: 尝试解决它的子任务 (递归它的子任务);
    //      b. 如果没子任务或子任务也没解
    //          a. 如果bestScore > demandScore: 则利大于弊,忍痛执行bestFo.action();
    //          b. 如果bestScore < demandScore: 则忍无可忍,任务改成ScoreNo或ActNo状态,并传染下?
    
    //9. 看用不用把来不及的,反思不通过的,全都改成ScoreNo或actNo状态,然后,在实时竞争时,及时过滤掉;
    
    
    //3. 感性淘汰则中止深入 (判断条件 = bestFo得分 < demandScore) (参考25042-7);
    double bestScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(bestFo)]) doubleValue];
    if (bestScore < demandScore) return curDemand;
    
    //4. 感性未淘汰则继续深入分支 (判断条件 = bestFo得分 > demandScore) (参考25042-6);
    //4. 未感性淘汰,那么它的子R和H任务中,肯定有一个是未"理性淘汰"的: 收集R和H任务;
    NSMutableArray *allSubDemands = [[NSMutableArray alloc] init];
    
    //5. 数据准备: 子R和子H任务;
    NSArray *subRDemands = bestFo.subDemands;
    NSArray *subHDemands = [SMGUtils convertArr:bestFo.subModels convertBlock:^id(TOAlgModel *item) {
        HDemandModel *hDemand = ARR_INDEX(item.subDemands, 0);
        return hDemand;
    }];
    
    //6. 优先级: 反思通过时子H任务优先,反思不通过时子R任务优先 (参考30114-todo2);
    if (bestFo.refrectionNo) {
        [allSubDemands addObjectsFromArray:subRDemands];
        [allSubDemands addObjectsFromArray:subHDemands];
    } else {
        [allSubDemands addObjectsFromArray:subHDemands];
        [allSubDemands addObjectsFromArray:subRDemands];
    }
    
    //7. 向末枝路径探索: 从R到H逐一尝试最优路径,从中找出那个未"理性淘汰"的,递归判断;
    for (DemandModel *subDemand in allSubDemands) {
        //8. 判断subDemand.status是否已finish -> 无需解决 (参考25042-2);
        if (subDemand.status == TOModelStatus_Finish) continue;
        
        //9. 判断subDemand.status是withOut状态 -> 无解认命 (参考25042-2);
        if (subDemand.status == TOModelStatus_WithOut) continue;
        
        //10. 判断subDemand.status是actYes状态 -> 继续等待 (参考25042-3);
        //if (subDemand.status == TOModelStatus_ActYes) return nil;
        
        //11. 未感性淘汰的,一条路走到黑(递归循环),然后把最后的结果return返回;
        return [self bestEndBranch4Plan:scoreDic curDemand:subDemand demandScore:demandScore];
    }
    
    //12. bestFo没有子任务subDemands可决策的,则直接执行bestFo为末枝 (参考25042-8);
    NSLog(@"取分: K:%@ => V:%@分",TOModel2Key(bestFo),[scoreDic objectForKey:TOModel2Key(bestFo)]);
    [AITest test10:bestFo];
    return bestFo;
}

@end
