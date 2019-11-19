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
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p{
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


//MARK:===============================================================
//MARK:                     < 概念局部匹配 >
//MARK:===============================================================

/**
 *  MARK:--------------------概念局部匹配--------------------
 *  @param except_ps : 排除_ps; (如:同一批次输入的概念组,不可用来识别自己)
 */
+(AIAlgNodeBase*) partMatching_Alg:(AIAlgNodeBase*)algNode isMem:(BOOL)isMem except_ps:(NSArray*)except_ps{
    //1. 数据准备;
    if (!ISOK(algNode, AIAlgNodeBase.class)) {
        return nil;
    }
    except_ps = ARRTOOK(except_ps);
    
    //2. 调用通用局部 匹配方法;
    return [self partMatching_General:algNode.content_ps refPortsBlock:^NSArray *(AIKVPointer *item_p) {
        if (item_p) {
            //1> value_p的refPorts是单独存储的;
            return ARRTOOK([SMGUtils searchObjectForFilePath:item_p.filePath fileName:kFNRefPorts_All(isMem) time:cRTReference_All(isMem)]);
        }
        return nil;
    } exceptBlock:^BOOL(AIKVPointer *target_p) {
        if (target_p) {
            //2> 自身 | 排除序列 不可激活;
            return [target_p isEqual:algNode.pointer] || [SMGUtils containsSub_p:target_p parent_ps:except_ps];
        }
        return true;
    }];
}

/**
 *  MARK:--------------------时序的局部匹配--------------------
 *  废弃: 被顺序的专用匹配方法所取代;
 */
//+(id) partMatching_Fo:(AIFoNodeBase*)protoNode{
//    //1. 数据准备
//    if (!ISOK(protoNode, AIFoNodeBase.class)) {
//        return nil;
//    }
//
//    //2. 通用局部匹配方法;
//    return [AINetIndexUtils partMatching_General:protoNode.content_ps refPortsBlock:^NSArray *(AIKVPointer *item_p) {
//        //1> 返回alg.refPorts;
//        AIAlgNodeBase *itemNode = [SMGUtils searchNode:item_p];
//        if (itemNode) {
//            return itemNode.refPorts;
//        }
//        return nil;
//    } exceptBlock:^BOOL(AIKVPointer *target_p) {
//        //2> 不可匹配自己;
//        if (target_p) {
//            return [target_p isEqual:protoNode.pointer];
//        }
//        return true;
//    }];
//}

/**
 *  MARK:--------------------通用局部匹配方法--------------------
 *  注: 根据引用找出相似度最高且达到阀值的结果返回; (相似度匹配)
 *  从content_ps的所有value.refPorts找前cPartMatchingCheckRefPortsLimit个, 如:contentCount9*limit5=45个;
 *  @param exceptBlock : notnull 排除回调,不可激活则返回true;
 *  @param refPortsBlock : notnull 取item_p.refPorts的方法;
 *  @result 把最匹配的返回;
 */
+(id) partMatching_General:(NSArray*)proto_ps
             refPortsBlock:(NSArray*(^)(AIKVPointer *item_p))refPortsBlock
               exceptBlock:(BOOL(^)(AIKVPointer *target_p))exceptBlock{
    //1. 数据准备;
    if (ARRISOK(proto_ps)) {
        NSMutableDictionary *countDic = [[NSMutableDictionary alloc] init];
        NSData *maxKey = nil;
        
        //2. 对每个微信息,取被引用的强度前cPartMatchingCheckRefPortsLimit个;
        for (AIKVPointer *item_p in proto_ps) {
            NSArray *refPorts = refPortsBlock(item_p);
            refPorts = ARR_SUB(refPorts, 0, cPartMatchingCheckRefPortsLimit);
            
            //3. 进行计数
            for (AIPort *refPort in refPorts) {
                if (!exceptBlock(item_p)) {
                    NSData *key = [NSKeyedArchiver archivedDataWithRootObject:refPort.target_p];
                    int oldCount = [NUMTOOK([countDic objectForKey:key]) intValue];
                    [countDic setObject:@(oldCount + 1) forKey:key];
                }
            }
        }
        
        //4. 从计数器countDic 中 找出最相似(计数最大)的maxKey
        for (NSData *key in countDic.allKeys) {
            
            //5. 达到局部匹配的阀值才有效;
            int curNodeMatchingCount = [NUMTOOK([countDic objectForKey:key]) intValue];
            if (((float)curNodeMatchingCount / (float)proto_ps.count) >= cPartMatchingThreshold) {
                
                //6. 取最匹配的一个;
                if (maxKey == nil || ([NUMTOOK([countDic objectForKey:maxKey]) intValue] < curNodeMatchingCount)) {
                    maxKey = key;
                }
            }
        }
        
        //7. 有结果时取出对应的assAlgNode返回;
        if (maxKey) {
            AIKVPointer *max_p = [NSKeyedUnarchiver unarchiveObjectWithData:maxKey];
            AINodeBase *result = [SMGUtils searchNode:max_p];
            return result;
        }
    }
    return nil;
}

@end
