//
//  TCDemand.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCDemand.h"

@implementation TCDemand

/**
 *  MARK:--------------------r预测--------------------
 *  @version
 *      2021.12.05: 原本只有tor受阻时才执行solution,现改为不依赖tor,因为tor改到概念识别之后了 (参考24171-9);
 */
+(void) rDemand:(AIShortMatchModel*)model{
    //2. 预测处理_把mv加入到demandManager;
    [theTC.outModelManager updateCMVCache_RMV:model];
    
    //6. 此处推进不成功,则运行TOP四模式;
    BOOL torOPushMSuccess = false;
    if (!torOPushMSuccess) {
        [TCSolution solution];
    }
}

/**
 *  MARK:--------------------p任务--------------------
 *  @desc 功能说明:
 *      1. 更新energy值
 *      2. 更新需求池
 *      3. 进行dataOut决策行为化;
 */
+(void) pDemand:(AICMVNode*)cmvNode{
    //1. 将联想到的cmv更新energy & 更新demandManager & decisionLoop
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    [theTC.outModelManager updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta];
    
    //2. 转向执行;
    [TCSolution solution];
}

//交由DemandManager构建任务完成;
+(void) subDemand:(AIShortMatchModel*)rtInModel foModel:(TOFoModel*)foModel{
    
    
    //TODOTOMORROW20211128: 构建任务树 (将DemandManager代码整理过来);
    
    //5. 提交子任务;
    __block NSArray *except_ps = nil;
    [DemandManager updateSubDemand:rtInModel baseFo:foModel createSubDemandBlock:^(ReasonDemandModel *subDemand) {
        
        //6. 子任务行为化,转TCSolution;
        [TCSolution rSolution:subDemand];
        //return;//子任务Finish/ActYes时,不return,因为要继续父任务;
        
    } finishBlock:^(NSArray *_except_ps) {
        except_ps = _except_ps;
    }];
    
    
    
    
    
    
    //TODOTOMORROW20211128: 当前父任务下挂载的:所有子任务处理;
    //  a1: 有子任务还没决策时,转solution找解决方案 --> 转solution();
    //  a2: 全部子任务决策过后,剩下无法实践解决的价值之和,是否使其足够放弃当前父任务; (比如又累又烦的活,赚钱也不干) --> 失败递归;
    
    //8. 子任务尝试完成后,进行FPS综合评价 (如果子任务完成后,依然有解决不了的不愿意的价值,则不通过);
    NSArray *except_ps = nil;//不应期 = 当前所有子任务 - 已解决的 - actYes中的;
    BOOL scoreSuccess = [AIScore FPS:foModel rtInModel:rtInModel except_ps:except_ps];
    NSLog(@"未发生感性评价(反思)-%@",scoreSuccess ? @"通过 (继续父fo行为化)" : @"不通过 (中断父fo行为化)");
    if (!scoreSuccess) {
        foModel.status = TOModelStatus_ScoreNo;
        [theTOR singleLoopBackWithFailureModel:foModel];
        return;
    }
    
    
}

+(void) feedbackDemand:(AIShortMatchModel*)model{
    
    
    //----------TODOTOMORROW20211205: 反馈feedback后,生成子任务;
    //2. 子任务能解决便解决,解决不了的(也有可能是因为来不及,所以解决方案失败);
    //3. 识别结果pFos挂载到focusFo下做子任务 (好的坏的全挂载,比如做的饭我爱吃{MV+},但是又太麻烦{MV-});
    //4. 然后分析下,到TCDemand中,能否从root自动调用继续决策螺旋 (一个个一层层进行综合pk);
    //3. 无论子任务是否解决,都回来判综合评分pk,比如子任务不解决我也要继续父任务;
    

}

+(void) hDemand:(TOAlgModel*)algModel{
    //对algModel生成H任务,并挂载在当前短时记忆分支下;
    HDemandModel *hDemand = [HDemandModel newWithAlgModel:algModel];
    [TCSolution hSolution:hDemand];
    
    //TODOTOMORROW20211128: 如果algModel失败,可以考虑对它的具象生成H任务,比如找武器时,可以想到拿刀,然后再想到厨房,而不是直接根据武器就想到厨房;
}

@end
