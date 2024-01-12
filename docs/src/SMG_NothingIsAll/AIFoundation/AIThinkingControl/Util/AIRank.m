//
//  AIRank.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/12/19.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AIRank.h"

@implementation AIRank

/**
 *  MARK:--------------------概念识别综合排名 (参考2722d-方案2-todo2)--------------------
 *  @result 返回排名名次: <matchAlg.pId, 综合排名值(越小越靠前)>;
 *  @version
 *      2023.01.31: 单项权重新增牛顿冷却曲线 (参考28042-思路2-3);
 *      2023.03.06: 识别排名器当前无用,关闭它 (参考28152-方案5 & todo6);
 */
+(NSArray*) recognitionAlgRank:(NSArray*)matchAlgModels {
    if (!Switch4RecognitionRank) return matchAlgModels;//开关关闭则直接返回;
    return [self getCooledRankTwice:matchAlgModels itemScoreBlock1:^CGFloat(AIMatchAlgModel *item) {
        return [item matchValue]; //匹配度项;
    } itemScoreBlock2:^CGFloat(AIMatchAlgModel *item) {
        return [item strongValue]; //强度项;
    } itemKeyBlock:^id(AIMatchAlgModel *item) {
        return @(item.matchAlg.pointerId);
    }];
}

/**
 *  MARK:--------------------时序识别综合排名 (参考2722d-方案2-todo2 & 2722f-todo14)--------------------
 *  @result 返回排名名次: <matchFo.pId, 综合排名值(越小越靠前)>;
 *  @version
 *      2023.01.31: 单项权重新增牛顿冷却曲线 (参考28042-思路2-3);
 *      2023.03.06: 识别排名器当前无用,关闭它 (参考28152-方案5 & todo6);
 */
+(NSArray*) recognitionFoRank:(NSArray*)matchFoModels {
    if (!Switch4RecognitionRank) return matchFoModels;//开关关闭则直接返回;
    return [self getCooledRankTwice:matchFoModels itemScoreBlock1:^CGFloat(AIMatchFoModel *item) {
        return [item matchFoValue]; //匹配度项;
    } itemScoreBlock2:^CGFloat(AIMatchFoModel *item) {
        return [item strongValue]; //强度项;
    } itemKeyBlock:^id(AIMatchFoModel *item) {
        return @(item.matchFo.pointerId);
    }];
}

/**
 *  MARK:--------------------S综合排名--------------------
 *  @desc 对前中后段分别排名,然后综合排名 (参考26222-TODO2);
 *  @desc 此处综合S的三个竞争器,顺序为:后->中->前 (参考28080-决策 & 结论2);
 *  @param needBack : 是否排后段: H传true需要,R传false不需要;
 *  @param fromSlow : 是否源于慢思考: 慢思考传true中段用stable排,快思考传false中段用effect排;
 *  @version
 *      2023.02.18: V2迭代: 把三项排名改成三次排序+漏斗 (参考28080-结论2);
 *      2023.02.19: 正式启用v2,并且动态计算每次保留比例;
 *      2023.05.23: 迭代v3,改为仅根据稳定性和有效性排名 (参考29099-方案);
 *  @result 返回排名结果;
 */
//+(NSArray*) solutionFoRankingV2:(NSArray*)solutionModels needBack:(BOOL)needBack fromSlow:(BOOL)fromSlow{
//    //0. 数据准备;
//    CGFloat resultNum = 6;
//    NSInteger rankNum = needBack ? 3 : 2;//排名几次;
//    CGFloat singleRate = MIN(1, powf(resultNum / solutionModels.count, 1.0f / rankNum));//每次保留条数比例;
//
//    //1. 后段排名;
//    if (needBack) {
//        solutionModels = [AIRank solutionBackRank:solutionModels];
//        solutionModels = ARR_SUB(solutionModels, 0, solutionModels.count * singleRate);
//    }
//
//    //2. 中段排名;
//    solutionModels = [AIRank solutionMidRank:solutionModels];
//    solutionModels = ARR_SUB(solutionModels, 0, solutionModels.count * singleRate);
//
//
//    //3. 前段排名;
//    solutionModels = [AIRank solutionFrontRank:solutionModels];
//    solutionModels = ARR_SUB(solutionModels, 0, solutionModels.count * singleRate);
//
//    //4. 返回;
//    return solutionModels;
//}
//
///**
// *  MARK:--------------------求解S前段排名 (参考28083-方案2 & 28084-5)--------------------
// */
//+(NSArray*) solutionFrontRank:(NSArray*)solutionModels {
//    return [self getCooledRankTwice:solutionModels itemScoreBlock1:^CGFloat(AICansetModel *item) {
//        return item.frontMatchValue; //前段匹配度项;
//    } itemScoreBlock2:^CGFloat(AICansetModel *item) {
//        return item.frontStrongValue; //前段强度项;
//    } itemKeyBlock:^id(AICansetModel *item) {
//        return @(item.cansetFo.pointerId);
//    }];
//}
//
///**
// *  MARK:--------------------求解S后段排名 (参考28092-方案 & todo3)--------------------
// */
//+(NSArray*) solutionBackRank:(NSArray*)solutionModels {
//    return [self getCooledRankTwice:solutionModels itemScoreBlock1:^CGFloat(AICansetModel *item) {
//        return item.backMatchValue; //匹配度项;
//    } itemScoreBlock2:^CGFloat(AICansetModel *item) {
//        return item.backStrongValue; //强度项;
//    } itemKeyBlock:^id(AICansetModel *item) {
//        return @(item.cansetFo.pointerId);
//    }];
//}
//
///**
// *  MARK:--------------------求解S中段排名 (参考28092-方案 & todo3)--------------------
// */
//+(NSArray*) solutionMidRank:(NSArray*)solutionModels {
//    return [self getCooledRankTwice:solutionModels itemScoreBlock1:^CGFloat(AICansetModel *item) {
//        return item.midStableScore; //中断稳定性项;
//    } itemScoreBlock2:^CGFloat(AICansetModel *item) {
//        return item.midEffectScore; //中段有效性项;
//    } itemKeyBlock:^id(AICansetModel *item) {
//        return @(item.cansetFo.pointerId);
//    }];
//}

