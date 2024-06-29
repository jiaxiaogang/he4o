//
//  TCRefrection.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/8/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "TCRefrection.h"

@implementation TCRefrection


//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------反思--------------------
 *  @desc 反思评分 (本方法中,根据checkCanset自身的spDic,前段相似度,懒值等,共同算出综合评分);
 *  _param protoCansets : 所在的源候选集 (原始proto候选集);
 *  @param demand   : 所在的源demand;
 *  @version
 *      2022.07.16: 写S评分pk (参考27048-TODO3 & 27049-TODO4);
 *      2022.09.26: cansets由可用方案候选集,改成原始候选集 (参考27123-问题3-方案);
 *      2022.09.26: 将limit保留最少3条 (因为发生了明明有1条,反而只限高没限低,导致被截剩0条了的问题);
 *      2022.11.30: 反思不需要识别,因为cansets都是同级,没法复用indexDic等,并且相似也不表示同场景 (而现在相似的抽具象已支持) (参考27211-todo2);
 *      2023.05.26: 计算canset稳定性改为有效性(sp改为eff得分),因为canset复现率低,几乎全是0分 (参考2909a-todo2);
 *      2023.05.26: BUG_修复计算cansetFenXianScore时,取cansetFo.cmvNode_p导致怎么都算出来是0分问题;
 */
+(BOOL) refrection:(TOFoModel*)checkCanset demand:(DemandModel*)demand{
    //1. 数据准备;
    [theTC updateOperCount:kFILENAME];
    Debug();
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:checkCanset.cansetFo];
    AIFoNodeBase *sceneFo = [SMGUtils searchNode:checkCanset.sceneFo];
    
    //4. 算出如果canset无效,会带来的风险;
    CGFloat nEffScore = 1 - [TOUtils getEffectScore:sceneFo effectIndex:checkCanset.sceneTargetIndex solutionFo:checkCanset.cansetFo];
    OFTitleLog(@"TCRefrection反思", @"\n%@ CUT:%ld 无效率:%.2f",ShortDesc4Pit(checkCanset.cansetFo),(long)checkCanset.cansetCutIndex,nEffScore);
    
    //5. 算出因canset无效,带来的风险分 = Eff为N的概率 x scene的mv评分;
    CGFloat canestFenXianScore = [AIScore score4MV:sceneFo.cmvNode_p ratio:nEffScore];
    
    //7. 算出后段的"懒"评分 (最后一帧静默等待不需要行为化,所以小于cansetTargetIndex即可);
    CGFloat lazyScore = 0;
    for (NSInteger i = checkCanset.cansetActIndex; i < checkCanset.cansetTargetIndex; i++) {
        //8. 遍历后半段中的"isOut=true"的行为,各指定"懒"评分;
        AIKVPointer *alg_p = ARR_INDEX(cansetFo.content_ps, i);
        if (alg_p && alg_p.isOut) {
            lazyScore -= 0.5f;
        }
    }
    
    //10. 计算解决任务奖励评分: 取负的baseRDemand评分 (参考27057);
    NSArray *rootDemands = [TOUtils getBaseDemands_AllDeep:demand];
    rootDemands = [SMGUtils filterArr:rootDemands checkValid:^BOOL(id item) {
        return ISOK(item, ReasonDemandModel.class);
    }];
    ReasonDemandModel *baseRDemand = ARR_INDEX_REVERSE(rootDemands, 0);
    CGFloat demandJianLiScore = -[AIScore score4Demand:baseRDemand];
    
    //11. S评分PK: pk通过 = 任务评分 - 方案评分 - 懒评分 > 0;
    //12. 三个评分都是负的,所以公式为以下 (result = 收益(负任务分) + mv的负分 + lazy的负分 > 0);
    CGFloat sumScore = demandJianLiScore + canestFenXianScore + lazyScore;
    BOOL result = sumScore > 0;
    NSLog(@"反思评价结果:%@通过 (解决任务奖励分%.1f Canset风险:%.2f 懒分:%.1f = %.1f)",result?@"已":@"未",demandJianLiScore,canestFenXianScore,lazyScore,sumScore);
    [AITest test21:result];
    DebugE();
    return result;
}

/**
 *  MARK:--------------------行为化反思--------------------
 *  @desc 对比当前foModel能解决的任务分 与 子任务带来的最严重负分 => 得出反思结果 (参考30054-todo6);
 *  @version
 *      2023.07.14: 子任务评分降权至60%,以增强连续行为化意愿 (参考3005a-方案1);
 *      2024.06.29: 子任务评分由最严重 改为 平均分 (参考32015-方案2);
 */
+(BOOL) actionRefrection:(TOFoModel*)baseFoModel {
    //1. 根据foModel向上找出rDemand的评分;
    [theTC updateOperCount:kFILENAME];
    Debug();
    OSTitleLog(@"行为化前 反思评价");
    ReasonDemandModel *baseRDemand = ARR_INDEX([TOUtils getBaseRDemands_AllDeep:baseFoModel], 0);
    if (!baseRDemand) return true;
    CGFloat demandScore = [AIScore score4Demand:baseRDemand];
    
    //2. 根据foModel向下取出subDemands的评分 (取最严重的一条subDemand分);
    //2024.06.29: 改为取平均分 (参考32015-方案2);
    float sumScore = 0;
    for (DemandModel *item in baseFoModel.subDemands) {
        CGFloat curSubScore = [AIScore score4Demand:item];
        sumScore += curSubScore;
    }
    CGFloat averageScore = baseFoModel.subDemands.count > 0 ? sumScore / baseFoModel.subDemands.count : 0;
    
    //2. 子任务评分降权至70% (参考3005a-方案1);
    averageScore *= 0.7f;
    
    //3. 对比二者,得出反思是否通过 (最严重也不比当前重要时,反思通过) (参考30054-todo6);
    BOOL result = averageScore > demandScore;
    NSLog(@"> 子任务分:%.2f > 当前任务分(%@):%.2f =====> %@通过",averageScore,ClassName2Str(baseRDemand.algsType),demandScore,result?@"已":@"未");
    DebugE();
    return result;
}

@end
