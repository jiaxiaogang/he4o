//
//  AINetUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetUtils.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "XGRedisUtil.h"
#import "NSString+Extension.h"
#import "AIAbsAlgNode.h"
#import "AINetAbsFoNode.h"
#import "AIAbsCMVNode.h"

@implementation AINetUtils

//MARK:===============================================================
//MARK:                     < CanOutput >
//MARK:===============================================================

+(BOOL) checkCanOutput:(NSString*)dataSource {
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSArray *arr = [SMGUtils searchObjectForFilePath:canout_p.filePath fileName:kFNDefault time:cRTDefault];
    return ARRISOK(arr) && [arr containsObject:STRTOOK(dataSource)];
}


+(void) setCanOutput:(NSString*)dataSource {
    //1. 取mv分区的引用序列文件;
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:canout_p.filePath fileName:kFNDefault time:cRTDefault]];
    NSString *identifier = STRTOOK(dataSource);
    if (![mArr containsObject:identifier]) {
        [mArr addObject:identifier];
        [SMGUtils insertObject:mArr rootPath:canout_p.filePath fileName:kFNDefault time:cRTDefault saveDB:true];
    }
}

//MARK:===============================================================
//MARK:                     < Other >
//MARK:===============================================================

+(BOOL) checkAllOfOut:(NSArray*)value_ps{
    if (ARRISOK(value_ps)) {
        for (AIKVPointer *value_p in value_ps) {
            if (!value_p.isOut) {
                return false;
            }
        }
        return true;
    }
    return false;
}

@end


@implementation AINetUtils (Insert)

//MARK:===============================================================
//MARK:                     < 引用插线 (外界调用,支持alg/fo/mv) >
//MARK:===============================================================

+(void) insertRefPorts_AllAlgNode:(AIPointer*)algNode_p value_ps:(NSArray*)value_ps ps:(NSArray*)ps{
    if (algNode_p && ARRISOK(value_ps)) {
        //1. 遍历value_p微信息,添加引用;
        for (AIPointer *value_p in value_ps) {
            //2. 硬盘网络时,取出refPorts -> 并二分法强度序列插入 -> 存XGWedis;
            if (!algNode_p.isMem) {
                [self insertRefPorts_HdNode:algNode_p passiveRefValue_p:value_p ps:ps];
            }else{
                //3. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
                [AINetUtils insertRefPorts_MemNode:algNode_p passiveRef_p:value_p];
            }
        }
    }
}

+(void) insertRefPorts_AllFoNode:(AIPointer*)foNode_p order_ps:(NSArray*)order_ps ps:(NSArray*)ps{
    for (AIPointer *order_p in ARRTOOK(order_ps)) {
        [self insertRefPorts_AllFoNode:foNode_p order_p:order_p ps:ps];
    }
}
+(void) insertRefPorts_AllFoNode:(AIPointer*)foNode_p order_p:(AIPointer*)order_p ps:(NSArray*)ps{
    if (!foNode_p.isMem) {
        AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:order_p fileName:kFNNode time:cRTNode];
        if (ISOK(algNode, AIAlgNodeBase.class)) {
            [AINetUtils insertPointer_Hd:foNode_p toPorts:algNode.refPorts ps:ps];
            [SMGUtils insertObject:algNode pointer:algNode.pointer fileName:kFNNode time:cRTNode];
        }
    }else{
        [self insertRefPorts_MemNode:foNode_p passiveRef_p:order_p ps:ps];
    }
}

+(void) insertRefPorts_AllMvNode:(AIPointer*)mvNode_p value_p:(AIPointer*)value_p {
    if (mvNode_p && value_p) {
        if (!mvNode_p.isMem) {
            //1. 硬盘网络时,取出refPorts -> 并二分法强度序列插入 -> 存XGWedis;
            [self insertRefPorts_HdNode:mvNode_p passiveRefValue_p:value_p ps:nil];
        }else{
            //2. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
            [AINetUtils insertRefPorts_MemNode:mvNode_p passiveRef_p:value_p];
        }
    }
}

/**
 *  MARK:--------------------硬盘节点_引用_微信息_插线 通用方法--------------------
 */
+(void) insertRefPorts_HdNode:(AIPointer*)hdNode_p passiveRefValue_p:(AIPointer*)passiveRefValue_p ps:(NSArray*)ps{
    if (ISOK(hdNode_p, AIKVPointer.class) && ISOK(passiveRefValue_p, AIKVPointer.class)) {
        NSMutableArray *refPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:passiveRefValue_p.filePath fileName:kFNRefPorts time:cRTReference]];
        [AINetUtils insertPointer_Hd:hdNode_p toPorts:refPorts ps:ps];
        [SMGUtils insertObject:refPorts rootPath:passiveRefValue_p.filePath fileName:kFNRefPorts time:cRTReference saveDB:true];
    }
}

