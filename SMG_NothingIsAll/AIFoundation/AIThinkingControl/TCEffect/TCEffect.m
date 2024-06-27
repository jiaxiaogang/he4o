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
 *      2023.05.18: BUG_修复fatherCanset更新的scene错误导致EFF更新错误问题 (参考29095-修复);
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
    if (Log4Effect) NSLog(@"---//rEffect触发器新增:%p (%@ | 触发时间:%.2f)",rDemand,TOStatus2Str(rDemand.status),triggerTime);
    [AITime setTimeTrigger:triggerTime trigger:^{
        //2. 取有效性 (默认即有效);
        EffectStatus es = rDemand.effectStatus == ES_NoEff ? ES_NoEff : ES_HavEff;
        
        //3. 有效,则解决方案成功 & 任务成功;
        //if (tp == ATPlus) {
        if (es == ES_HavEff) {
            rSolution.status = TOModelStatus_Finish;
            rDemand.status = TOModelStatus_Finish;
        }
        
        //2024.05.08: 整理代码,此处其实就是给rSolution的sceneTo和cansetTo更新eff值;
        //5. 更新effectDic;
        AIFoNodeBase *baseScene = [SMGUtils searchNode:rSolution.sceneTo];
        AIFoNodeBase *cansetTo = [SMGUtils searchNode:rSolution.transferSiModel.canset];
        AIEffectStrong *strong = [baseScene updateEffectStrong:baseScene.count solutionFo:cansetTo.p status:es];
        if (Log4Effect) IFTitleLog(@"rEffect", @"\n%p Scene:%@ (有效性:%@ 任务状态:%@)\nEff更新Scene:F%ld S:%@ (index:%ld H%ldN%ld)",rDemand,Fo2FStr(baseScene),EffectStatus2Str(es),TOStatus2Str(rDemand.status),baseScene.pId,Fo2FStr(cansetTo),baseScene.count,strong.hStrong,strong.nStrong);
        
        //6. 对抽象也更新eff (此处canset.count应该和rSolution.targetIndex是一样的) (参考29069-todo11.5);
        [TCRethinkUtil spEff4Abs:cansetTo curFoIndex:cansetTo.count itemRunBlock:^(AIFoNodeBase *absFo, NSInteger absIndex) {
            AIEffectStrong *strong = [baseScene updateEffectStrong:baseScene.count solutionFo:absFo.pointer status:es];
            if (Log4Effect) NSLog(@"\tEff更新scene:F%ld absS:%@ (index:%ld H%ldN%ld)",baseScene.pId,Fo2FStr(absFo),baseScene.count,strong.hStrong,strong.nStrong);
        }];
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
    double deltaTime = [TOUtils getSumDeltaTime:solutionFo startIndex:0 endIndex:hSolution.cansetTargetIndex];
    
    //2. 数据准备;
    HDemandModel *hDemand = (HDemandModel*)hSolution.baseOrGroup;
    TOFoModel *targetFo = (TOFoModel*)hDemand.baseOrGroup.baseOrGroup;
    AIFoNodeBase *targetFoNode = [SMGUtils searchNode:targetFo.content_p];
    NSInteger targetFoActIndex = targetFo.cansetActIndex;
    
    //3. 触发器;
    deltaTime *= 3.0f;
    if (Log4Effect) NSLog(@"---//hEffect触发器新增:%p (%@ | 触发时间:%.2f)",hSolution,TOStatus2Str(hDemand.status),deltaTime);
    [AITime setTimeTrigger:deltaTime trigger:^{
        //4. 取有效性 (默认即无效);
        EffectStatus es = hDemand.effectStatus == ES_HavEff ? ES_HavEff : ES_NoEff;
        
        //5. 无效,则当前方案失败;
        if (es == ES_NoEff) hSolution.status = TOModelStatus_ActNo;
        //if (tp == ATSub) hSolution.status = TOModelStatus_ActNo;
        
        //6. 取出所有需要eff更新的cansets;
        AIKVPointer *canset_p = hSolution.transferSiModel.canset;
        
        //7. 更新effectDic;
        [targetFoNode updateEffectStrong:targetFoActIndex solutionFo:canset_p status:es];
        //[targetFoNode updateSPStrong:targetFo.actionIndex type:tp];
        
        //8. 对抽象也更新eff (参考29069-todo11.5);
        AIFoNodeBase *canset = [SMGUtils searchNode:canset_p];
        [TCRethinkUtil spEff4Abs:canset curFoIndex:hSolution.cansetTargetIndex itemRunBlock:^(AIFoNodeBase *absFo, NSInteger absIndex) {
            [targetFoNode updateEffectStrong:targetFoActIndex solutionFo:absFo.pointer status:es];
        }];
        
        //8. log
        AIEffectStrong *strong = [TOUtils getEffectStrong:targetFoNode effectIndex:targetFoActIndex solutionFo:canset_p];
        if (Log4Effect) IFTitleLog(@"hEffect", @"\n%p S:%@ (有效性:%@ 当前方案状态:%@)",hSolution,Pit2FStr(canset_p),EffectStatus2Str(es),TOStatus2Str(hSolution.status));
        NSLog(@"\t=>targetFo:%@ (index:%ld H%ldN%ld)",Fo2FStr(targetFoNode),targetFoActIndex,strong.hStrong,strong.nStrong);
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
