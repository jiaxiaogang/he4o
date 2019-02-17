//
//  AIAlgNodeManager.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/14.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAlgNodeManager.h"
#import "AIAlgNode.h"
#import "AIAbsAlgNode.h"
#import "AIPort.h"
#import "AIKVPointer.h"
#import "AINetUtils.h"
#import "NSString+Extension.h"

@implementation AIAlgNodeManager

+(AIAlgNode*) createAlgNode:(NSArray*)algsArr isOut:(BOOL)isOut{
    //1. 数据
    algsArr = ARRTOOK(algsArr);
    
    //2. 构建具象节点 (优先用本地已有,否则new)
    AIAlgNode *conNode = [[AIAlgNode alloc] init];
    conNode.pointer = [SMGUtils createPointer:PATH_NET_ALG_NODE algsType:@"" dataSource:@"" isOut:isOut];
    
    //3. 指定value_ps
    conNode.value_ps = [SMGUtils sortPointers:algsArr];
 
    //4. value.refPorts (更新引用序列)
    [AINetUtils insertPointer:conNode.pointer toRefPortsByValues:conNode.value_ps ps:conNode.value_ps];
    
    //5. 存储
    [SMGUtils insertObject:conNode rootPath:conNode.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
    
    return conNode;
}


//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================

/**
 *  MARK:--------------------查找网络中即有具象节点--------------------
 *  注: 性能优化:如果在查找过程中,共同具象节点有上百个,而又因数量等不符合,则会有卡在IO上的可能;所以此处届时可考虑使用二分法索引等来优化;
 */
//+(AIAlgNode*) findLocalConNode:(NSArray*)absNodes{
//    //1.  数据准备
//    absNodes = ARRTOOK(absNodes);
//    AIAlgNode *result = nil;
//    
//    //2. 筛选出conPort最短的absNode;
//    AIAbsAlgNode *minNode = nil;
//    for (AIAbsAlgNode *absNode in absNodes) {
//        if (minNode == nil || minNode.conPorts.count > absNode.conPorts.count) {
//            minNode = absNode;
//        }
//    }
//    
//    //3. 正向查找出absAlgNodes的共同关联的具象节点;
//    if (minNode) {
//        ///1. 循环查最小absNode的"具象路由";
//        for (AIPort *checkPort in minNode.conPorts) {
//            AIPointer *checkPointer = checkPort.target_p;
//            
//            ///2. 检查是否 同时存在所有其它absNode的"具象路由"中;
//            BOOL checkSuccess = true;
//            for (AIAbsAlgNode *item in absNodes) {
//                if (![item isEqual:minNode]) {
//                    NSArray *con_ps = [SMGUtils convertPointersFromPorts:item.conPorts];
//                    if (![SMGUtils containsSub_p:checkPointer parent_ps:con_ps]) {
//                        checkSuccess = false;
//                        break;
//                    }
//                }
//            }
//            
//            ///3. 反过来检查 "找到的具象节点" 是否也指向 "这些抽象节点";
//            if (checkSuccess) {
//                BOOL singleSuccess = true;
//                AIAlgNode *single = [SMGUtils searchObjectForPointer:checkPointer fileName:FILENAME_Node time:cRedisNodeTime];
//                if (ISOK(single, AIAlgNode.class) && single.absPorts.count == absNodes.count) {
//                    NSArray *single_ps = [SMGUtils convertPointersFromPorts:single.absPorts];
//                    for (AIAbsAlgNode *absNode in absNodes) {
//                        if (![SMGUtils containsSub_p:absNode.pointer parent_ps:single_ps]) {
//                            singleSuccess = false;
//                            break;
//                        }
//                    }
//                }
//                
//                ///4. 正反搜索都匹配,则重复使用;
//                if (singleSuccess) {
//                    result = single;
//                    break;
//                }
//            }
//        }
//    }
//    return result;
//}

+(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)algSames algA:(AIAlgNode*)algA algB:(AIAlgNode*)algB{
    if (ARRISOK(algSames) && algA && algB) {
        //1. 数据准备
        NSArray *sortSames = ARRTOOK([SMGUtils sortPointers:algSames]);
        NSString *samesStr = [SMGUtils convertPointers2String:sortSames];
        NSString *samesMd5 = STRTOOK([NSString md5:samesStr]);
        
        //2. 判断algA.absPorts和absB.absPorts中的header,是否已存在algSames的抽象节点;
        AIAbsAlgNode *findAbsNode = nil;
        NSMutableArray *allAbsPorts = [[NSMutableArray alloc] init];
        [allAbsPorts addObjectsFromArray:algA.absPorts];
        [allAbsPorts addObjectsFromArray:algB.absPorts];
        for (AIPort *port in allAbsPorts) {
            if ([samesMd5 isEqualToString:port.header]) {
                findAbsNode = [SMGUtils searchObjectForPointer:port.target_p fileName:FILENAME_Node time:cRedisNodeTime];
                break;
            }
        }
        
        //3. 无则创建
        if (!findAbsNode) {
            findAbsNode = [[AIAbsAlgNode alloc] init];
            BOOL isOut = [AINetUtils checkAllOfOut:sortSames];
            findAbsNode.pointer = [SMGUtils createPointer:PATH_NET_ALG_ABS_NODE algsType:@"" dataSource:@"" isOut:isOut];
            findAbsNode.value_ps = sortSames;
            
            //4. value.refPorts (更新微信息的引用序列)
            [AINetUtils insertPointer:findAbsNode.pointer toRefPortsByValues:findAbsNode.value_ps ps:findAbsNode.value_ps];
        }
        
        //5. 关联
        [AINetUtils insertPointer:findAbsNode.pointer toPorts:algA.absPorts ps:findAbsNode.value_ps];
        [AINetUtils insertPointer:findAbsNode.pointer toPorts:algB.absPorts ps:findAbsNode.value_ps];
        [AINetUtils insertPointer:algA.pointer toPorts:findAbsNode.conPorts ps:algA.value_ps];
        [AINetUtils insertPointer:algB.pointer toPorts:findAbsNode.conPorts ps:algA.value_ps];
        
        //6. 存储
        [SMGUtils insertObject:findAbsNode pointer:findAbsNode.pointer fileName:FILENAME_Node time:cRedisNodeTime];
        [SMGUtils insertObject:algA pointer:algA.pointer fileName:FILENAME_Node time:cRedisNodeTime];
        [SMGUtils insertObject:algB pointer:algB.pointer fileName:FILENAME_Node time:cRedisNodeTime];
        
        return findAbsNode;
    }
    return nil;
}

@end
