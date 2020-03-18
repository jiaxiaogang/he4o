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
        [theNV setNodeData:lastProtoAlg_p lightStr:@"lastItem2"];
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
            NSLog(@"当前item_p:%@ -------------------",[NVHeUtil getLightStr:item_p]);
            refPorts = ARR_SUB(refPorts, 0, cPartMatchingCheckRefPortsLimit);
            for (NSInteger i = 0; i < refPorts.count; i++) {
                AIPort *item = ARR_INDEX(refPorts, i);
                AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item.target_p];
                NSString *countDesc = @"";
                NSString *classDesc = @"";
                NSString *reMd5 = @"";
                if (itemAlg) {
                    classDesc = ISOK(itemAlg, AIAbsAlgNode.class) ? @"抽象" : @"具象";
                    countDesc = STRFORMAT(@"%ld/%ld",itemAlg.content_ps.count,proto_ps.count);
                    reMd5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:itemAlg.content_ps]]);
                }
                NSLog(@"{稀疏码:%@=%ld} -%ld-> {概念:%@=%ld[%@][%@][isMem:%d]} 下标:%ld, MD5:%d",
                      item_p.identifier,item_p.pointerId,(long)item.strong.value,
                      itemAlg.pointer.identifier,itemAlg.pointer.pointerId,classDesc,countDesc,itemAlg.pointer.isMem,
                      (long)i,
                      [reMd5 isEqualToString:item.header]);
            }
            //TODOTOMORROW:
            //查下为什么那么多远投坚果,最终 (Height5).refPorts才3个;
            //连续直投,然后重启远投,会有content_ps.count=0的情况, (2_AIVisionAlgs_0);
            //但在构建日志中,有两次抽象2,分别存内存和硬盘,长度都为5;
            
            //1. 确定一下长度=0,是否是因为未持久化;
            //2. 找下因非全含失败的原因;
            
            //3. 进行计数
            for (AIPort *refPort in refPorts) {
                if (!exceptBlock(refPort.target_p)) {
                    NSData *key = [NSKeyedArchiver archivedDataWithRootObject:refPort.target_p];
                    int oldCount = [NUMTOOK([countDic objectForKey:key]) intValue];
                    [countDic setObject:@(oldCount + 1) forKey:key];
                }
            }
            NSLog(@"匹配情况: %@ -----------------",countDic.allValues);
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
        for (NSData *key in sortKeys) {
            AIKVPointer *key_p = [NSKeyedUnarchiver unarchiveObjectWithData:key];
            AINodeBase *result = [SMGUtils searchNode:key_p];
            int matchingCount = [NUMTOOK([countDic objectForKey:key]) intValue];
            
            //6. 判断全含; (matchingCount == assAlg.content.count) (且只能识别为抽象节点)
            if (ISOK(result, AIAbsAlgNode.class) && result.content_ps.count == matchingCount) {
                return result;
            }
            if (!ISOK(result, AIAbsAlgNode.class) && result.content_ps.count != matchingCount) {
                typeCountWrong ++;
            }else if (!ISOK(result, AIAbsAlgNode.class)) {
                typeWrong ++;
            }else if(result.content_ps.count != matchingCount){
                countWrong ++;
            }
            WLog(@"识别 Item失败原因分析 > 类型:%@ AssCount:%ld 匹配长度:%d",result.class,result.content_ps.count,matchingCount);
        }
        WLog(@"识别结果 >> 非抽象且非全含:%ld,非抽象数:%ld,非全含数:%ld / 总数:%lu",(long)typeCountWrong,(long)typeWrong,countWrong,(unsigned long)sortKeys.count);
        
        NSLog(@"");
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
+(NSArray*) matchAlg2FuzzyAlgV2:(AIAlgNodeBase*)protoAlg matchAlg:(AIAlgNodeBase*)matchAlg {
    //1. 数据准备;
    if (!protoAlg || !matchAlg) {
        return nil;
    }
    
    //2. matchAlg未匹配之处 (目前仅支持单特征);
    NSArray *pSubMs = [SMGUtils removeSub_ps:matchAlg.content_ps parent_ps:protoAlg.content_ps];
    
    //3. 取proto同层的sameLevel前20个;
    NSArray *sameLevel_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All:matchAlg]];
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
        NSLog(@"M同层有效节点数为:%lu",(unsigned long)validConDatas.count);
        
        //b. 对result3进行取值value并排序: result4 (根据差的绝对值大小排序);
        double pValue = [NUMTOOK([AINetIndex getData:pValue_p]) doubleValue];
        NSArray *sortConDatas = [validConDatas sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            double v1 = [NUMTOOK([obj1 objectForKey:@"v"]) doubleValue];
            double v2 = [NUMTOOK([obj2 objectForKey:@"v"]) doubleValue];
            double absV1 = fabs(v1 - pValue);
            double absV2 = fabs(v2 - pValue);
            return absV1 > absV2 ? NSOrderedAscending : absV1 < absV2 ? NSOrderedDescending : NSOrderedSame;
        }];
        NSLog(@"M同层,具象节点排序好后:%@",sortConDatas);
        
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
    }
    
    //5. 对最终结果进行排序;
    NSArray *result = [fuzzyAlgs sortedArrayUsingComparator:^NSComparisonResult(AIKVPointer *p1, AIKVPointer *p2) {
        //a. 数据准备;
        NSInteger p1Count = 0,p2Count = 0,p1IndexSum = 0,p2IndexSum = 0;
        
        //b. 获取匹配量 (越大越相似);
        for (NSArray *sortConAlgs in allSortConAlgs) {
            for (NSInteger i = 0; i < sortConAlgs.count; i++) {
                AIAlgNodeBase *item = ARR_INDEX(sortConAlgs, i);
                if ([item.pointer isEqual:p1]) {
                    p1Count ++;
                    p1IndexSum += i;
                }else if ([item.pointer isEqual:p2]) {
                    p2Count ++;
                    p2IndexSum += i;
                }
            }
        }
        
        //c. 获取相似度 (越小越相似);
        CGFloat p1Similarity = p1Count > 0 ? (float)p1IndexSum / p1Count : 0;
        CGFloat p2Similarity = p2Count > 0 ? (float)p2IndexSum / p2Count : 0;
        
        //d. 一级对比匹配量;
        if (p1Count != p2Count) {
            return p1Count > p2Count ? NSOrderedAscending : NSOrderedDescending;
        }else{
            //3. 二级对比相似度;
            return p1Similarity == p2Similarity ? NSOrderedSame : p1Similarity < p2Similarity ? NSOrderedAscending : NSOrderedDescending;
        }
    }];
    return result;
}

@end