//MARK:===============================================================
//MARK:                     < 内存插线 >
//MARK:===============================================================

+(void) insertRefPorts_MemNode:(AIPointer*)memNode_p passiveRef_p:(AIPointer*)passiveRef_p{
    [self insertRefPorts_MemNode:memNode_p passiveRef_p:passiveRef_p ps:nil];
}
+(void) insertRefPorts_MemNode:(AIPointer*)memNode_p passiveRef_p:(AIPointer*)passiveRef_p ps:(NSArray*)ps{
    if (ISOK(memNode_p, AIKVPointer.class) && ISOK(passiveRef_p, AIKVPointer.class)) {
        //1. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
        NSMutableArray *memRefPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:passiveRef_p fileName:kFNMemRefPorts]];
        [AINetUtils insertPointer_Mem:memNode_p toPorts:memRefPorts ps:ps];
        [SMGUtils insertObject:memRefPorts rootPath:passiveRef_p.filePath fileName:kFNMemRefPorts time:cRTMemPort saveDB:false];//存储
    }
}

+(void) insertAbsPorts_MemNode:(AIPointer*)abs_p con_p:(AIPointer*)con_p absNodeContent:(NSArray*)absNodeContent{
    if (ISOK(abs_p, AIKVPointer.class) && ISOK(con_p, AIKVPointer.class)) {
        NSMutableArray *memAbsPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:con_p fileName:kFNMemAbsPorts]];
        [AINetUtils insertPointer_Mem:abs_p toPorts:memAbsPorts ps:absNodeContent];
        [SMGUtils insertObject:memAbsPorts rootPath:con_p.filePath fileName:kFNMemAbsPorts time:cRTMemPort saveDB:false];//存储
    }
}

+(void) insertConPorts_MemNode:(AIPointer*)con_p abs_p:(AIPointer*)abs_p conNodeContent:(NSArray*)conNodeContent{
    if (ISOK(con_p, AIKVPointer.class) && ISOK(abs_p, AIKVPointer.class)) {
        NSMutableArray *memConPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:abs_p fileName:kFNMemConPorts]];
        [AINetUtils insertPointer_Mem:con_p toPorts:memConPorts ps:conNodeContent];
        [SMGUtils insertObject:memConPorts rootPath:abs_p.filePath fileName:kFNMemConPorts time:cRTMemPort saveDB:false];//存储
    }
}


//MARK:===============================================================
//MARK:                     < 通用 仅插线到ports >
//MARK:===============================================================

+(void) insertPointer_Hd:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        //1. 找到/新建port
        AIPort *findPort = [self findPort:pointer toPorts:ports ps:ps];
        if (!findPort) {
            return;
        }
        
        //2. 强度更新
        findPort.strong.value ++;
        
        //3. 二分插入
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            AIPort *checkPort = ARR_INDEX(ports, checkIndex);
            return [SMGUtils comparePortA:findPort portB:checkPort];
        } startIndex:0 endIndex:ports.count - 1 success:^(NSInteger index) {
            NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)findPort.target_p.pointerId);
        } failure:^(NSInteger index) {
            if (ARR_INDEXISOK(ports, index)) {
                [ports insertObject:findPort atIndex:index];
            }else{
                [ports addObject:findPort];
            }
        }];
    }
}

+(void) insertPointer_Mem:(AIPointer*)pointer toPorts:(NSMutableArray*)memPorts ps:(NSArray*)ps{
    //1. 找出/生成port
    AIPort *findPort = [self findPort:pointer toPorts:memPorts ps:ps];
    if (findPort) {
        //2. 插到第一个
        [memPorts insertObject:findPort atIndex:0];
    }
}

/**
 *  MARK:--------------------从ports中找出符合的port或者new一个 通用方法--------------------
 */
+(AIPort*) findPort:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        //1. 找出旧有;
        AIPort *findPort = nil;
        for (AIPort *port in ports) {
            if ([pointer isEqual:port.target_p]) {
                findPort = port;
                [ports removeObject:port];
                break;
            }
        }
        
        //2. 无则新建port;
        if (!findPort) {
            findPort = [[AIPort alloc] init];
            findPort.target_p = pointer;
            findPort.header = [NSString md5:[SMGUtils convertPointers2String:ps]];
        }
        
        return findPort;
    }
    return nil;
}


//MARK:===============================================================
//MARK:                     < 抽具象关联 Relate (外界调用,支持alg/fo) >
//MARK:===============================================================

