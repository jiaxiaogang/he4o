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
#import "AIAbsCMVNode.h"
#import "AIPort.h"
#import "ThinkingUtils.h"

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

+(NSInteger) getDefaultStrong_Index:(AIAbsCMVNode*)absMv conMvs:(NSArray*)conMvs{
    if (absMv && ARRISOK(conMvs)) {
        //1. 取出方向索引;
        NSInteger delta = [NUMTOOK([AINetIndex getData:absMv.delta_p]) integerValue];
        MVDirection direction = [ThinkingUtils getMvReferenceDirection:delta];
        NSArray *indexes = [theNet getNetNodePointersFromDirectionReference:absMv.pointer.algsType direction:direction limit:INT_MAX];
        
        //2. 筛出最强方向索引强度;
        NSInteger maxStrong = 0;
        for (__block AICMVNodeBase *weakConMv in conMvs) {
            AIPort *findPort = ARR_INDEX([SMGUtils filterArr:indexes checkValid:^BOOL(AIPort *item) {
                return [item.target_p isEqual:weakConMv.pointer];
            }], 0);
            if (findPort && maxStrong < findPort.strong.value) {
                maxStrong = findPort.strong.value;
            }
        }
        return maxStrong + 1;
    }
    return 1;
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
