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

@implementation AIAlgNodeManager

+(AIAlgNode*) createAlgNode:(NSArray*)algsArr{
    //1. 构建抽象节点 (微信息"Alg引用序列"去重)
    NSMutableArray *absAlgNodes = [[NSMutableArray alloc] init];
    for (AIKVPointer *alg_p in ARRTOOK(algsArr)) {
        AIAbsAlgNode *absNode = [[AIAbsAlgNode alloc] init];
        absNode.pointer = [SMGUtils createPointerForNode:PATH_NET_ALG_ABS_NODE];
        absNode.value_p = alg_p;/////TODO引用序列去重给用上;
        
        
        
        
        
        
        [absAlgNodes addObject:absNode];
    }
    
    //2. 构建具象节点 (优先用本地已有,否则new)
    AIAlgNode *conNode = [self findLocalConNode:absAlgNodes];
    if (!conNode) {
        conNode = [[AIAlgNode alloc] init];
        conNode.pointer = [SMGUtils createPointerForNode:PATH_NET_ALG_NODE];
    }
    
    //3. 关联
    for (AIAbsAlgNode *absNode in absAlgNodes) {
        [AINetUtils insertPointer:absNode.pointer toPorts:conNode.absPorts];
        [AINetUtils insertPointer:conNode.pointer toPorts:absNode.conPorts];
    }
    
    //4. 存储抽象节点
    for (AIAbsAlgNode *absNode in absAlgNodes) {
        [SMGUtils insertObject:absNode rootPath:absNode.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
    }
    
    //5. 存储具象节点
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
+(AIAlgNode*) findLocalConNode:(NSArray*)absNodes{
    //1.  数据准备
    absNodes = ARRTOOK(absNodes);
    AIAlgNode *result = nil;
    
    //2. 筛选出conPort最短的absNode;
    AIAbsAlgNode *minNode = nil;
    for (AIAbsAlgNode *absNode in absNodes) {
        if (minNode == nil || minNode.conPorts.count > absNode.conPorts.count) {
            minNode = absNode;
        }
    }
    
    //3. 正向查找出absAlgNodes的共同关联的具象节点;
    if (minNode) {
        ///1. 循环查最小absNode的"具象路由";
        for (AIPort *checkPort in minNode.conPorts) {
            AIPointer *checkPointer = checkPort.target_p;
            
            ///2. 检查是否 同时存在所有其它absNode的"具象路由"中;
            BOOL checkSuccess = true;
            for (AIAbsAlgNode *item in absNodes) {
                if (![item isEqual:minNode]) {
                    NSArray *con_ps = [SMGUtils convertPointersFromPorts:item.conPorts];
                    if (![SMGUtils containsSub_p:checkPointer parent_ps:con_ps]) {
                        checkSuccess = false;
                        break;
                    }
                }
            }
            
            ///3. 反过来检查 "找到的具象节点" 是否也指向 "这些抽象节点";
            if (checkSuccess) {
                BOOL singleSuccess = true;
                AIAlgNode *single = [SMGUtils searchObjectForPointer:checkPointer fileName:FILENAME_Node time:cRedisNodeTime];
                if (ISOK(single, AIAlgNode.class) && single.absPorts.count == absNodes.count) {
                    NSArray *single_ps = [SMGUtils convertPointersFromPorts:single.absPorts];
                    for (AIAbsAlgNode *absNode in absNodes) {
                        if (![SMGUtils containsSub_p:absNode.pointer parent_ps:single_ps]) {
                            singleSuccess = false;
                            break;
                        }
                    }
                }
                
                ///4. 正反搜索都匹配,则重复使用;
                if (singleSuccess) {
                    result = single;
                    break;
                }
            }
        }
    }
    return result;
}

@end