/**
 *  MARK:--------------------求解S排名器 (参考29099-方案)--------------------
 *  @version
 *      2023.05.23: BUG_用sceneId_cansetId做key,会有重复的,导致算漏的BUG,改用内存地址来做唯一key;
 *      2023.05.24: BUG_修复此处将sceneTargetIndex用错成cansetTargetIndex的问题 (会导致取到eff几乎全是错的0);
 *      2023.05.26: BUG_修复SP总是取到0的问题,改为eff为主排序,sp仅取下一帧稳定性做二级排序,H值三级排序 (参考2909a-方案2);
 *      2023.12.26: 优化sort性能,把getEffectStrong()提出来提前取好 (参考31025-代码段-问题1) //共三处优化,此乃其一;
 */
+(NSArray*) solutionFoRankingV3:(NSArray*)solutionModels {
    //0. 将effStrong提前取出来,存到mapModel中;
    NSArray *mapArr = [SMGUtils convertArr:solutionModels convertBlock:^id(AICansetModel *item) {
        AIFoNodeBase *sceneFo = [SMGUtils searchNode:item.sceneFo];
        AIEffectStrong *strong = [TOUtils getEffectStrong:sceneFo effectIndex:item.sceneTargetIndex solutionFo:item.cansetFo];
        return [MapModel newWithV1:item v2:strong];
    }];
    
    //1. 根据cutIndex到target之间的稳定性和有效性来排名 (参考29099-todo1 & todo2);
    NSArray *sort = [SMGUtils sortBig2Small:mapArr compareBlock1:^double(MapModel *item) {
        return [TOUtils getEffectScore:item.v2];//后段有效性 (参考2909a-todo1);
    } compareBlock2:^double(MapModel *item) {
        AICansetModel *cansetModel = item.v1;
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetModel.cansetFo];
        return [TOUtils getStableScore:cansetFo startSPIndex:cansetModel.cutIndex + 1 endSPIndex:cansetModel.cutIndex + 1];//下帧稳定性
    } compareBlock3:^double(MapModel *item) {
        AIEffectStrong *strong = item.v2;
        return strong.hStrong;//H值 (参考2909a-todo3);
    }];
    
    //2. 将mapModel转回AICansetModel数组;
    sort = [SMGUtils convertArr:sort convertBlock:^id(MapModel *obj) {
        return obj.v1;
    }];
    
    //2. debug日志
    for (AICansetModel *obj in ARR_SUB(sort, 0, 5)) {
        AIFoNodeBase *sceneFo = [SMGUtils searchNode:obj.sceneFo];
        AIEffectStrong *effStrong = [TOUtils getEffectStrong:sceneFo effectIndex:sceneFo.count solutionFo:obj.cansetFo];
        CGFloat effScore = [TOUtils getEffectScore:effStrong];
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:obj.cansetFo];
        CGFloat spScore = [TOUtils getStableScore:cansetFo startSPIndex:obj.cutIndex + 1 endSPIndex:obj.cutIndex + 1];
        if (Log4AIRank) NSLog(@"%ld. %@<F%ld %@> %@:(分:%.2f) %@:(分:%.2f)",[sort indexOfObject:obj],SceneType2Str(obj.baseSceneModel.type),obj.sceneFo.pointerId,Fo2FStr(cansetFo),
                              CLEANSTR(cansetFo.spDic),spScore,effStrong.description,effScore);
    }
    return sort;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------单项models冷却后竞争值--------------------
 *  @desc 单项一般包含多条,如匹配度项竞争,比如: 三班的语文考试;
 *  @version
 *      2023.05.23: 修复归1化后小数写成了int型,导致只有0和1的BUG;
 *  @todo : 其实这里的排名再冷却,有点麻烦,可以直接改成排名的名次相加来计算,但目前也没啥问题,所以先不动了 (如果哪天发现现做法有问题时再这么改);
 */
