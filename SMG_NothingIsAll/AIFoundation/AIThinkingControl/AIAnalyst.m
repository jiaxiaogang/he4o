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
//MARK:                     < Alg匹配度 (由TO调用) >
//MARK: @desc 目前写在AINetUtils.getNearData()中,回头看整理到此处;
//MARK:===============================================================

//MARK:===============================================================
//MARK:                     < Value相近度 (由TI调用) >
//MARK:===============================================================

/**
 *  MARK:--------------------比对稀疏码相近度--------------------
 *  @result 返回0到1 (0:稀疏码完全不同, 1稀疏码完全相同) (参考26127-TODO6);
 *  @version
 *      2023.03.13: 支持循环码时的相近度计算 (参考28174-todo2);
 *      2023.03.16: 修复首尾差值算错的BUG (因为测得360左右度和180左右度相近度是0.9以上);
 */
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p{
    //1. 取稀疏码值;
    double cansetData = [NUMTOOK([AINetIndex getData:cansetV_p]) doubleValue];
    double protoData = [NUMTOOK([AINetIndex getData:protoV_p]) doubleValue];
    
    //2. 计算相近度返回;
    return [self compareCansetValue:cansetData protoV:protoData at:cansetV_p.algsType ds:cansetV_p.dataSource isOut:protoV_p.isOut];
}

+(CGFloat) compareCansetValue:(double)cansetV protoV:(double)protoV at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut{
    //2. 循环时: 计算出nearV相近度 (参考28174-todo2);
    double max = [CortexAlgorithmsUtil maxOfLoopValue:at ds:ds];
    if (max > 0) {
        double halfMax = max / 2;
        double protoDelta = fabs(cansetV - protoV);
        protoDelta = protoDelta > halfMax ? max - protoDelta : protoDelta;
        CGFloat result = 1 - protoDelta / halfMax;
        return result;
    }
    
    //3. 线性时: 计算出nearV相近度 (参考25082-公式1);
    double delta = fabs(cansetV - protoV);
    double span = [AINetIndex getIndexSpan:at ds:ds isOut:isOut];
    double nearV = (span == 0) ? 1 : (1 - delta / span);
    return nearV;
}

@end
