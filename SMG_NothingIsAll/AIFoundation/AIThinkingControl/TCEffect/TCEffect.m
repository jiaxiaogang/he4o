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
 *      2023.02.14: 当前effect仅对取得solution的pFo有效 (参考28076);
 *      2023.04.19: 支持canset迁移的EFF统计 (参考29069-todo11);
 */
+(void) rEffect:(TOFoModel*)rSolution{
    [theTC updateOperCount:kFILENAME];
    Debug();
    //1. 取deltaTime;
    ReasonDemandModel *rDemand = (ReasonDemandModel*)rSolution.baseOrGroup;
    AIMatchFoModel *pFo = (AIMatchFoModel*)rSolution.basePFoOrTargetFoModel;
    AIFoNodeBase *baseFo = [SMGUtils searchNode:pFo.matchFo];
    double deltaTime = [TOUtils getSumDeltaTime2Mv:baseFo cutIndex:pFo.cutIndex];
    double triggerTime = deltaTime * 3.0f;
    
    //2. 触发器;
    NSLog(@"---//rEffect触发器新增:%p (%@ | 触发时间:%.2f)",rDemand,TOStatus2Str(rDemand.status),triggerTime);
    [AITime setTimeTrigger:triggerTime trigger:^{
        //2. 取有效性 (默认即有效);
        EffectStatus es = rDemand.effectStatus == ES_NoEff ? ES_NoEff : ES_HavEff;
        
        //3. 有效,则解决方案成功 & 任务成功;
        //if (tp == ATPlus) {
        if (es == ES_HavEff) {
            rSolution.status = TOModelStatus_Finish;
            rDemand.status = TOModelStatus_Finish;
        }
        
        //4. 取出所有需要eff更新的cansets;
        NSArray *canset_ps = [rSolution getRethinkEffectCansets];
        for (AIKVPointer *canset_p in canset_ps) {
            //5. 更新effectDic;
            //[solutionFo updateSPStrong:solutionFo.count type:tp];
            [baseFo updateEffectStrong:baseFo.count solutionFo:canset_p status:es];
            
            //6. 对抽象也更新eff (此处canset.count应该和rSolution.targetIndex是一样的) (参考29069-todo11.5);
            AIFoNodeBase *canset = [SMGUtils searchNode:canset_p];
            [TCRethinkUtil spEff4Abs:canset curFoIndex:canset.count itemRunBlock:^(AIFoNodeBase *absFo, NSInteger absIndex) {
                [baseFo updateEffectStrong:baseFo.count solutionFo:absFo.pointer status:es];
            }];
            
            //6. log;
            AIEffectStrong *strong = [TOUtils getEffectStrong:baseFo effectIndex:baseFo.count solutionFo:canset_p];
            IFTitleLog(@"rEffect", @"\n%p S:%@ (有效性:%@ 任务状态:%@)\n\tfromPFo:%@ (index:%ld H%ldN%ld)",rDemand,Pit2FStr(canset_p),EffectStatus2Str(es),TOStatus2Str(rDemand.status),Fo2FStr(baseFo),baseFo.count,strong.hStrong,strong.nStrong);
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
 *      2023.04.19: 支持canset迁移的EFF统计 (参考29069-todo11);
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
        
        //5. 无效,则当前方案失败;
        if (es == ES_NoEff) hSolution.status = TOModelStatus_ActNo;
        //if (tp == ATSub) hSolution.status = TOModelStatus_ActNo;
        
        //6. 取出所有需要eff更新的cansets;
        NSArray *canset_ps = [hSolution getRethinkEffectCansets];
        for (AIKVPointer *canset_p in canset_ps) {
            //7. 更新effectDic;
            [targetFoNode updateEffectStrong:targetFo.actionIndex solutionFo:canset_p status:es];
            //[targetFoNode updateSPStrong:targetFo.actionIndex type:tp];
            
            //8. 对抽象也更新eff (参考29069-todo11.5);
            AIFoNodeBase *canset = [SMGUtils searchNode:canset_p];
            [TCRethinkUtil spEff4Abs:canset curFoIndex:hSolution.targetSPIndex itemRunBlock:^(AIFoNodeBase *absFo, NSInteger absIndex) {
                [targetFoNode updateEffectStrong:targetFo.actionIndex solutionFo:absFo.pointer status:es];
            }];
            
            //8. log
            AIEffectStrong *strong = [TOUtils getEffectStrong:targetFoNode effectIndex:targetFo.actionIndex solutionFo:canset_p];
            IFTitleLog(@"hEffect", @"\n%p S:%@ (有效性:%@ 当前方案状态:%@)",hSolution,Pit2FStr(canset_p),EffectStatus2Str(es),TOStatus2Str(hSolution.status));
            NSLog(@"\t=>targetFo:%@ (index:%ld H%ldN%ld)",Fo2FStr(targetFoNode),targetFo.actionIndex,strong.hStrong,strong.nStrong);
        }
    }];
    DebugE();
}

///**
// *  MARK:--------------------输入期eff有效率 (参考28182-todo6&7)--------------------
// */
//+(void) rInEffect:(AIFoNodeBase*)pFo matchRFos:(NSArray*)matchRFos es:(EffectStatus)es{
//    [theTC updateOperCount:kFILENAME];
//    Debug();
//    //1. 取交集: matchFo下的cansets与matchRFos取交集 (参考28182-todo6-场景判断);
//    NSArray *cansets = [pFo getConCansets:pFo.count];
//    NSArray *cansetRFos = [SMGUtils filterArr:matchRFos checkValid:^BOOL(AIMatchFoModel *item) {
//        return [cansets containsObject:item.matchFo];
//    }];
//    
//    //2. 对交集canset进行effect计数更新;
//    for (AIMatchFoModel *item in cansetRFos) {
//        AIEffectStrong *strong = [pFo updateEffectStrong:pFo.count solutionFo:item.matchFo status:es];
//        IFTitleLog(@"rInEffect", @"\nS:%@ (有效性:%@)\n\tfromPFo:%@ (index:%ld H%ldN%ld)",Pit2FStr(item.matchFo),EffectStatus2Str(es),Fo2FStr(pFo),pFo.count,strong.hStrong,strong.nStrong);
//    }
//    DebugE();
//}

@end
