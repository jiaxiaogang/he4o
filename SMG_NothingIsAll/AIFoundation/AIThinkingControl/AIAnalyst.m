//
//  AIAnalyst.m
//  SMG_NothingIsAll
//
//  Created by jia on 2022/6/10.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import "AIAnalyst.h"

@implementation AIAnalyst

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
