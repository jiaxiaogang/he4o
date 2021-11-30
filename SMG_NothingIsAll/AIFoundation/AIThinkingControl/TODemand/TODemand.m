//
//  TODemand.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TODemand.h"

@implementation TODemand

+(void) rDemand:(AIShortMatchModel*)model{
    //2. 预测处理_把mv加入到demandManager;
    [theTC.outModelManager updateCMVCache_RMV:model];
}

//交由DemandManager构建任务完成;
+(void) demand:(AIShortMatchModel*)rtInModel{
    
    
    //TODOTOMORROW20211128: 构建任务树 (将DemandManager代码整理过来);
    
    //5. 提交子任务;
    __block NSArray *except_ps = nil;
    [DemandManager updateSubDemand:rtInModel baseFo:foModel createSubDemandBlock:^(ReasonDemandModel *subDemand) {
        
        //6. 子任务行为化;
        [self.delegate toAction_SubModelBegin:subDemand];
        //return;//子任务Finish/ActYes时,不return,因为要继续父任务;
    } finishBlock:^(NSArray *_except_ps) {
        except_ps = _except_ps;
    }];
    
    
    
    
    
    
    //TODOTOMORROW20211128: 当前父任务下挂载的:所有子任务处理;
    //  a1: 有子任务还没决策时,转solution找解决方案 --> 转solution();
    //  a2: 全部子任务决策过后,剩下无法实践解决的价值之和,是否使其足够放弃当前父任务; (比如又累又烦的活,赚钱也不干) --> 失败递归;
    
    //8. 子任务尝试完成后,进行FPS综合评价 (如果子任务完成后,依然有解决不了的不愿意的价值,则不通过);
    __block NSArray *except_ps = nil;//不应期 = 当前所有子任务 - 已解决的 - actYes中的;
    BOOL scoreSuccess = [AIScore FPS:foModel rtInModel:rtInModel except_ps:except_ps];
    NSLog(@"未发生感性评价(反思)-%@",scoreSuccess ? @"通过 (继续父fo行为化)" : @"不通过 (中断父fo行为化)");
    if (!scoreSuccess) {
        foModel.status = TOModelStatus_ScoreNo;
        [self.delegate toAction_SubModelFailure:foModel];
        return;
    }
    
    
}

+(void) hDemand:(TOAlgModel*)algModel{
    //对algModel生成H任务,并挂载在当前短时记忆分支下;
    HDemandModel *hDemand = [HDemandModel newWithAlgModel:algModel];
    [TOSolution hSolution:hDemand];
    
    //TODOTOMORROW20211128: 如果algModel失败,可以考虑对它的具象生成H任务,比如找武器时,可以想到拿刀,然后再想到厨房,而不是直接根据武器就想到厨房;
}

@end
