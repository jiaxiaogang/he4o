//
//  TCEffect.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/5/22.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TCEffect.h"

@implementation TCEffect

/**
 *  MARK:--------------------R任务有效率--------------------
 *  @version
 *      2022.05.22: 初版,任务有效率强化 (将ES状态更新至任务pFo下的effectDic中) (参考26095-1&2);
 */
+(void) rEffect:(ReasonDemandModel*)rDemand{
    [theTC updateOperCount];
    Debug();
    //1. 取deltaTime;
    double maxDeltaTime = 0;
    for (AIMatchFoModel *pFo in rDemand.pFos) {
        AIFoNodeBase *fo = [SMGUtils searchNode:pFo.matchFo];
        double deltaTime = [TOUtils getSumDeltaTime2Mv:fo cutIndex:pFo.cutIndex2];
        maxDeltaTime = MAX(maxDeltaTime, deltaTime);
    }
    
    maxDeltaTime *= 1.3f;
    NSLog(@"---//rEffect触发器新增:%p (%@ | 触发时间:%.2f)",rDemand,TOStatus2Str(rDemand.status),maxDeltaTime);
    [AITime setTimeTrigger:maxDeltaTime trigger:^{
        //2. 取有效性 (默认即有效);
        EffectStatus es = rDemand.effectStatus == ES_NoEff ? ES_NoEff : ES_HavEff;
        
        //3. 更新effectDic;
        for (AIMatchFoModel *pFoModel in rDemand.pFos) {
            AIFoNodeBase *pFo = [SMGUtils searchNode:pFoModel.matchFo];
            for (TOFoModel *solutionModel in rDemand.actionFoModels) {
                [pFo updateEffectStrong:pFo.count solutionFo:solutionModel.content_p status:es];
            }
        }
        
        //3. 有效,则任务成功;
        if (es == ES_HavEff) rDemand.status = TOModelStatus_Finish;
        NSLog(@"---//rEffect触发器执行:%p 有效性:%@ 任务状态:%@",rDemand,EffectStatus2Str(es),TOStatus2Str(rDemand.status));
    }];
    DebugE();
}

+(void) hEffect:(HDemandModel*)hDemand{
    
}

@end
