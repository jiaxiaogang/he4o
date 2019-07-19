//
//  AINetAbsCMVUtil.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/27.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsCMVUtil.h"
#import "AIKVPointer.h"
#import "AINetIndex.h"

@implementation AINetAbsCMVUtil


//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------取aNode和bNode的抽象urgentTo值--------------------
 */
+(NSInteger) getAbsUrgentTo:(NSArray*)mvNodes {
    return [self getAbsValue:mvNodes singleValueBlock:^NSInteger(AICMVNodeBase *mvNode) {
        if (ISOK(mvNode, AICMVNodeBase.class)) {
            return [NUMTOOK([AINetIndex getData:mvNode.urgentTo_p]) integerValue];
        }
        return 0;
    }];
}


/**
 *  MARK:--------------------取aNode和bNode的抽象delta值--------------------
 */
+(NSInteger) getAbsDelta:(NSArray*)mvNodes {
    return [self getAbsValue:mvNodes singleValueBlock:^NSInteger(AICMVNodeBase *mvNode) {
        if (ISOK(mvNode, AICMVNodeBase.class)) {
            return [NUMTOOK([AINetIndex getData:mvNode.delta_p]) integerValue];
        }
        return 0;
    }];
}


//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------获取平均值方法--------------------
 */
+(NSInteger) getAbsValue:(NSArray*)mvNodes singleValueBlock:(NSInteger(^)(AICMVNodeBase*))singleValueBlock{
    //1. 数据检查
    if (!ARRISOK(mvNodes) || !singleValueBlock) {
        return 0;
    }
    
    //2. 取SUM(urgentTo | delta)
    NSInteger sum = 0;
    for (AICMVNodeBase *mvNode in mvNodes) {
        NSInteger singleValue = singleValueBlock(mvNode);
        sum += singleValue;
    }
    
    //3. 取absUrgentTo | absDelta; (//由MIN(aUrgentTo, bUrgentTo)改为平均)
    NSInteger absValue = sum / (int)mvNodes.count;
    return absValue;
}


@end
