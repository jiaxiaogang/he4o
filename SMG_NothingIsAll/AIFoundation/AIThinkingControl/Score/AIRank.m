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
 */
+(NSArray*) recognitonAlgRank:(NSArray*)matchAlgModels {
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
 */
+(NSArray*) recognitonFoRank:(NSArray*)matchFoModels {
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
 *  @result 返回排名结果;
 */
+(NSArray*) solutionFoRanking:(NSArray*)solutionModels needBack:(BOOL)needBack fromSlow:(BOOL)fromSlow{
    //1. 三段分开排;
    NSArray *backSorts = needBack ? [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return obj.backMatchValue;
    }] : nil;
    NSArray *midSorts = [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return fromSlow ? obj.stableScore : obj.effectScore;
    }];
    NSArray *frontSorts = [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return obj.frontMatchValue;
    }];
    
    //2. 综合排名
    NSArray *ranking = [SMGUtils sortSmall2Big:solutionModels compareBlock:^double(AISolutionModel *obj) {
        NSInteger backIndex = needBack ? [backSorts indexOfObject:obj] + 1 : 1;
        NSInteger midIndex = [midSorts indexOfObject:obj] + 1;
        NSInteger frontIndex = [frontSorts indexOfObject:obj] + 1;
        return backIndex * midIndex * frontIndex;
    }];
    
    //3. 返回;
    return ranking;
}
+(NSArray*) solutionFoRankingV2:(NSArray*)solutionModels needBack:(BOOL)needBack fromSlow:(BOOL)fromSlow{
    //1. 后段排名;
    //TODOTOMORROW20230218: 写中段竞争器;
    
    //2. 中段排名;
    
    
    //3. 前段排名;
    solutionModels = [AIRank solutionFrontRank:solutionModels];
    NSInteger limit = MAX(10, solutionModels.count * 0.2f);
    solutionModels = ARR_SUB(solutionModels, 0, limit);
    
    //4. 返回;
    return solutionModels;
}

/**
 *  MARK:--------------------求解S前段排名 (参考28083-方案2 & 28084-5)--------------------
 */
+(NSArray*) solutionFrontRank:(NSArray*)solutionModels {
    return [self getCooledRankTwice:solutionModels itemScoreBlock1:^CGFloat(AISolutionModel *item) {
        return item.frontMatchValue; //前段匹配度项;
    } itemScoreBlock2:^CGFloat(AISolutionModel *item) {
        return item.frontStrongValue; //前段强度项;
    } itemKeyBlock:^id(AISolutionModel *item) {
        return @(item.cansetFo.pointerId);
    }];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------单条model冷却后竞争值--------------------
 *  @desc 单条仅一条,比如: 张三的语文考试;
 *  @desc 使用: 单项权重新增NewtonCoolDownCurve (参考28042-思路2-3);
 *  @param totalCoolTime : 冷却至微不可见的总需时长
 *  @param pastTime : 当前项已冷却了多久;
 *  @result 冷却后的温度值;
 */
+(CGFloat) getCooledValue:(CGFloat)totalCoolTime pastTime:(CGFloat)pastTime{
    //1. 冷却完全后的值 (现此值符合28原则);
    CGFloat finishValue = 0.000322f;
    
    //2. 冷却系数
    CGFloat coefficient = -logf(finishValue) / totalCoolTime;
    
    //3. 计算出冷却后的值;
    CGFloat cooledValue = expf(-coefficient * pastTime);
    return cooledValue;
}

/**
 *  MARK:--------------------单项models冷却后竞争值--------------------
 *  @desc 单项一般包含多条,如匹配度项竞争,比如: 三班的语文考试;
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
    for (id item in models) {
        //4. 取单科排名下标;
        NSInteger index4Rank = [rank indexOfObject:item];
        
        //5. 各自归1化;
        CGFloat normalized4Rank = index4Rank / rank.count;
        
        //5. 各自冷却后的值;
        CGFloat cool4Rank = [self getCooledValue:1 pastTime:normalized4Rank];
        
        //6. 计算综合排名;
        id key = itemKeyBlock(item);
        [result setObject:@(cool4Rank) forKey:key];
    }
    return result;
}

/**
 *  MARK:--------------------两项models冷却后竞争值--------------------
 *  @desc 包含两项, 比如: 三班的语数竞赛;
 */
+(NSArray*) getCooledRankTwice:(NSArray*)models itemScoreBlock1:(CGFloat(^)(id item))itemScoreBlock1 itemScoreBlock2:(CGFloat(^)(id item))itemScoreBlock2 itemKeyBlock:(id(^)(id item))itemKeyBlock{
    //1. 两个冷却后字典计算;
    NSDictionary *cooledDic1 = [self getCooledValueDic:models itemScoreBlock:itemScoreBlock1 itemKeyBlock:itemKeyBlock];
    NSDictionary *cooledDic2 = [self getCooledValueDic:models itemScoreBlock:itemScoreBlock2 itemKeyBlock:itemKeyBlock];
    
    //2. 求出综合竞争值并排序 (参考25083-2&公式2 & 25084-1);
    NSArray *result = [SMGUtils sortSmall2Big:models compareBlock:^double(id obj) {
        id key = itemKeyBlock(obj);
        float coolScore1 = NUMTOOK([cooledDic1 objectForKey:key]).floatValue;
        float coolScore2 = NUMTOOK([cooledDic2 objectForKey:key]).floatValue;
        //[result setObject:@(coolScore1 * coolScore2) forKey:key]; // 返回排序前的scoreDic时;
        return coolScore1 * coolScore2; //返回排序后的sortArr时;
    }];
    return result;
}

@end
