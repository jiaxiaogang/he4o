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

+(AIAlgNode*) createAlgNode:(NSArray*)algsArr isOut:(BOOL)isOut saveDB:(BOOL)saveDB{
    //1. 数据
    algsArr = ARRTOOK(algsArr);
    
    //2. 构建具象节点 (优先用本地已有,否则new)
    AIAlgNode *conNode = [[AIAlgNode alloc] init];
    conNode.pointer = [SMGUtils createPointer:PATH_NET_ALG_NODE algsType:@"" dataSource:@"" isOut:isOut];
    
    //3. 指定value_ps
    conNode.content_ps = [SMGUtils sortPointers:algsArr];
 
    //4. value.refPorts (更新引用序列)
    [AINetUtils insertPointer:conNode.pointer toRefPortsByValues:conNode.content_ps ps:conNode.content_ps saveDB:saveDB];
    
    //5. 存储
    [SMGUtils insertObject:conNode rootPath:conNode.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime_All(saveDB) saveDB:saveDB];
    
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

+(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)algSames conAlgs:(NSArray*)conAlgs saveDB:(BOOL)saveDB{
    if (ARRISOK(algSames) && ARRISOK(conAlgs)) {
        //1. 数据准备
        algSames = ARRTOOK(algSames);
        NSArray *sortSames = ARRTOOK([SMGUtils sortPointers:algSames]);
        NSString *samesStr = [SMGUtils convertPointers2String:sortSames];
        NSString *samesMd5 = STRTOOK([NSString md5:samesStr]);
        
        //2. 判断algA.absPorts和absB.absPorts中的header,是否已存在algSames的抽象节点;
        AIAbsAlgNode *findAbsNode = nil;
        NSMutableArray *allAbsPorts = [[NSMutableArray alloc] init];
        for (AIAlgNode *item in conAlgs) {
            [allAbsPorts addObjectsFromArray:item.absPorts];
        }
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
            findAbsNode.content_ps = sortSames;
            
            ///1. value.refPorts (更新微信息的引用序列)
            [AINetUtils insertPointer:findAbsNode.pointer toRefPortsByValues:findAbsNode.content_ps ps:findAbsNode.content_ps saveDB:saveDB];
        }
        
        //4. 祖母的嵌套
        for (AIAlgNode *item in conAlgs) {
            ///1. 可替换时,逐个进行替换; (比如cLess/cGreater时,就不可替换)
            if ([SMGUtils containsSub_ps:algSames parent_ps:item.content_ps]) {
                NSMutableArray *newValue_ps = [SMGUtils removeSub_ps:algSames parent_ps:[[NSMutableArray alloc] initWithArray:item.content_ps]];
                [newValue_ps addObject:findAbsNode.pointer];
                item.content_ps = [SMGUtils sortPointers:newValue_ps];
            }
        }
        
        //5. 关联 & 存储
        [AINetUtils relateAbs:findAbsNode conNodes:conAlgs saveDB:saveDB];
        return findAbsNode;
    }
    return nil;
}

@end