+(void) relateAlgAbs:(AIAbsAlgNode*)absNode conNodes:(NSArray*)conNodes{
    if (ISOK(absNode, AIAbsAlgNode.class) && ARRISOK(conNodes)) {
        [self relateGeneralAbs:absNode absConPorts:absNode.conPorts conNodes:conNodes contentPsBlock:^NSArray *(AIAlgNodeBase *node) {
            if (ISOK(node, AIAlgNodeBase.class)) {
                return node.content_ps;
            }
            return nil;
        }];
    }
}

+(void) relateFoAbs:(AINetAbsFoNode*)absNode conNodes:(NSArray*)conNodes{
    if (ISOK(absNode, AINetAbsFoNode.class) && ARRISOK(conNodes)) {
        [self relateGeneralAbs:absNode absConPorts:absNode.conPorts conNodes:conNodes contentPsBlock:^NSArray *(AIFoNodeBase *node) {
            if (ISOK(node, AIFoNodeBase.class)) {
                return node.orders_kvp;
            }
            return nil;
        }];
    }
}

+(void) relateMvAbs:(AIAbsCMVNode*)absNode conNodes:(NSArray*)conNodes{
    if (ISOK(absNode, AIAbsCMVNode.class) && ARRISOK(conNodes)) {
        [self relateGeneralAbs:absNode absConPorts:absNode.conPorts conNodes:conNodes contentPsBlock:^NSArray *(AICMVNodeBase *node) {
            return nil;
        }];
    }
}

/**
 *  MARK:--------------------抽具象关联通用方法--------------------
 *  @param absConPorts : notnull
 */
+(void) relateGeneralAbs:(AINodeBase*)absNode absConPorts:(NSMutableArray*)absConPorts conNodes:(NSArray*)conNodes contentPsBlock:(NSArray*(^)(id))contentPsBlock{
    if (ISOK(absNode, AIAbsCMVNode.class) && ARRISOK(conNodes)) {
        //1. 具象节点的 关联&存储
        for (AINodeBase *conNode in conNodes) {
            NSArray *absContent_ps = contentPsBlock(absNode);
            NSArray *conContent_ps = contentPsBlock(conNode);
            if (!conNode.pointer.isMem) {
                //2. hd_具象节点插"抽象端口";
                [AINetUtils insertPointer_Hd:absNode.pointer toPorts:conNode.absPorts ps:absContent_ps];
                //3. hd_抽象节点插"具象端口";
                [AINetUtils insertPointer_Hd:conNode.pointer toPorts:absConPorts ps:conContent_ps];
                //4. hd_存储
                [SMGUtils insertObject:conNode pointer:conNode.pointer fileName:kFNNode time:cRTNode];
            }else{
                //5. mem_抽象插到具象上
                [self insertAbsPorts_MemNode:absNode.pointer con_p:conNode.pointer absNodeContent:absContent_ps];
                //6. mem_具象插到抽象上
                [self insertConPorts_MemNode:conNode.pointer abs_p:absNode.pointer conNodeContent:conContent_ps];
            }
        }
        
        //7. 抽象节点的 关联&存储
        [SMGUtils insertObject:absNode pointer:absNode.pointer fileName:kFNNode_All(absNode.pointer.isMem) time:cRTNode_All(absNode.pointer.isMem)];
    }
}

@end


//MARK:===============================================================
//MARK:                     < 转移 >
//MARK:===============================================================
@implementation AINetUtils (Move)

+(id) move2HdNodeFromMemNode_Alg:(AINodeBase*)memNode {
    return [self move2HdNodeFromMemNode_General:memNode insertRefPortsBlock:^(AIAlgNodeBase *hdNode) {
        if (ISOK(hdNode, AIAlgNodeBase.class)) {
            [AINetUtils insertRefPorts_AllAlgNode:hdNode.pointer value_ps:hdNode.content_ps ps:hdNode.content_ps];
        }
    }];
}

+(id) move2HdNodeFromMemNode_Fo:(AINodeBase*)memNode {
    return [self move2HdNodeFromMemNode_General:memNode insertRefPortsBlock:^(AIFoNodeBase *hdNode) {
        if (ISOK(hdNode, AIFoNodeBase.class)) {
            [AINetUtils insertRefPorts_AllFoNode:hdNode.pointer order_ps:hdNode.orders_kvp ps:hdNode.orders_kvp];
        }
    }];
}

/**
 *  MARK:--------------------转移内存节点为硬盘节点--------------------
 *  @param insertRefPortsBlock : 引用插线方法 notnull;
 */
