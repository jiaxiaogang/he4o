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
+(NSDictionary*) recognitonAlgRank:(NSArray*)matchAlgModels {
    //1. 数据准备;
    matchAlgModels = ARRTOOK(matchAlgModels);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 分别按相似度和强度排序;
    NSArray *rank4MatchValue = [SMGUtils sortBig2Small:matchAlgModels compareBlock:^double(AIMatchAlgModel *obj) {
        return [obj matchValue];
    }];
    NSArray *rank4StrongValue = [SMGUtils sortBig2Small:matchAlgModels compareBlock:^double(AIMatchAlgModel *obj) {
        return [obj strongValue];
    }];
    
    //3. 求出综合排名;
    for (AIMatchAlgModel *item in matchAlgModels) {
        //4. 取两科排名下标;
        NSInteger index4MatchValue = [rank4MatchValue indexOfObject:item];
        NSInteger index4StrongValue = [rank4StrongValue indexOfObject:item];
        
        //5. 各自归1化;
        CGFloat normalized4MatchValue = index4MatchValue / rank4MatchValue.count;
        CGFloat normalized4StrongValue = index4StrongValue / rank4StrongValue.count;
        
        //5. 各自冷却后的值;
        CGFloat cool4MatchValue = [self getCooledValue:1 pastTime:normalized4MatchValue];
        CGFloat cool4StrongValue = [self getCooledValue:1 pastTime:normalized4StrongValue];
        
        //6. 计算综合排名;
        [result setObject:@(cool4MatchValue * cool4StrongValue) forKey:@(item.matchAlg.pointerId)];
    }
    return result;
}

/**
 *  MARK:--------------------时序识别综合排名 (参考2722d-方案2-todo2 & 2722f-todo14)--------------------
 *  @result 返回排名名次: <matchFo.pId, 综合排名值(越小越靠前)>;
 *  @version
 *      2023.01.31: 单项权重新增牛顿冷却曲线 (参考28042-思路2-3);
 */
+(NSDictionary*) recognitonFoRank:(NSArray*)matchFoModels {
    //1. 数据准备;
    matchFoModels = ARRTOOK(matchFoModels);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 分别按相似度和强度排序;
    NSArray *rank4MatchValue = [SMGUtils sortBig2Small:matchFoModels compareBlock:^double(AIMatchFoModel *obj) {
        return [obj matchFoValue];
    }];
    NSArray *rank4StrongValue = [SMGUtils sortBig2Small:matchFoModels compareBlock:^double(AIMatchFoModel *obj) {
        return [obj strongValue];
    }];
    
    //3. 求出综合排名;
    for (AIMatchFoModel *item in matchFoModels) {
        //4. 取两科排名下标;
        NSInteger index4MatchValue = [rank4MatchValue indexOfObject:item];
        NSInteger index4StrongValue = [rank4StrongValue indexOfObject:item];
        
        //5. 各自归1化;
        CGFloat normalized4MatchValue = index4MatchValue / rank4MatchValue.count;
        CGFloat normalized4StrongValue = index4StrongValue / rank4StrongValue.count;
        
        //5. 各自冷却后的值;
        CGFloat cool4MatchValue = [self getCooledValue:1 pastTime:normalized4MatchValue];
        CGFloat cool4StrongValue = [self getCooledValue:1 pastTime:normalized4StrongValue];
        
        //6. 计算综合排名;
        [result setObject:@(cool4MatchValue * cool4StrongValue) forKey:@(item.matchFo.pointerId)];
    }
    return result;
}

/**
 *  MARK:--------------------S综合排名--------------------
 *  @desc 对前中后段分别排名,然后综合排名 (参考26222-TODO2);
 *  @param needBack : 是否排后段: H传true需要,R传false不需要;
 *  @param fromSlow : 是否源于慢思考: 慢思考传true中段用stable排,快思考传false中段用effect排;
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

/**
 *  MARK:--------------------求解S前段排名 (参考28083-方案2 & 28084-5)--------------------
 */
+(NSDictionary*) solutionFrontRank:(NSArray*)solutionModels protoFo:(AIFoNodeBase*)protoFo {
    //1. 数据准备;
    solutionModels = ARRTOOK(solutionModels);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    //2. 分别按相似度和强度排序;
    NSArray *rank4MatchValue = [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return obj.frontMatchValue;
    }];
    NSArray *rank4StrongValue = [SMGUtils sortBig2Small:solutionModels compareBlock:^double(AISolutionModel *obj) {
        return obj.frontStrongValue;
    }];
    
    //3. 求出综合排名;
    for (AIMatchAlgModel *item in solutionModels) {
        //4. 取两科排名下标;
        NSInteger index4MatchValue = [rank4MatchValue indexOfObject:item];
        NSInteger index4StrongValue = [rank4StrongValue indexOfObject:item];
        
        //5. 各自归1化;
        CGFloat normalized4MatchValue = index4MatchValue / rank4MatchValue.count;
        CGFloat normalized4StrongValue = index4StrongValue / rank4StrongValue.count;
        
        //5. 各自冷却后的值;
        CGFloat cool4MatchValue = [self getCooledValue:1 pastTime:normalized4MatchValue];
        CGFloat cool4StrongValue = [self getCooledValue:1 pastTime:normalized4StrongValue];
        
        //6. 计算综合排名;
        [result setObject:@(cool4MatchValue * cool4StrongValue) forKey:@(item.matchAlg.pointerId)];
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------获取冷却后值--------------------
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

@end
