//
//  AINetAbsCMVUtil.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/27.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsCMVUtil.h"
#import "AIKVPointer.h"

@implementation AINetAbsCMVUtil


/**
 *  MARK:--------------------取aNode和bNode的抽象urgentTo值--------------------
 */
+(NSInteger) getAbsUrgentTo:(AICMVNodeBase*)aMv bMv_p:(AICMVNodeBase*)bMv{
    //1. 数据检查
    if (!aMv || !bMv) {
        return 0;
    }
    
    //2. 取urgentTo
    NSInteger aUrgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:aMv.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    NSInteger bUrgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:bMv.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    
    //3. 取absUrgentTo;
    NSInteger absUrgentTo = MIN(aUrgentTo, bUrgentTo);
    return absUrgentTo;
}


/**
 *  MARK:--------------------取aNode和bNode的抽象delta值--------------------
 */
+(NSInteger) getAbsDelta:(AICMVNodeBase*)aMv bMv_p:(AICMVNodeBase*)bMv{
    //1. 数据检查
    if (!aMv || !bMv) {
        return 0;
    }
    
    //2. 取delta
    NSInteger aDelta = [NUMTOOK([SMGUtils searchObjectForPointer:aMv.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    NSInteger bDelta = [NUMTOOK([SMGUtils searchObjectForPointer:bMv.delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    
    //3. 取absDelta值;
    NSInteger absDelta = MIN(aDelta, bDelta);
    return absDelta;
}



@end