+(NSDictionary*) getCooledValueDic:(NSArray*)models itemScoreBlock:(CGFloat(^)(id item))itemScoreBlock itemKeyBlock:(id(^)(id item))itemKeyBlock {
    //1. 数据准备;
    models = ARRTOOK(models);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

    //2. 分别按相似度和强度排序;
    NSArray *rank = [SMGUtils sortBig2Small:models compareBlock:^double(id obj) {
        return itemScoreBlock(obj);
    }];

    //3. 求出综合排名;
    for (id item in rank) {
        //4. 取单科排名下标;
        NSInteger index4Rank = [rank indexOfObject:item];

        //5. 各自归1化;
        CGFloat normalized4Rank = (float)index4Rank / rank.count;

        //5. 单条model根据28原则冷却后的值 (单条仅一条,比如: 张三的语文考试) (参考28042-思路2-3);
        CGFloat cool4Rank = [MathUtils getCooledValue_28:normalized4Rank];

        //6. 计算综合排名;
        id key = itemKeyBlock(item);
        [result setObject:@(cool4Rank) forKey:key];
    }
    if (Log4AIRankDebugMode) NSLog(@"AIRank-单项排名: %@",CLEANSTR([SMGUtils convertArr:rank convertBlock:^id(id obj) {return itemKeyBlock(obj);}]));
    return result;
}

/**
 *  MARK:--------------------两项models冷却后竞争值--------------------
 *  @desc 包含两项, 比如: 三班的语数竞赛;
 *  @version
 *      2023.05.24: BUG_热度应该是越高越好,排反了,改为从大到小排;
 */
+(NSArray*) getCooledRankTwice:(NSArray*)models itemScoreBlock1:(CGFloat(^)(id item))itemScoreBlock1 itemScoreBlock2:(CGFloat(^)(id item))itemScoreBlock2 itemKeyBlock:(id(^)(id item))itemKeyBlock{
    //1. 两个冷却后字典计算;
    NSDictionary *cooledDic1 = [self getCooledValueDic:models itemScoreBlock:itemScoreBlock1 itemKeyBlock:itemKeyBlock];
    NSDictionary *cooledDic2 = [self getCooledValueDic:models itemScoreBlock:itemScoreBlock2 itemKeyBlock:itemKeyBlock];

    //2. 求出综合竞争值并排序 (参考25083-2&公式2 & 25084-1);
    NSArray *result = [SMGUtils sortBig2Small:models compareBlock:^double(id obj) {
        id key = itemKeyBlock(obj);
        float coolScore1 = NUMTOOK([cooledDic1 objectForKey:key]).floatValue;
        float coolScore2 = NUMTOOK([cooledDic2 objectForKey:key]).floatValue;
        return coolScore1 * coolScore2; //返回排序后的sortArr时;
    }];

    //3. debug日志
    for (AICansetModel *obj in result) {
        id key = itemKeyBlock(obj);
        AIFoNodeBase *sceneFo = [SMGUtils searchNode:obj.sceneFo];
        AIEffectStrong *effStrong = [TOUtils getEffectStrong:sceneFo effectIndex:sceneFo.count solutionFo:obj.cansetFo];
        AIFoNodeBase *cansetFo = [SMGUtils searchNode:obj.cansetFo];
        float coolScore1 = NUMTOOK([cooledDic1 objectForKey:key]).floatValue,coolScore2 = NUMTOOK([cooledDic2 objectForKey:key]).floatValue;
        CGFloat spScore = itemScoreBlock1(obj), effScore = itemScoreBlock2(obj);
        if (ISOK(obj, AICansetModel.class)) {
            if (Log4AIRank) NSLog(@"%ld. %@:(分:%.2f) %@:(分:%.2f) %@<F%ld %@>",[result indexOfObject:obj],
                                  CLEANSTR(cansetFo.spDic),spScore,effStrong.description,effScore,
                                  SceneType2Str(obj.baseSceneModel.type),obj.sceneFo.pointerId,Fo2FStr(cansetFo));
            if (Log4AIRankDebugMode) NSLog(@"\t> %@ sp排名:%.5f eff排名:%.5f => 综合排名:%.5f",key,coolScore1,coolScore2,coolScore1 * coolScore2);
        }
    }

    return result;
}

@end