+(id) move2HdNodeFromMemNode_General:(AINodeBase*)memNode insertRefPortsBlock:(void(^)(id hdNode))insertRefPortsBlock{
    if (memNode && memNode.pointer.isMem) {
        AINodeBase *hdNode = [SMGUtils searchObjectForPointer:memNode.pointer fileName:kFNNode time:cRTNode];
        ///2. 转移_hdNet不存在,才转移;
        if (!hdNode) {
            hdNode = memNode;
            hdNode.pointer.isMem = false;
            
            ///3. 转移_微信息引用序列;
            insertRefPortsBlock(hdNode);
            
            ///4. 转移_存储到hdNet
            [SMGUtils insertNode:hdNode];
        }
        return hdNode;
    }
    return memNode;
}

@end


///**
// *  MARK:--------------------插线到ports (分文件优化)--------------------
// *  @param pointerFileName : 指针序列文件名,如kFNReference_ByPointer
// *  @param portFileName : 强度序列文件名,如kFNReference_ByPort
// *
// *  1. 各种神经元中只保留"指针"和"类型";
// *  2. 其它absPorts,conPorts,refPorts都使用单独文件的方式;
// *  3. 暂不使用 (未完成)
// */
//-(void) insertPointer:(AIKVPointer*)node_p target_p:(AIKVPointer*)target_p difStrong:(int)difStrong pointerFileName:(NSString*)pointerFileName portFileName:(NSString*)portFileName{
////    //1. 数据检查
////    if (!ISOK(target_p, AIKVPointer.class) || !ISOK(node_p, AIKVPointer.class) || difStrong == 0) {
////        return;
////    }
////
////    //2. 取identifier分区的引用序列文件;
////    NSMutableArray *mArrByPointer = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:node_p fileName:pointerFileName time:cRTPort]];
////    NSMutableArray *mArrByPort = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:node_p fileName:portFileName time:cRTPort]];
////
////    //3. 找到旧的mArrByPointer;
////    __block AIPort *oldPort = nil;
////    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
////        AIPort *checkPort = ARR_INDEX(mArrByPointer, checkIndex);
////        return [SMGUtils comparePointerA:target_p pointerB:checkPort.target_p];
////    } startIndex:0 endIndex:mArrByPointer.count - 1 success:^(NSInteger index) {
////        AIPort *findPort = ARR_INDEX(mArrByPointer, index);
////        if (ISOK(findPort, AIPort.class)) {
////            oldPort = findPort;
////        }
////    } failure:^(NSInteger index) {
////        oldPort = [[AIPort alloc] init];
////        oldPort.target_p = target_p;
////        oldPort.strong.value = 1;
////        if (ARR_INDEXISOK(mArrByPointer, index)) {
////            [mArrByPointer insertObject:oldPort atIndex:index];
////        }else{
////            [mArrByPointer addObject:oldPort];
////        }
////        [SMGUtils insertObject:mArrByPointer rootPath:filePath fileName:kFNReference_ByPointer time:cRTReference];
////    }];
////
////    //4. 搜索旧port并去掉_mArrByPort;
////    if (oldPort == nil) {
////        NSLog(@"BUG!!!未找到,也未生成新的oldPort!!!");
////        return;
////    }
////    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
////        AIPort *checkPort = ARR_INDEX(mArrByPort, checkIndex);
////        return [SMGUtils comparePortA:oldPort portB:checkPort];
////    } startIndex:0 endIndex:mArrByPort.count - 1 success:^(NSInteger index) {
////        AIPort *findPort = ARR_INDEX(mArrByPort, index);
////        if (ISOK(findPort, AIPort.class)) {
////            [mArrByPort removeObjectAtIndex:index];
////        }
////    } failure:nil];
////
////    //5. 生成新port
////    oldPort.strong.value += difStrong;
////    AIPort *newPort = oldPort;
////
////    //6. 将新port插入_mArrByPort
////    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
////        AIPort *checkPort = ARR_INDEX(mArrByPort, checkIndex);
////        return [SMGUtils comparePortA:newPort portB:checkPort];
////    } startIndex:0 endIndex:mArrByPort.count - 1 success:^(NSInteger index) {
////        NSLog(@"警告!!! bug:在第二序列的ports中发现了两次port目标___pointerId为:%ld",(long)newPort.target_p.pointerId);
////    } failure:^(NSInteger index) {
////        if (ARR_INDEXISOK(mArrByPort, index)) {
////            [mArrByPort insertObject:newPort atIndex:index];
////        }else{
////            [mArrByPort addObject:newPort];
////        }
////        [SMGUtils insertObject:mArrByPort rootPath:filePath fileName:kFNReference_ByPort time:cRTReference];
////    }];
//}
