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
 *      2022.05.27: 将effect改为行为化首帧O反省 (参考26127-TODO1);
 *      2022.05.28: 不需要effect做首帧反省了,tcActYes支持每帧O反省 (参考26136-方案);
 */
+(void) rEffect:(TOFoModel*)rSolution{
    [theTC updateOperCount:kFILENAME];
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
    maxDeltaTime *= 3.0f;
    NSLog(@"---//rEffect触发器新增:%p (%@ | 触发时间:%.2f)",rDemand,TOStatus2Str(rDemand.status),maxDeltaTime);
    [AITime setTimeTrigger:maxDeltaTime trigger:^{
        //2. 取有效性 (默认即有效);
        EffectStatus es = rDemand.effectStatus == ES_NoEff ? ES_NoEff : ES_HavEff;
        //AnalogyType tp = rDemand.effectStatus == ES_NoEff ? ATSub : ATPlus;
        
        //3. 更新effectDic;
        //AIFoNodeBase *solutionFo = [SMGUtils searchNode:rSolution.content_p];
        //[solutionFo updateSPStrong:solutionFo.count type:tp];
        for (AIMatchFoModel *pFoModel in rDemand.pFos) {
            AIFoNodeBase *pFo = [SMGUtils searchNode:pFoModel.matchFo];
            [pFo updateEffectStrong:pFo.count solutionFo:rSolution.content_p status:es];
        }
        
        //3. 有效,则解决方案成功 & 任务成功;
        //if (tp == ATPlus) {
        if (es == ES_HavEff) {
            rSolution.status = TOModelStatus_Finish;
            rDemand.status = TOModelStatus_Finish;
        }
        
        //4. log;
        IFTitleLog(@"rSolution反省", @"\n%p S:%@ (有效性:%@ 任务状态:%@)",rDemand,Pit2FStr(rSolution.content_p),EffectStatus2Str(es),TOStatus2Str(rDemand.status));
        for (AIMatchFoModel *pFoModel in rDemand.pFos) {
            AIFoNodeBase *pFo = [SMGUtils searchNode:pFoModel.matchFo];
            AIEffectStrong *strong = [TOUtils getEffectStrong:pFo effectIndex:pFo.count solutionFo:rSolution.content_p];
            NSLog(@"\t=>pFo:%@ (index:%ld H%ldN%ld)",Fo2FStr(pFo),pFo.count,strong.hStrong,strong.nStrong);
        }
    }];
    DebugE();
}

/**
 *  MARK:--------------------H任务有效率--------------------
 *  @version
 *      2022.05.22: 初版,任务有效率强化 (将ES状态更新至任务targetFo下的effectDic中) (参考26095-4&5);
 *      2022.05.27: 将effect改为行为化首帧O反省 (参考26127-TODO1);
 *      2022.05.28: 不需要effect做首帧反省了,tcActYes支持每帧O反省 (参考26136-方案);
 */
+(void) hEffect:(TOFoModel*)hSolution{
    [theTC updateOperCount:kFILENAME];
    Debug();
    //1. 取deltaTime;
    AIFoNodeBase *solutionFo = [SMGUtils searchNode:hSolution.content_p];
    double deltaTime = [TOUtils getSumDeltaTime:solutionFo startIndex:0 endIndex:hSolution.targetSPIndex];
    
    //2. 数据准备;
    HDemandModel *hDemand = (HDemandModel*)hSolution.baseOrGroup;
    TOFoModel *targetFo = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFoNode = [SMGUtils searchNode:targetFo.content_p];
    
    //3. 触发器;
    deltaTime *= 3.0f;
    NSLog(@"---//hEffect触发器新增:%p (%@ | 触发时间:%.2f)",hSolution,TOStatus2Str(hDemand.status),deltaTime);
    [AITime setTimeTrigger:deltaTime trigger:^{
        //4. 取有效性 (默认即无效);
        EffectStatus es = hDemand.effectStatus == ES_HavEff ? ES_HavEff : ES_NoEff;
        //AnalogyType tp = hDemand.effectStatus == ES_HavEff ? ATPlus : ATSub;
        
        //5. 更新effectDic;
        [targetFoNode updateEffectStrong:targetFo.actionIndex solutionFo:hSolution.content_p status:es];
        //[targetFoNode updateSPStrong:targetFo.actionIndex type:tp];

        //6. 无效,则当前方案失败;
        if (es == ES_NoEff) hSolution.status = TOModelStatus_ActNo;
        //if (tp == ATSub) hSolution.status = TOModelStatus_ActNo;
        
        //7. log
        AIEffectStrong *strong = [TOUtils getEffectStrong:targetFoNode effectIndex:targetFo.actionIndex solutionFo:hSolution.content_p];
        IFTitleLog(@"HSolution反省", @"\n%p S:%@ (有效性:%@ 当前方案状态:%@)",hSolution,Pit2FStr(hSolution.content_p),EffectStatus2Str(es),TOStatus2Str(hSolution.status));
        NSLog(@"\t=>targetFo:%@ (index:%ld H%ldN%ld)",Fo2FStr(targetFoNode),targetFo.actionIndex,strong.hStrong,strong.nStrong);
    }];
    DebugE();
}

@end
