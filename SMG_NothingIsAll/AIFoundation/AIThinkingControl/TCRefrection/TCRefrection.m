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
+(BOOL) refrection:(AICansetModel*)checkCanset demand:(DemandModel*)demand{
    //1. 数据准备;
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:checkCanset.cansetFo];
    AIFoNodeBase *sceneFo = [SMGUtils searchNode:checkCanset.sceneFo];
    
    //4. 算出如果canset无效,会带来的风险;
    CGFloat nEffScore = 1 - [TOUtils getEffectScore:sceneFo effectIndex:checkCanset.sceneTargetIndex solutionFo:checkCanset.cansetFo];
    OFTitleLog(@"TCRefrection反思", @"\n%@ CUT:%ld 前匹配度%.2f 无效率:%.2f",Pit2FStr(checkCanset.cansetFo),(long)checkCanset.cutIndex,checkCanset.frontMatchValue,nEffScore);
    
    //5. 算出因canset无效,带来的风险分 = Eff为N的概率 x scene的mv评分;
    CGFloat canestFenXianScore = [AIScore score4MV:sceneFo.cmvNode_p ratio:nEffScore];
    
    //7. 算出后段的"懒"评分;
    CGFloat lazyScore = 0;
    for (NSInteger i = checkCanset.cutIndex + 1; i < cansetFo.count; i++) {
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
    return result;
}

/**
 *  MARK:--------------------任务树反思--------------------
 *  @desc 判断当前输出,对任务树别的任务的不良影响,影响大则反思不通过,不大则通过 (参考30052-方案);
 */
+(void) refrection4DemandTree:(AICansetModel*)checkCanset demand:(DemandModel*)demand {
    //1. 数据准备;
    NSArray *roots = [theTC.outModelManager.getAllDemand copy];
    for (ReasonDemandModel *root in roots) {
        //2. 任务类型非R时,或为当前demand时,跳过;
        if (!ISOK(root, ReasonDemandModel.class)) continue;
        if ([root isEqual:demand]) continue;
        
        //3. 对有效pFos进行反思;
        for (AIMatchFoModel *pFo in root.validPFos) {
            
            //1. 截出pFo中含cutIndex部分 (参考30052-todo2);
            AIFoNodeBase *pFoNode = [SMGUtils searchNode:pFo.matchFo];
            NSArray *frontContent_ps = ARR_SUB(pFoNode.content_ps, 0, pFo.cutIndex + 1);
            
            //2. canset的cutIndex已发生,只截出它的后面,到targetIndex(含targetIndex,如果它存在的话)之间部分 (参考30052-todo2);
            AIFoNodeBase *cansetFo = [SMGUtils searchNode:checkCanset.cansetFo];
            NSInteger length = checkCanset.targetIndex - checkCanset.cutIndex; //如目标为3,截点为1,则取2和3两帧 (即length=目标-截点);
            NSArray *backContent_ps = ARR_SUB(cansetFo.content_ps, checkCanset.cutIndex + 1, length);
            
            //3. 将前后两部分拼接起来 (参考30052-todo2);
            NSArray *regroup_ps = [SMGUtils collectArrA:frontContent_ps arrB:backContent_ps];
            
            //4. 出取pFo的cansets;
            NSArray *oldCansets = [pFoNode getConCansets:pFoNode.count];
            
            
            //TODOTOMORROW20230705: 继续写任务树反思功能;
            
            //5. 然后取pFo.cansets中进行识别;
            //[TIUtils recognitionCansetFo:pFo.matchFo sceneFo:nil];
            //看下识别算法,怎么写
            //  1. 这里不会为regroup生成fo;
            //  2. 看下这里的regroup和oldCansets之间怎么判断全含?是哪个mIsC哪个;
            
            //  3. 其实pFo的front部分不用识别,它已发生,且在cansets中本来就有相对应的满足;
            //  4. 而back部分,mIsC怎么判断,通过实例来分析:
            //      > 比如:pFo为疼,cansets其中一条为:车撞到会疼;
            //              疑问: 不解决问题的canset似乎不会生成吧?
            //              分析: 有可能迁移来,但在无效后再判为否,但即使它无效未必是因为它的锅,也许仅仅是没用而已,但不至于是负作用 (0分不是负分);
            //              结论: 即,判断它是否为负,还是应该在外围进行识别预测价值来决定,而不是在cansets中识别;
            //      > 而当前任务的解决方案就是飞到危险地带吃,多任务树反思后发现,吃没疼重要,所以反思不通过;
            
            //      > 再如:pFo为疼,cansets其中一条为:吃药不解决饥饿问题;
            //              疑问: 这里反馈似乎未涉及到吃药会苦的介入?
            //              分析: 它判断不到苦,可能药就直接吃了,吃了后再反馈又能如何?也是迟了;
            //              结论: 即,判断它是否苦,应该放到外转进行识别预测价值来决定,而在cansets中识别是不可能实现的;
            //      > 而当前任务的解决方案就是吃药,多任务树反思后发现,吃药治病比饥饿重要,所以反思通过;
            
            //  5. 第4的疑问可见,从cansets进行返回,并不可靠,建议在拼接前后部分后,重新进行识别,然后制定子任务;
            //  6. 建议子任务后,再看能不能通过按交通灯按钮,将绿灯改成红灯,让车停下来?
            //  7. 如果子任务无解 (即无法改变交通灯),则中止吃的任务 (因为比起饿更怕疼);
            //  8. 说白了,就是反思识别提前呗,提前到行为化之前...别的啥也不用改;
            
            //所以: 查下如果将反思识别前置,它能不能在飞之前有效打断?如果能,那这里就不用写了,中止;
            
            
            
            
        }
    }
}

@end
