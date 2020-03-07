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
#import "AIAbsAlgNode.h"
#import "AINetUtils.h"
#import "ThinkingUtils.h"
#import "AINetIndex.h"

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
    } exceptBlock:^BOOL(AIPointer *target_p) {
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
 *  @desc 迭代记录:
 *      2019.12.23 - 迭代支持全含,参考17215 (代码中由判断相似度,改为判断全含)
 */
+(id) partMatching_General:(NSArray*)proto_ps
             refPortsBlock:(NSArray*(^)(AIKVPointer *item_p))refPortsBlock
               exceptBlock:(BOOL(^)(AIPointer *target_p))exceptBlock{
    //1. 数据准备;
    if (ARRISOK(proto_ps)) {
        NSMutableDictionary *countDic = [[NSMutableDictionary alloc] init];
        
        //2. 对每个微信息,取被引用的强度前cPartMatchingCheckRefPortsLimit个;
        for (AIKVPointer *item_p in proto_ps) {
            NSArray *refPorts = refPortsBlock(item_p);
            refPorts = ARR_SUB(refPorts, 0, cPartMatchingCheckRefPortsLimit);
            
            //3. 进行计数
            for (AIPort *refPort in refPorts) {
                if (!exceptBlock(refPort.target_p)) {
                    NSData *key = [NSKeyedArchiver archivedDataWithRootObject:refPort.target_p];
                    int oldCount = [NUMTOOK([countDic objectForKey:key]) intValue];
                    [countDic setObject:@(oldCount + 1) forKey:key];
                }
            }
        }
        
        //4. 排序相似数从大到小;
        NSArray *sortKeys = ARRTOOK([countDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            int matchingCount1 = [NUMTOOK([countDic objectForKey:obj1]) intValue];
            int matchingCount2 = [NUMTOOK([countDic objectForKey:obj2]) intValue];
            return matchingCount1 < matchingCount2;
        }]);
        
        //5. 从大到小,依次取到对应的node和matchingCount
        NSInteger typeWrong = 0;
        for (NSData *key in sortKeys) {
            AIKVPointer *key_p = [NSKeyedUnarchiver unarchiveObjectWithData:key];
            AINodeBase *result = [SMGUtils searchNode:key_p];
            int matchingCount = [NUMTOOK([countDic objectForKey:key]) intValue];
            
            //6. 判断全含; (matchingCount == assAlg.content.count) (且只能识别为抽象节点)
            if (ISOK(result, AIAbsAlgNode.class) && result.content_ps.count == matchingCount) {
                return result;
            }
            if (!ISOK(result, AIAbsAlgNode.class)) {
                typeWrong ++;
            }else{
                [theNV setNodeData:result.pointer lightStr:@"识别到抽象正确"];
            }
        }
        WLog(@"识别结果 >> 非抽象数:%ld / 总数:%lu",(long)typeWrong,(unsigned long)sortKeys.count);
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < 模糊匹配 >
//MARK:===============================================================
/**
 *  MARK:--------------------对识别算法补充模糊匹配功能--------------------
 *  @caller : 由TIR_Alg.partMatching()方法调用;
 *  @参考: 18151
 *  @time 2020.03.06
 */
+(AIAlgNodeBase*) partMatching_Alg_Fuzzy:(AIAlgNodeBase*)protoAlg matchAlg:(AIAlgNodeBase*)matchAlg {
    //1. 数据准备;
    if (!protoAlg || !matchAlg) {
        return nil;
    }
    
    //2. matchAlg未匹配之处;
    NSArray *pSubMs = [SMGUtils removeSub_ps:protoAlg.content_ps parent_ps:matchAlg.content_ps];
    
    //3. 取proto同层的sameLevel前20个;
    NSArray *sameLevel_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:matchAlg]];
    sameLevel_ps = ARR_SUB(sameLevel_ps, 0, cMCValue_ConAssLimit);
    
    //4. 对未匹配稀疏码进行逐一模糊匹配;
    NSMutableDictionary *scoreboard = [[NSMutableDictionary alloc] init];
    __block NSMutableArray *validConData = [[NSMutableArray alloc] init];
    for (AIKVPointer *pValue_p in pSubMs) {
        //5. 对result2筛选出包含同标识value值的: result3;
        [ThinkingUtils filterAlg_Ps:sameLevel_ps valueIdentifier:pValue_p.identifier itemValid:^(AIAlgNodeBase *alg, AIKVPointer *value_p) {
            NSNumber *value = [AINetIndex getData:value_p];
            if (alg && value) {
                //6. 收集同标记的具象节点的数据,并且记到计数牌;
                [validConData addObject:@{@"a":alg,@"v":value}];
                NSString *sbKey = STRFORMAT(@"%@_%ld",alg.pointer.identifier,(long)alg.pointer.pointerId);
                NSInteger sbValue = [NUMTOOK([scoreboard objectForKey:sbKey]) integerValue];
                [scoreboard setObject:@(sbValue + 1) forKey:sbKey];
            }
        }];
    }
    
    NSLog(@"M同层有效节点数为:%ld",validConData.count);
    
    //5. 找出以上sameLevel_ps中,匹配到pValue_p最多次的结果;
    

    
    //7. 对result3进行取值value并排序: result4 (根据差的绝对值大小排序);
    double mValue = [NUMTOOK([AINetIndex getData:msValue_p]) doubleValue];
    NSArray *sortConData = [validConData sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        double v1 = [NUMTOOK([obj1 objectForKey:@"v"]) doubleValue];
        double v2 = [NUMTOOK([obj2 objectForKey:@"v"]) doubleValue];
        double absV1 = fabs(v1 - mValue);
        double absV2 = fabs(v2 - mValue);
        return absV1 > absV2 ? NSOrderedAscending : absV1 < absV2 ? NSOrderedDescending : NSOrderedSame;
    }];
    NSLog(@"M同层,具象节点排序好后:%@",sortConData);
    if (!ARRISOK(sortConData)) {
        complete(alreadayGLs,acts);
        return;
    }
    
    //8. 对result4中前5个进行反思;
    NSDictionary *firstConData = ARR_INDEX(sortConData, 0);
    AIAlgNodeBase *firstConAlg = [firstConData objectForKey:@"a"];
}

@end
