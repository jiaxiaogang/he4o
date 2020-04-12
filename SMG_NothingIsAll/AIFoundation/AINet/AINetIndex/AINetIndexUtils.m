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
#import "AIAlgNodeBase.h"

@implementation AINetIndexUtils

//MARK:===============================================================
//MARK:                     < 概念绝对匹配 >
//MARK:===============================================================
+(id) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p{
    if (value_p) {
        return [self getAbsoluteMatchingAlgNodeWithValuePs:@[value_p]];
    }
    return nil;
}
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps{
    AIAlgNodeBase *result = [self getAbsoluteMatchingAlgNodeWithValuePs:value_ps except_ps:nil isMem:true];
    if (!result) {
        result = [self getAbsoluteMatchingAlgNodeWithValuePs:value_ps except_ps:nil isMem:false];
    }
    return result;
}
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps except_ps:(NSArray*)except_ps isMem:(BOOL)isMem {
    //1. 取数据;
    except_ps = ARRTOOK(except_ps);
    NSArray *sort_ps = [SMGUtils sortPointers:value_ps];
    
    //2. 执行并返回;
    return [self getAbsoluteMatching_General:value_ps sort_ps:sort_ps except_ps:except_ps getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
        return ARRTOOK([SMGUtils searchObjectForFilePath:item_p.filePath fileName:kFNRefPorts_All(isMem) time:cRTReference_All(isMem)]);
    }];
}


//MARK:===============================================================
//MARK:                     < 时序绝对匹配 >
//MARK:===============================================================
+(AIFoNodeBase*) getAbsoluteMatchingFoNodeWithContent_ps:(NSArray*)content_ps except_ps:(NSArray*)except_ps isMem:(BOOL)isMem {
    return [self getAbsoluteMatching_General:content_ps sort_ps:content_ps except_ps:except_ps getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
        NSArray *refPorts = nil;
        if (isMem) {
            refPorts = ARRTOOK([SMGUtils searchObjectForFilePath:item_p.filePath fileName:kFNMemRefPorts time:cRTMemReference]);
        }else{
            AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
            if (itemAlg) refPorts = itemAlg.refPorts;
        }
        return refPorts;
    }];
}


//MARK:===============================================================
//MARK:                     < 绝对匹配 (概念/时序) 通用方法 >
//MARK:===============================================================

/**
 *  MARK:--------------------alg/fo 绝对匹配通用方法--------------------
 *  @todo
 *      1. 随后支持只匹配抽象alg/fo (可由checkItemValid来实现) (可用于概念识别,因为概念识别为具象时,会导致无法建立抽具象关联);
 *          说明: 不过随后抽具象节点类会统一,所以如果这个影响不到v2.0则可不做;
 */
+(id) getAbsoluteMatching_General:(NSArray*)content_ps sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps getRefPortsBlock:(NSArray*(^)(AIKVPointer *item_p))getRefPortsBlock{
    //1. 数据检查
    if (!getRefPortsBlock) return nil;
    content_ps = ARRTOOK(content_ps);
    NSString *md5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:sort_ps]]);
    except_ps = ARRTOOK(except_ps);
    
    //2. 依次找content_ps的被引用序列,并判断header匹配;
    for (AIKVPointer *item_p in content_ps) {
        //3. 取refPorts;
        NSArray *refPorts = ARRTOOK(getRefPortsBlock(item_p));
        
        //4. 判定refPort.header是否一致;
        for (AIPort *refPort in refPorts) {
            //5. 将md5匹配header & 不在except_ps的找到并返回;
            if (![except_ps containsObject:refPort.target_p] && [md5 isEqualToString:refPort.header]) {
                return [SMGUtils searchNode:refPort.target_p];
            }
        }
    }
    return nil;
}

@end
