//
//  TIRUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2020/1/10.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TIRUtils.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "AIAbsAlgNode.h"
#import "AINetUtils.h"
#import "ThinkingUtils.h"
#import "AINetIndex.h"
#import "NSString+Extension.h"
#import "AINetIndexUtils.h"
//temp
#import "NVHeUtil.h"

@implementation TIRUtils

/**
 *  MARK:--------------------时序识别之: protoFo&assFo匹配判断--------------------
 *  要求: protoFo必须全含assFo对应的last匹配下标之前的所有元素;
 *  例如: 如: protFo:[abcde] 全含 assFo:[acefg]
 *  名词说明:
 *      1. 全含: 指从lastAssIndex向前,所有的assItemAlg都匹配成功;
 *      2. 非全含: 指从lastAssIndex向前,只要有一个assItemAlg匹配失败,则非全含;
 *  @param success : lastAssIndex指已发生到的index,后面则为时序预测; matchValue指匹配度(0-1);
 *  @param protoFo : 四层说明: 在fromShortMem时,protoFo中的概念元素为parent层, 而在fromRethink时,其元素为match层;
 */
+(void) TIR_Fo_CheckFoValidMatch:(AIFoNodeBase*)protoFo assFo:(AIFoNodeBase*)assFo checkItemValid:(BOOL(^)(AIKVPointer *itemAlg,AIKVPointer *assAlg))checkItemValid success:(void(^)(NSInteger lastAssIndex,CGFloat matchValue))success failure:(void(^)(NSString *msg))failure {
    //1. 数据准备;
    BOOL paramValid = protoFo && protoFo.content_ps.count > 0 && assFo && assFo.content_ps.count > 0 && success && checkItemValid;
    if (!paramValid) {
        failure(@"参数错误");
        return;
    }
    AIKVPointer *lastProtoAlg_p = ARR_INDEX_REVERSE(protoFo.content_ps, 0); //最后一个protoAlg指针
    int validItemCount = 1;                                                 //默认有效数为1 (因为lastAlg肯定有效);
    NSInteger lastAssIndex = -1;                                            //在assFo已发生到的index,后面为预测;
    NSInteger lastProtoIndex = protoFo.content_ps.count - 2;                //protoAlg匹配判断从倒数第二个开始,向前逐个匹配;
    
    //2. 找出lastIndex
    for (NSInteger i = 0; i < assFo.content_ps.count; i++) {
        NSInteger curIndex = assFo.content_ps.count - i - 1;
        AIKVPointer *checkAssAlg_p = ARR_INDEX(assFo.content_ps, curIndex);
        if (checkItemValid(lastProtoAlg_p,checkAssAlg_p)) {
            lastAssIndex = curIndex;
            break;
        }
    }
    if (lastAssIndex == -1) {
        failure(@"时序识别: lastItem匹配失败,查看是否在联想时就出bug了");
        [theNV setNodeData:lastProtoAlg_p appendLightStr:@"lastItem2"];
        [theNV setNodeData:assFo.pointer lightStr:@"assFo2"];
        return;
    }else{
        NSLog(@"时序识别: lastItem匹配成功");
    }
    
    //3. 从lastAssIndex向前逐个匹配;
    for (NSInteger i = lastAssIndex - 1; i >= 0; i--) {
        AIKVPointer *checkAssAlg_p = ARR_INDEX(assFo.content_ps, i);
        if (checkAssAlg_p) {
            
            //4. 在protoFo中同样从lastProtoIndex依次向前找匹配;
            BOOL checkResult = false;
            for (NSInteger j = lastProtoIndex; j >= 0; j--) {
                AIKVPointer *protoAlg_p = ARR_INDEX(protoFo.content_ps, j);
                if (checkItemValid(protoAlg_p,checkAssAlg_p)) {
                    lastProtoIndex = j; //成功匹配alg时,更新protoIndex (以达到只能向前匹配的目的);
                    checkResult = true;
                    validItemCount ++;  //有效数+1;
                    NSLog(@"时序识别: item有效+1");
                    break;
                }
            }
            
            //5. 非全含 (一个失败,全盘皆输);
            if (!checkResult) {
                [theNV setNodeData:checkAssAlg_p lightStr:@"3item未匹配"];
                [theNV setNodeData:assFo.pointer lightStr:@"3assFo"];
                [theNV setNodeData:protoFo.pointer lightStr:@"3protoFo"];
                failure(@"时序识别: item无效,未在protoFo中找到,所有非全含,不匹配");
                return;
            }
        }
    }
    
    //6. 到此全含成功 之: 匹配度计算
    CGFloat matchValue = (float)validItemCount / assFo.content_ps.count;
    
    //7. 到此全含成功 之: 返回success
    success(lastAssIndex,matchValue);
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
            //1> 数据准备 (value_p的refPorts是单独存储的);
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
            NSLog(@"当前item_p:%@ -------------------数量:%lu",[NVHeUtil getLightStr:item_p],(unsigned long)refPorts.count);
            //TODOTOMORROW:
            //查下为什么那么多远投坚果,最终 (Height5).refPorts才3个;
            
            //3. 进行计数
            for (AIPort *refPort in refPorts) {
                if (!exceptBlock(refPort.target_p)) {
                    NSData *key = OBJ2DATA(refPort.target_p);
                    int oldCount = [NUMTOOK([countDic objectForKey:key]) intValue];
                    [countDic setObject:@(oldCount + 1) forKey:key];
                }
            }
            if (countDic.count) NSLog(@"匹配情况: %@ -----------------",countDic.allValues);
        }
        
        //4. 排序相似数从大到小;
        NSArray *sortKeys = ARRTOOK([countDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            int matchingCount1 = [NUMTOOK([countDic objectForKey:obj1]) intValue];
            int matchingCount2 = [NUMTOOK([countDic objectForKey:obj2]) intValue];
            return matchingCount1 < matchingCount2;
        }]);
        
        //5. 从大到小,依次取到对应的node和matchingCount
        NSInteger typeWrong = 0;
        NSInteger countWrong = 0;
        NSInteger typeCountWrong = 0;
        WLog(@"proto___________长度:%lu 内容:[%@]",proto_ps.count,[NVHeUtil getLightStr4Ps:proto_ps]);
        for (NSData *key in sortKeys) {
            AIKVPointer *key_p = DATA2OBJ(key);
            AINodeBase *result = [SMGUtils searchNode:key_p];
            int matchingCount = [NUMTOOK([countDic objectForKey:key]) intValue];
            
            //6. 判断全含; (matchingCount == assAlg.content.count) (且只能识别为抽象节点)
            if (ISOK(result, AIAbsAlgNode.class) && result.content_ps.count == matchingCount) {
                NSLog(@"=======MatchAlg Success_长度:%lu 匹配:%d 类型:%@ 内容:[%@]",(unsigned long)result.content_ps.count,matchingCount,result.class,[NVHeUtil getLightStr4Ps:result.content_ps]);
                return result;
            }
            if (!ISOK(result, AIAbsAlgNode.class) && result.content_ps.count != matchingCount) {
                typeCountWrong ++;
            }else if (!ISOK(result, AIAbsAlgNode.class)) {
                typeWrong ++;
            }else if(result.content_ps.count != matchingCount){
                countWrong ++;
            }
            WLog(@"Item识别失败_长度:%lu 匹配:%d 类型:%@ 内容:[%@]",(unsigned long)result.content_ps.count,matchingCount,result.class,[NVHeUtil getLightStr4Ps:result.content_ps]);
        }
        WLog(@"识别结果 >> 非抽象且非全含:%ld,非抽象数:%ld,非全含数:%ld / 总数:%lu",(long)typeCountWrong,(long)typeWrong,countWrong,(unsigned long)sortKeys.count);
    }
    return nil;
}

