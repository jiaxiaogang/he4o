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
+(BOOL) refrection:(AISolutionModel*)checkCanset cansets:(NSArray*)protoCansets demand:(DemandModel*)demand{
    OFTitleLog(@"TCRefrection反思", @"\n%@",Pit2FStr(checkCanset.cansetFo));
    //1. 反思识别
    NSDictionary *recogDic = [TCRefrection recognition4SRefrection:checkCanset cansets:protoCansets];
    
    //2. 反思评价
    BOOL score = [TCRefrection score4SRefrection:recogDic cansets:protoCansets demand:demand];
    return score;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------S反思识别--------------------
 *  @desc   1. 功能: 从cansets中检查与item匹配度高的部分,并作为识别结果返回;
 *          2. 向性: 下;
 *          3. 范围: 无论是H还是R,都向具象根据匹配度取数条,做综合反思 (参考27055-方案1-步骤3);
 *  @param checkCanset  : 当前canset检查项;
 *  @param protoCansets : item所在的cansets (原始proto候选集);
 *  @version
 *      2022.07.16: 写S评分pk (参考27048-TODO3 & 27049-TODO4);
 *  @result frontNearDic : 识别结果,按照前段匹配度排序返回为字典格式 <K:结果pId, V:匹配度>;
 */
+(NSDictionary*) recognition4SRefrection:(AISolutionModel*)checkCanset cansets:(NSArray*)protoCansets{
    //1. 收集前段匹配度字典 <K:checkCansetFoPId, V:frontSumNear>
    NSMutableDictionary *frontNearDic = [[NSMutableDictionary alloc] init];
    
    //2. 与cansets兄弟们逐一进行比对,得出前段匹配度;
    for (AISolutionModel *otherCanset in protoCansets) {
        //3. 不与自身比较;
        if ([otherCanset.cansetFo isEqual:checkCanset.cansetFo]) continue;
        
        //4. 对比二者;
        CGFloat frontNear = [AIAnalyst compareFromSolutionCanset:checkCanset otherCanset:otherCanset];
        [frontNearDic setObject:@(frontNear) forKey:@(otherCanset.cansetFo.pointerId)];
    }
    return frontNearDic;
}

/**
 *  MARK:--------------------S反思评价--------------------
 *  @desc 从具象上求解 (本方法中,从同具象层的cansets中,找出前段相似的,共同算出综合评分);
 *  @param recogDic : 反思识别的结果字典 (参考recognition4SRefrection()的@result);
 *  @param protoCansets : 所在的源候选集 (原始proto候选集);
 *  @param demand   : 所在的源demand;
 *  @version
 *      2022.07.16: 写S评分pk (参考27048-TODO3 & 27049-TODO4);
 *      2022.09.26: cansets由可用方案候选集,改成原始候选集 (参考27123-问题3-方案);
 *      2022.09.26: 将limit保留最少3条 (因为发生了明明有1条,反而只限高没限低,导致被截剩0条了的问题);
 */
+(BOOL) score4SRefrection:(NSDictionary*)recogDic cansets:(NSArray*)protoCansets demand:(DemandModel*)demand{
    //1. 根据前段匹配度排序;
    NSArray *sortCansets = [SMGUtils sortBig2Small:protoCansets compareBlock:^double(AISolutionModel *obj) {
        return NUMTOOK([recogDic objectForKey:@(obj.cansetFo.pointerId)]).floatValue;
    }];
    
    //2. cansets有80条,那么到底前多少条,参与到反思评价中来? => 截取三分之一,但最多不超过5条,最小不少于3条;
    NSInteger limit = MAX(3, MIN(5, sortCansets.count * 0.3f));
    sortCansets = ARR_SUB(sortCansets, 0, limit);
    
    //3. 取到fo,算出后段的mv评分,并累计到sum中;
    CGFloat sumMvScore = 0.0f,sumLazyScore = 0.0f;
    int mvScoreNum = 0,lazyScoreNum = 0;
    
    for (AISolutionModel *item in sortCansets) {
        AIFoNodeBase *recogFo = [SMGUtils searchNode:item.cansetFo];
        
        //4. 算出后半段稳定性评分;
        CGFloat stabScore = [TOUtils getStableScore:recogFo startSPIndex:item.cutIndex + 1 endSPIndex:recogFo.count];
        
        //5. 算出后半段稳定性 x mv评分 (正mv返回正分 | 负mv返回负分 | 无mv返回0分);
        CGFloat mvScore = [AIScore score4MV:recogFo.cmvNode_p ratio:stabScore];
        
        //6. 累计评分;
        sumMvScore += mvScore;
        mvScoreNum ++;
        
        //7. 算出后段的"懒"评分;
        CGFloat lazyScore = 0;
        for (NSInteger i = item.cutIndex + 1; i < recogFo.count; i++) {
            //8. 遍历后半段中的"isOut=true"的行为,各指定"懒"评分;
            AIKVPointer *alg_p = ARR_INDEX(recogFo.content_ps, i);
            if (alg_p && alg_p.isOut) {
                lazyScore -= 0.5f;
            }
        }
        sumLazyScore += lazyScore;
        lazyScoreNum ++;
        
        //8. 日志
        CGFloat frontNear = NUMTOOK([recogDic objectForKey:@(item.cansetFo.pointerId)]).floatValue;
        NSLog(@"反思识别结果:%@\n\tCUT:%ld 前匹配度%.2f 后稳定性:%.2f 价值分:%.1f 懒分:%.1f",Pit2FStr(item.cansetFo),(long)item.cutIndex,frontNear,stabScore,mvScore,lazyScore);
    }
    
    //9. 根据sum和num累计,算出平均"方案评分"和"懒评分";
    CGFloat averageMvScore = mvScoreNum > 0 ? sumMvScore / mvScoreNum : 0;
    CGFloat averageLazyScore = lazyScoreNum > 0 ? sumLazyScore / lazyScoreNum : 0;
    
    //10. 计算任务评分: 取baseRDemand评分 (参考27057);
    NSArray *rootDemands = [TOUtils getBaseDemands_AllDeep:demand];
    rootDemands = [SMGUtils filterArr:rootDemands checkValid:^BOOL(id item) {
        return ISOK(item, ReasonDemandModel.class);
    }];
    ReasonDemandModel *baseRDemand = ARR_INDEX_REVERSE(rootDemands, 0);
    CGFloat averageDemandScore = [AIScore score4Demand:baseRDemand];
    
    //11. S评分PK: pk通过 = 任务评分 - 方案评分 - 懒评分 > 0;
    //12. 三个评分都是负的,所以公式为以下 (result = 收益(负任务分) + mv的负分 + lazy的负分 > 0);
    BOOL result = -averageDemandScore + averageMvScore + averageLazyScore > 0;
    NSLog(@"反思评价结果:%@通过 任务分%.1f 价值分:%.2f 懒分:%.1f",result?@"已":@"未",averageDemandScore,averageMvScore,averageLazyScore);
    return result;
}

@end
