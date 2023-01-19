//
//  AIAnalyst.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/6/10.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AIAnalyst.h"

@implementation AIAnalyst

//MARK:===============================================================
//MARK:                     < Fo相似度 (由TO调用) >
//MARK:===============================================================

/**
 *  MARK:--------------------时序比对--------------------
 *  @desc 初步比对候选集是否适用于protoFo (参考26128-第1步);
 *  @param ptAleardayCount      : ptFo已发生个数:
 *                                  1. 根R=cutIndex+1
 *                                  2. 子R=父actionIndex对应indexDic条数;
 *                                  3. H.actionIndex前已发生;
 *  @param isH                  : 是否需要后段匹配 (R不需要传false,H需要传true);
 *  @version
 *      2022.05.30: 匹配度公式改成: 匹配度总和/proto长度 (参考26128-1-4);
 *      2022.05.30: R和H模式复用封装 (参考26161);
 *      2022.06.11: 修复反思子任务没有protoFo用于analyst的BUG (参考26224-方案图);
 *      2022.06.11: 改用pFo参与analyst算法比对 & 并改取pFo已发生个数计算方式 (参考26232-TODO3&5&6);
 *      2022.06.12: 每帧analyst都映射转换成maskFo的帧元素比对 (参考26232-TODO4);
 *      2022.09.15: 导致任务的maskFo不从demand取,而是从pFo取 (因为它在推进时会变化) (参考27097-todo3);
 *      2022.11.03: compareHCansetFo比对中复用alg相似度 (参考27175-3);
 *      2022.11.03: 复用alg相似度 (参考27175-2&3);
 *      2022.11.20: 改为match与canset比对,复用indexDic和alg相似度 (参考27202-3&4&5);
 *      2022.11.20: 持久化复用: 支持indexDic复用和概念matchValue复用 (参考20202-3&4);
 *      2022.12.03: 修复复用matchValue有时为0的问题 (参考27223);
 *      2022.12.03: 当canset前段有遗漏时,该方案无效 (参考27224);
 *      2023.01.08: 将R和H的时序比对,整理删除仅留下这个通用时序比对方法;
 *  @result 返回cansetFo前段匹配度 & 以及已匹配的cutIndex截点;
 */
+(AISolutionModel*) compareCansetFo:(AIKVPointer*)cansetFo_p basePFoOrTargetFoModel:(id)basePFoOrTargetFoModel ptAleardayCount:(NSInteger)ptAleardayCount isH:(BOOL)isH {
    //1. 数据准备 & 复用indexDic;
    AIKVPointer *matchFo_p = [TOUtils convertBaseFoFromBasePFoOrTargetFoModel:basePFoOrTargetFoModel];
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
    NSDictionary *indexDic = [cansetFo getAbsIndexDic:matchFo_p];
    [AITest test102:cansetFo];
    
    //2. 计算出canset的cutIndex (canset的cutIndex,也已在proto中发生) (参考26128-1-1);
    NSInteger matchCutIndex = ptAleardayCount - 1;
    NSInteger cansetCutIndex = NUMTOOK([indexDic objectForKey:@(matchCutIndex)]).integerValue;
    
    //3. 判断canset前段是否有遗漏 (参考27224);
    if (cansetCutIndex < matchCutIndex) return nil;
    
    //4. 计算前段匹配度 (参考28035-todo3);
    CGFloat frontMatchValue = 1;
    for (NSInteger i = 0; i < ptAleardayCount; i++) {
        frontMatchValue *= [self compareCansetAlg:i cansetFo:cansetFo_p matchFo:matchFo_p];
    }
    
    //5. 前段不匹配时,直接返回nil (参考26128-1-3);
    if (frontMatchValue == 0) return nil;
    
    //6. 后段: 找canset后段目标 和 后段匹配度 (H需要后段匹配, R不需要);
    if (isH) {
        //7. 后段匹配度 (后段不匹配时,直接返nil);
        CGFloat backMatchValue =  [self compareCansetAlg:ptAleardayCount cansetFo:cansetFo_p matchFo:matchFo_p];
        if (backMatchValue == 0) return nil;
        
        //8. canset目标下标
        NSInteger cansetTargetIndex = NUMTOOK([indexDic objectForKey:@(ptAleardayCount)]).integerValue;
        
        //9. 后段成功;
        return [AISolutionModel newWithCansetFo:cansetFo_p frontMatchValue:frontMatchValue backMatchValue:backMatchValue cutIndex:cansetCutIndex targetIndex:cansetTargetIndex basePFoOrTargetFoModel:basePFoOrTargetFoModel];
        
    }else{
        //11. 后段: R不判断后段;
        return [AISolutionModel newWithCansetFo:cansetFo_p frontMatchValue:frontMatchValue backMatchValue:1 cutIndex:cansetCutIndex targetIndex:cansetFo.count basePFoOrTargetFoModel:basePFoOrTargetFoModel];
    }
}

