//
//  AINetIndexUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/31.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AINetIndexUtils.h"
#import "NSString+Extension.h"
#import "AIKVPointer.h"
#import "AIPort.h"

@implementation AINetIndexUtils

//MARK:===============================================================
//MARK:                     < 概念绝对匹配 >
//MARK:===============================================================
+(id) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p{
    AIAlgNodeBase *result = nil;
    if (value_p) {
        return [self getAbsoluteMatchingAlgNodeWithValuePs:@[value_p]];
    }
    return result;
}
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps{
    AIAlgNodeBase *result = [self getAbsoluteMatchingAlgNodeWithValuePs:value_ps exceptAlg_p:nil isMem:true];
    if (!result) {
        result = [self getAbsoluteMatchingAlgNodeWithValuePs:value_ps exceptAlg_p:nil isMem:false];
    }
    return result;
}
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps exceptAlg_p:(AIPointer*)exceptAlg_p isMem:(BOOL)isMem {
    ///1. 绝对匹配 -> (header匹配)
    value_ps = ARRTOOK(value_ps);
    NSString *valuesMD5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:[SMGUtils sortPointers:value_ps]]]);
    for (AIPointer *value_p in value_ps) {
        NSArray *refPorts = ARRTOOK([SMGUtils searchObjectForFilePath:value_p.filePath fileName:kFNRefPorts_All(isMem) time:cRTReference_All(isMem)]);
        
        for (AIPort *refPort in refPorts) {
            
            ///2. 依次绝对匹配header,找到则返回;
            if (![refPort.target_p isEqual:exceptAlg_p] && [valuesMD5 isEqualToString:refPort.header]) {
                AIAlgNodeBase *result = [SMGUtils searchNode:refPort.target_p];
                return result;
            }
        }
    }
    return nil;
}

@end
