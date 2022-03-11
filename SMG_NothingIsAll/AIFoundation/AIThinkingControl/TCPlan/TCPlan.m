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
 *  @param rootFo       : 当前选定的根任务下的解决方案;
 *  @todo
 *      2021.12.08: 后续solution行为化处理,根据>cutIndex筛选 (参考24185-方案1-代码);
 */
+(void) plan:(DemandModel*)rootDemand rootFo:(TOFoModel*)rootFo scoreDic:(NSMutableDictionary*)scoreDic{
    
    //TODOTOMORROW20220309:
    //2. 将SP评分,计入到TCScore竞争;
    
    
    
    
    //1. 根据得分字典,从root向sub,取最优路径 (参考24195-3);
    cgfloat score = [AIScore score4Demand:rootDemand];
    
    
    
    
    
    double demandScore = [AIScore score4MV:rootDemand.algsType urgentTo:rootDemand.urgentTo delta:rootDemand.delta ratio:1.0f];
    TOModelBase *endBranch = [self bestEndBranch4Plan:scoreDic curDemand:rootDemand demandScore:demandScore];
    
    //2. 从最优路径末枝的解决方案,转给TCSolution执行 (参考24195-4);
    double endBranchScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(endBranch)]) doubleValue];
    [TCSolution solution:endBranch endScore:endBranchScore];
}

/**
 *  MARK:--------------------取当前要执行的解决方案--------------------
 *  @desc 从最优路径的末尾取 (最优路径可能有在subRDemands处分叉口,那么依次解决叉口任务);
 *  @version
 *      2021.12.28: 工作记忆树任务下_首条S的支持 (参考25042);
 *      2021.12.28: 重新整理整个方法,参考评分字典数据结构做最优路径 (参考24196-示图);
 *  @result
 *      1. 返回空S的Demand时,执行solution找解决方案;
 *      2. 返回路径末枝BestFo时,执行action行为化;
 *      3. 返回nil时,中止决策继续等待;
 */
+(TOModelBase*) bestEndBranch4Plan:(NSMutableDictionary*)scoreDic curDemand:(DemandModel*)curDemand demandScore:(double)demandScore{
    
    //1. 如果curDemand为空S,则直接返回 (参考25042-5);
    if (!ARRISOK(curDemand.actionFoModels)) return curDemand;
    
    //2. 从actionFoModels找出最好的分支继续 (参考24196-示图 & 25042-6);
    TOFoModel *bestFo = nil;
    for (TOFoModel *itemFo in curDemand.actionFoModels) {
        double itemScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(itemFo)]) doubleValue];
        double bestScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(bestFo)]) doubleValue];
        if (!bestFo || itemScore > bestScore) bestFo = itemFo;
    }
    
    //3. 感性淘汰则中止深入 (判断条件 = bestFo得分 < demandScore) (参考25042-7);
    double bestScore = [NUMTOOK([scoreDic objectForKey:TOModel2Key(bestFo)]) doubleValue];
    if (bestScore < demandScore) return curDemand;
    
    //4. 感性未淘汰则继续深入分支 (判断条件 = bestFo得分 > demandScore) (参考25042-6);
    //4. 未感性淘汰,那么它的子R和H任务中,肯定有一个是未"理性淘汰"的: 收集R和H任务;
    NSMutableArray *allSubDemands = [[NSMutableArray alloc] init];
    
    //5. 优先级: 先解决子R任务 (副作用,磨刀不误砍柴功) (参考25042-4);
    [allSubDemands addObjectsFromArray:bestFo.subDemands];
    
    //6. 优先级: 再解决子H任务,即推进时序跳下一帧 (磨完刀了去继续砍柴) (参考25042-4);
    NSArray *subHDemands = [SMGUtils convertArr:bestFo.subModels convertBlock:^id(TOAlgModel *item) {
        HDemandModel *hDemand = ARR_INDEX(item.subDemands, 0);
        return hDemand;
    }];
    [allSubDemands addObjectsFromArray:subHDemands];
    
    //7. 向末枝路径探索: 从R到H逐一尝试最优路径,从中找出那个未"理性淘汰"的,递归判断;
    for (DemandModel *subDemand in allSubDemands) {
        //8. 判断subDemand.status是否已finish -> 无需解决 (参考25042-2);
        if (subDemand.status == TOModelStatus_Finish) continue;
        
        //9. 判断subDemand.status是withOut状态 -> 无解认命 (参考25042-2);
        if (subDemand.status == TOModelStatus_WithOut) continue;
        
        //10. 判断subDemand.status是actYes状态 -> 继续等待 (参考25042-3);
        if (subDemand.status == TOModelStatus_ActYes) return nil;
        
        //11. 未感性淘汰的,一条路走到黑(递归循环),然后把最后的结果return返回;
        return [self bestEndBranch4Plan:scoreDic curDemand:subDemand demandScore:demandScore];
    }
    
    //12. bestFo没有子任务subDemands可决策的,则直接执行bestFo为末枝 (参考25042-8);
    NSLog(@"取分: K:%@ => V:%@分",TOModel2Key(bestFo),[scoreDic objectForKey:TOModel2Key(bestFo)]);
    [AITest test10:bestFo];
    return bestFo;
}

@end
