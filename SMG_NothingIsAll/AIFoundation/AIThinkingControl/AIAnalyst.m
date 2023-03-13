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
 */
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p{
    //1. 取稀疏码值;
    double cansetData = [NUMTOOK([AINetIndex getData:cansetV_p]) doubleValue];
    double protoData = [NUMTOOK([AINetIndex getData:protoV_p]) doubleValue];
    
    //2. 循环时: 计算出nearV相近度 (参考28174-todo2);
    double max = [CortexAlgorithmsUtil maxOfLoopValue:cansetV_p.algsType ds:cansetV_p.dataSource];
    if (max > 0) {
        double halfMax = max / 2;
        double protoDelta = fabs(cansetData - protoData);
        protoDelta = protoDelta > halfMax ? protoDelta - halfMax : protoDelta;
        return 1 - protoDelta / halfMax;
    }
    
    //3. 线性时: 计算出nearV相近度 (参考25082-公式1);
    double delta = fabs(cansetData - protoData);
    double span = [AINetIndex getIndexSpan:protoV_p.algsType ds:protoV_p.dataSource isOut:protoV_p.isOut];
    double nearV = (span == 0) ? 1 : (1 - delta / span);
    return nearV;
}

@end
