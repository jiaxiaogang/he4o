//
//  AINetUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetUtils.h"
#import "AIKVPointer.h"
#import "AIAlgNode.h"
#import "AIAbsAlgNode.h"
#import "AIPort.h"

@implementation AINetUtils

+(BOOL) checkCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource {
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSArray *arr = [SMGUtils searchObjectForFilePath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime];
    return ARRISOK(arr) && [arr containsObject:STRFORMAT(@"%@_%@",algsType,dataSource)];
}


+(void) setCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource {
    //1. 取mv分区的引用序列文件;
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime]];
    NSString *identifier = STRFORMAT(@"%@_%@",algsType,dataSource);
    if (![mArr containsObject:identifier]) {
        [mArr addObject:identifier];
        [SMGUtils insertObject:mArr rootPath:canout_p.filePath fileName:FILENAME_Default time:cRedisDefaultTime];
    }
}

//MARK:===============================================================
//MARK:                     < algTypeNodeUtils >
//MARK:===============================================================
+(AIAlgNode*) createAlgNode:(NSArray*)algsArr{
    //1. 构建抽象节点 (微信息"Alg引用序列"去重)
    AIAbsAlgNode *minNode = nil;
    NSMutableArray *absAlgNodes = [[NSMutableArray alloc] init];
    for (AIKVPointer *alg_p in ARRTOOK(algsArr)) {
        AIAbsAlgNode *absNode = [[AIAbsAlgNode alloc] init];
        absNode.pointer = [SMGUtils createPointerForNode:PATH_NET_ALG_ABS_NODE];
        absNode.value_p = alg_p;/////TODO引用序列去重给用上;
        [absAlgNodes addObject:absNode];
        
        
        //2. 筛选出conPort最短的absNode;
        if (minNode == nil || minNode.conPorts.count > absNode.conPorts.count) {
            minNode = absNode;
        }
    }
    
    //2. 查找出absAlgNodes的共同具象关联;
    if (ARRISOK(absAlgNodes) && minNode) {
        for (AIPort *checkPort in minNode.conPorts) {
            AIPointer *checkPointer = checkPort.target_p;
            for (AIAbsAlgNode *checkNode in absAlgNodes) {
                if (![checkNode isEqual:minNode]) {
                    //TODO查找出是否都contains checkP
                }
            }
        }
    }
    
    //1. 构建具象节点
    AIAlgNode *conNode = [[AIAlgNode alloc] init];
    conNode.pointer = [SMGUtils createPointerForNode:PATH_NET_ALG_NODE];
    
    
//    
//    //3. 关联
//    [self insertPointer:absNode.pointer toPorts:conNode.absPorts];
//    [self insertPointer:conNode.pointer toPorts:absNode.conPorts];
//    
//    //4. 存储抽象节点
//    [SMGUtils insertObject:absNode rootPath:absNode.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
    
    
    
    
    //5. 存储具象节点
    [SMGUtils insertObject:conNode rootPath:conNode.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
    
    return conNode;
}


+(void) insertPointer:(AIPointer*)pointer toPorts:(NSMutableArray*)ports{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        AIPort *port = [[AIPort alloc] init];
        port.target_p = pointer;
        [ports addObject:port];
    }
}

@end