/**
 *  MARK:--------------------对比canset和match (复用indexDic和相似度)--------------------
 *  @desc 对比canset的元素和match的元素;
 *          1. 复用indexDic: canset和match的映射关系本来就存在indexDic中;
 *          2. matchIndex: 根据indexDic取到matchIndex,当matchIndex<ptAleardayCount时,即为前段,=时为后段;
 *          3. 复用matchValue: 然后将cansetIndex和matchIndex对应二者的持久化概念相似度复用返回即可;
 *  _param checkMatchIndexBlock : 根据matchIndex检查是否要继续 (比如前段时:matchIndex在后段就不继续,或者在后段时matchIndex在前段也不继续);
 *  @version
 *      2022.11.20: 初版: match与canset比对,复用indexDic和alg相似度 (参考27202-3&4&5);
 */
+(CGFloat) compareCansetAlg:(NSInteger)matchIndex cansetFo:(AIKVPointer*)cansetFo_p matchFo:(AIKVPointer*)matchFo_p {
    //1. 数据准备;
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
    AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];

    //2. 复用indexDic;
    NSDictionary *indexDic = [cansetFo getAbsIndexDic:matchFo.pointer];
    if (![indexDic objectForKey:@(matchIndex)]) [AITest test22];
    
    //3. 根据indexDic取出cansetIndex;
    NSInteger cansetIndex = NUMTOOK([indexDic objectForKey:@(matchIndex)]).integerValue;

    //5. 前后段匹配时: 返回复用matchValue相似度;
    AIKVPointer *cansetA_p = ARR_INDEX(cansetFo.content_ps, cansetIndex);
    AIKVPointer *matchA_p = ARR_INDEX(matchFo.content_ps, matchIndex);
    AIAlgNodeBase *cansetA = [SMGUtils searchNode:cansetA_p];
    CGFloat matchValue = [cansetA getAbsMatchValue:matchA_p];
    [AITest test16:matchValue];
    return matchValue;
}

//MARK:===============================================================
//MARK:                     < Value相近度 (由TI调用) >
//MARK:===============================================================

/**
 *  MARK:--------------------比对稀疏码相近度--------------------
 *  @result 返回0到1 (0:稀疏码完全不同, 1稀疏码完全相同) (参考26127-TODO6);
 */
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p{
    //1. 取稀疏码值;
    double cansetData = [NUMTOOK([AINetIndex getData:cansetV_p]) doubleValue];
    double protoData = [NUMTOOK([AINetIndex getData:protoV_p]) doubleValue];
    
    //2. 计算出nearV (参考25082-公式1);
    double delta = fabs(cansetData - protoData);
    double span = [AINetIndex getIndexSpan:protoV_p.algsType ds:protoV_p.dataSource isOut:protoV_p.isOut];
    double nearV = (span == 0) ? 1 : (1 - delta / span);
    return nearV;
}

@end