//MARK:===============================================================
//MARK:                     < 模糊匹配 >
//MARK:===============================================================

/**
 *  MARK:--------------------对概念识别算法补充模糊匹配功能--------------------
 *  @caller : 由TIR_Alg.partMatching()方法调用;
 *  @参考: 18151
 *  @time 2020.03.06
 *  @version :
 *      v1: 仅支持单个稀疏码不同,并仅返回单个最相似的结果;
 *      v2: 支持多个稀疏码不同,并支持返回多个相似度排序后的结果;
 */
+(NSArray*) matchAlg2FuzzyAlgV2:(AIAlgNodeBase*)protoAlg matchAlg:(AIAlgNodeBase*)matchAlg except_ps:(NSArray*)except_ps{
    NSLog(@"=============== Fuzzy Start ===============");
    //1. 数据准备;
    except_ps = ARRTOOK(except_ps);
    if (!protoAlg || !matchAlg) {
        return nil;
    }
    
    //2. matchAlg未匹配之处;
    NSArray *pSubMs = [SMGUtils removeSub_ps:matchAlg.content_ps parent_ps:protoAlg.content_ps];
    
    //3. 取proto同层的sameLevel前20个 (排除(含proto)不算);
    NSArray *sameLevel_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:matchAlg]];
    sameLevel_ps = [SMGUtils removeSub_ps:except_ps parent_ps:sameLevel_ps];
    sameLevel_ps = ARR_SUB(sameLevel_ps, 0, cMCValue_ConAssLimit);
    
    //4. 逐个稀疏码,找模糊匹配节点数组;
    NSMutableArray *allSortConAlgs = [[NSMutableArray alloc] init];//收集所有排序好的匹配节点数组 (二维数组);
    NSMutableArray *fuzzyAlgs = [[NSMutableArray alloc] init];//收集所有模糊匹配到的同级节点指针;
    for (AIKVPointer *pValue_p in pSubMs) {
        //a. 对result2筛选出包含同标识value值的: result3;
        __block NSMutableArray *validConDatas = [[NSMutableArray alloc] init];
        [ThinkingUtils filterAlg_Ps:sameLevel_ps valueIdentifier:pValue_p.identifier itemValid:^(AIAlgNodeBase *alg, AIKVPointer *value_p) {
            NSNumber *value = [AINetIndex getData:value_p];
            if (alg && value) {
                [validConDatas addObject:@{@"a":alg,@"v":value}];
            }
        }];
        
        //b. 对result3进行取值value并排序: result4 (根据差的绝对值小的排前面);
        double pValue = [NUMTOOK([AINetIndex getData:pValue_p]) doubleValue];
        NSArray *sortConDatas = [validConDatas sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            double v1 = [NUMTOOK([obj1 objectForKey:@"v"]) doubleValue];
            double v2 = [NUMTOOK([obj2 objectForKey:@"v"]) doubleValue];
            double absV1 = fabs(v1 - pValue);
            double absV2 = fabs(v2 - pValue);
            return absV1 > absV2 ? NSOrderedDescending : absV1 < absV2 ? NSOrderedAscending : NSOrderedSame;
        }];
        
        //c. 转成sortConAlgs & allValidSameLevel_ps
        NSMutableArray *sortConAlgs = [[NSMutableArray alloc] init];
        for (NSDictionary *sortConData in sortConDatas) {
            AIAlgNodeBase *algNode = [sortConData objectForKey:@"a"];
            [sortConAlgs addObject:algNode];
            if (![fuzzyAlgs containsObject:algNode]) {
                [fuzzyAlgs addObject:algNode];
            }
        }
        
        //d. 收集结果
        [allSortConAlgs addObject:sortConAlgs];
        
        //e. 调试日志
        NSLog(@"-------------------> Fuzzy同层:%@ 有效数:%d 排序基准:%@",[NVHeUtil getLightStr:pValue_p],validConDatas.count,[NSString removeFloatZero:STRFORMAT(@"%f",pValue)]);
        for (NSDictionary *item in sortConDatas) {
            AIAlgNodeBase *itemAlg = [item objectForKey:@"a"];
            NSLog(@"--> 地址:%d 内容:[%@] 值:%@",itemAlg.pointer.pointerId,[NVHeUtil getLightStr4Ps:itemAlg.content_ps],[item objectForKey:@"v"]);
        }
    }
    
    //5. 对最终结果进行排序;
    NSArray *result = [fuzzyAlgs sortedArrayUsingComparator:^NSComparisonResult(AIAlgNodeBase *a1, AIAlgNodeBase *a2) {
        //a. 数据准备;
        NSInteger a1Count = 0,a2Count = 0,a1IndexSum = 0,a2IndexSum = 0;
        
        //b. 获取匹配量 (越大越相似);
        for (NSArray *sortConAlgs in allSortConAlgs) {
            for (NSInteger i = 0; i < sortConAlgs.count; i++) {
                AIAlgNodeBase *item = ARR_INDEX(sortConAlgs, i);
                if ([item isEqual:a1]) {
                    a1Count ++;
                    a1IndexSum += i;
                }else if ([item isEqual:a2]) {
                    a2Count ++;
                    a2IndexSum += i;
                }
            }
        }
        
        //c. 获取相似度 (越小越相似);
        CGFloat a1Similarity = a1Count > 0 ? (float)a1IndexSum / a1Count : 0;
        CGFloat a2Similarity = a2Count > 0 ? (float)a2IndexSum / a2Count : 0;
        
        //d. 一级对比匹配量 (值大的排前面);
        if (a1Count != a2Count) {
            return a1Count > a2Count ? NSOrderedAscending : NSOrderedDescending;
        }else{
            //3. 二级对比相似度 (值小的排前面);
            return a1Similarity == a2Similarity ? NSOrderedSame : a1Similarity > a2Similarity ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
    
    [theApp.nvView setNodeData:protoAlg.pointer appendLightStr:STRFORMAT(@"%ld_fuzzyP",protoAlg.pointer.pointerId)];
    [theApp.nvView setNodeData:matchAlg.pointer appendLightStr:STRFORMAT(@"%ld_fuzzyM",protoAlg.pointer.pointerId)];
    for (NSInteger i = 0; i < result.count; i++) {
        AIAlgNodeBase *item = ARR_INDEX(result, i);
        [theApp.nvView setNodeData:item.pointer appendLightStr:STRFORMAT(@"%ld_fuzzyR(%ld)",protoAlg.pointer.pointerId,(long)i)];
        NSLog(@"=======FuzzyAlg Success_地址:%d 长度:%lu 内容:[%@] (P数:%d / M数:%d)",item.pointer.pointerId,item.content_ps.count,[NVHeUtil getLightStr4Ps:item.content_ps],(unsigned long)protoAlg.content_ps.count,matchAlg.content_ps.count);
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < 内类比 >
//MARK:===============================================================

/**
 *  MARK:--------------------内类比构建抽象概念--------------------
 *  @注意: 此处algNode和algNode_Inner应该是组分关系,但先保持抽具象关系,看后面测试,有没别的影响,再改 (参考179_内类比全流程回顾)
 *  @desc 大小时
 */
+(AIAbsAlgNode*)createInnerAbsAlg_NoRepeat:(AIAlgNodeBase*)conAlg value_p:(AIPointer*)value_p{
    //1. 数据检查
    if (!value_p) return nil;
    //2. 有则加强;
    AIAbsAlgNode *assAlg = [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValueP:value_p];
    if (ISOK(assAlg, AIAbsAlgNode.class)) {
        [AINetUtils relateAlgAbs:assAlg conNodes:@[conAlg]];
        return assAlg;
    }else{
        //3. 无则构建
        return [theNet createAbsAlgNode:@[value_p] conAlgs:@[conAlg] isMem:false];
    }
}

/**
 *  MARK:--------------------内类比构建抽象时序--------------------
 */
+(AINetAbsFoNode*)createInnerAbsFo:(AIAlgNodeBase*)backAlg rangeAlg_ps:(NSArray*)rangeAlg_ps conFo:(AIFoNodeBase*)conFo{
    //1. 数据检查
    if (!backAlg || !conFo) return nil;
    rangeAlg_ps = ARRTOOK(rangeAlg_ps);
    
    //2. 拼接content_ps
    NSMutableArray *absOrders = [[NSMutableArray alloc] init];
    [absOrders addObjectsFromArray:rangeAlg_ps];
    [absOrders addObject:backAlg.pointer];
    
    //3. 构建
    AINetAbsFoNode *result = [theNet createAbsFo_Inner:conFo orderSames:absOrders];
    return result;
}

@end
