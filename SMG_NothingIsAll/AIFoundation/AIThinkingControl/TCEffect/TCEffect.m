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
+(void) rEffect:(TOFoModel*)rSolution{
    [theTC updateOperCount];
    Debug();
    //1. 取deltaTime;
    ReasonDemandModel *rDemand = (ReasonDemandModel*)rSolution.baseOrGroup;
    double maxDeltaTime = 0;
    for (AIMatchFoModel *pFo in rDemand.pFos) {
        AIFoNodeBase *fo = [SMGUtils searchNode:pFo.matchFo];
        double deltaTime = [TOUtils getSumDeltaTime2Mv:fo cutIndex:pFo.cutIndex2];
        maxDeltaTime = MAX(maxDeltaTime, deltaTime);
    }
    
    //2. 触发器;
    maxDeltaTime *= 1.5f;
    NSLog(@"---//rEffect触发器新增:%p (%@ | 触发时间:%.2f)",rDemand,TOStatus2Str(rDemand.status),maxDeltaTime);
    [AITime setTimeTrigger:maxDeltaTime trigger:^{
        //2. 取有效性 (默认即有效);
        EffectStatus es = rDemand.effectStatus == ES_NoEff ? ES_NoEff : ES_HavEff;
        
        //3. 更新effectDic;
        for (AIMatchFoModel *pFoModel in rDemand.pFos) {
            AIFoNodeBase *pFo = [SMGUtils searchNode:pFoModel.matchFo];
            [pFo updateEffectStrong:pFo.count solutionFo:rSolution.content_p status:es];
        }
        
        //3. 有效,则解决方案成功 & 任务成功;
        if (es == ES_HavEff) {
            rSolution.status = TOModelStatus_Finish;
            rDemand.status = TOModelStatus_Finish;
        }
        
        //4. log;
        IFTitleLog(@"R有效率", @"\n%p S:%@ (有效性:%@ 任务状态:%@)",rDemand,Pit2FStr(rSolution.content_p),EffectStatus2Str(es),TOStatus2Str(rDemand.status));
        for (AIMatchFoModel *pFoModel in rDemand.pFos) {
            AIFoNodeBase *pFo = [SMGUtils searchNode:pFoModel.matchFo];
            NSString *desc = [TOUtils getEffectDesc:pFo effectIndex:pFo.count solutionFo:rSolution.content_p];
            NSLog(@"\t=>pFo:%@ (index:%ld mv有效率:%@)",Fo2FStr(pFo),pFo.count,desc);
        }
    }];
    DebugE();
}

/**
 *  MARK:--------------------H任务有效率--------------------
 *  @version
 *      2022.05.22: 初版,任务有效率强化 (将ES状态更新至任务targetFo下的effectDic中) (参考26095-4&5);
 */
+(void) hEffect:(TOFoModel*)hSolution{
    [theTC updateOperCount];
    Debug();
    //1. 取deltaTime;
    AIFoNodeBase *solutionFo = [SMGUtils searchNode:hSolution.content_p];
    double deltaTime = [TOUtils getSumDeltaTime:solutionFo startIndex:0 endIndex:hSolution.targetSPIndex];
    
    //2. 数据准备;
    HDemandModel *hDemand = (HDemandModel*)hSolution.baseOrGroup;
    TOFoModel *targetFo = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFoNode = [SMGUtils searchNode:targetFo.content_p];
    
    //3. 触发器;
    deltaTime *= 1.5f;
    NSLog(@"---//hEffect触发器新增:%p (%@ | 触发时间:%.2f)",hSolution,TOStatus2Str(hDemand.status),deltaTime);
    [AITime setTimeTrigger:deltaTime trigger:^{
        //4. 取有效性 (默认即无效);
        EffectStatus es = hDemand.effectStatus == ES_HavEff ? ES_HavEff : ES_NoEff;
        
        //5. 更新effectDic;
        [targetFoNode updateEffectStrong:targetFo.actionIndex solutionFo:hSolution.content_p status:es];

        //6. 无效,则当前方案失败;
        if (es == ES_NoEff) hSolution.status = TOModelStatus_ActNo;
        
        //7. log
        NSString *desc = [TOUtils getEffectDesc:targetFoNode effectIndex:targetFo.actionIndex solutionFo:hSolution.content_p];
        IFTitleLog(@"H有效率", @"\n%p S:%@ (有效性:%@ 当前方案状态:%@)",hSolution,Pit2FStr(hSolution.content_p),EffectStatus2Str(es),TOStatus2Str(hSolution.status));
        NSLog(@"\t=>targetFo:%@ (index:%ld mv有效率:%@)",Fo2FStr(targetFoNode),targetFo.actionIndex,desc);
    }];
    DebugE();
}

@end
