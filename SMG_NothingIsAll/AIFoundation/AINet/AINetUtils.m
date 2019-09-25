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
                [self insertRefPorts_HdNode:algNode_p passiveRefValue_p:value_p ps:ps difStrong:1];
            }else{
                //3. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
                [AINetUtils insertRefPorts_MemNode:algNode_p passiveRef_p:value_p ps:nil difStrong:1];
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
        [self insertRefPorts_MemNode:foNode_p passiveRef_p:order_p ps:ps difStrong:1];
    }
    if (foNode_p.isMem != order_p.isMem) {
        NSLog(@"WARN!!! alg被fo引用时,内存状态各异; foIsMem:%d",foNode_p.isMem);
    }
}

+(void) insertRefPorts_AllMvNode:(AIPointer*)mvNode_p value_p:(AIPointer*)value_p difStrong:(NSInteger)difStrong{
    if (mvNode_p && value_p) {
        if (!mvNode_p.isMem) {
            //1. 硬盘网络时,取出refPorts -> 并二分法强度序列插入 -> 存XGWedis;
            [self insertRefPorts_HdNode:mvNode_p passiveRefValue_p:value_p ps:nil difStrong:difStrong];
        }else{
            //2. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
            [AINetUtils insertRefPorts_MemNode:mvNode_p passiveRef_p:value_p ps:nil difStrong:difStrong];
        }
    }
}

/**
 *  MARK:--------------------硬盘节点_引用_微信息_插线 通用方法--------------------
 */
+(void) insertRefPorts_HdNode:(AIPointer*)hdNode_p passiveRefValue_p:(AIPointer*)passiveRefValue_p ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    if (ISOK(hdNode_p, AIKVPointer.class) && ISOK(passiveRefValue_p, AIKVPointer.class)) {
        NSMutableArray *refPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForFilePath:passiveRefValue_p.filePath fileName:kFNRefPorts time:cRTReference]];
        [AINetUtils insertPointer_Hd:hdNode_p toPorts:refPorts ps:ps difStrong:difStrong];
        [SMGUtils insertObject:refPorts rootPath:passiveRefValue_p.filePath fileName:kFNRefPorts time:cRTReference saveDB:true];
    }
}

//MARK:===============================================================
//MARK:                     < 内存插线 >
//MARK:===============================================================
+(void) insertRefPorts_MemNode:(AIPointer*)memNode_p passiveRef_p:(AIPointer*)passiveRef_p ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    if (ISOK(memNode_p, AIKVPointer.class) && ISOK(passiveRef_p, AIKVPointer.class)) {
        //1. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
        NSMutableArray *memRefPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:passiveRef_p fileName:kFNMemRefPorts]];
        [AINetUtils insertPointer_Mem:memNode_p toPorts:memRefPorts ps:ps difStrong:difStrong];
        [SMGUtils insertObject:memRefPorts rootPath:passiveRef_p.filePath fileName:kFNMemRefPorts time:cRTMemPort saveDB:false];//存储
    }
}

+(void) insertAbsPorts_MemNode:(AIPointer*)abs_p con_p:(AIPointer*)con_p absNodeContent:(NSArray*)absNodeContent{
    if (ISOK(abs_p, AIKVPointer.class) && ISOK(con_p, AIKVPointer.class)) {
        NSMutableArray *memAbsPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:con_p fileName:kFNMemAbsPorts time:cRTMemPort]];
        [AINetUtils insertPointer_Mem:abs_p toPorts:memAbsPorts ps:absNodeContent difStrong:1];
        [SMGUtils insertObject:memAbsPorts rootPath:con_p.filePath fileName:kFNMemAbsPorts time:cRTMemPort saveDB:false];//存储
    }
}

+(void) insertConPorts_MemNode:(AIPointer*)con_p abs_p:(AIPointer*)abs_p conNodeContent:(NSArray*)conNodeContent{
    if (ISOK(con_p, AIKVPointer.class) && ISOK(abs_p, AIKVPointer.class)) {
        NSMutableArray *memConPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:abs_p fileName:kFNMemConPorts]];
        [AINetUtils insertPointer_Mem:con_p toPorts:memConPorts ps:conNodeContent difStrong:1];
        [SMGUtils insertObject:memConPorts rootPath:abs_p.filePath fileName:kFNMemConPorts time:cRTMemPort saveDB:false];//存储
    }
}


//MARK:===============================================================
//MARK:                     < 通用 仅插线到ports >
//MARK:===============================================================
+(void) insertPointer_Hd:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps{
    [self insertPointer_Hd:pointer toPorts:ports ps:ps difStrong:1];
}
+(void) insertPointer_Hd:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        //1. 找到/新建port
        AIPort *findPort = [self findPort:pointer toPorts:ports ps:ps];
        if (!findPort) {
            return;
        }
        
        //2. 强度更新
        findPort.strong.value += difStrong;
        
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

+(void) insertPointer_Mem:(AIPointer*)pointer toPorts:(NSMutableArray*)memPorts ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    //1. 找出/生成port
    AIPort *findPort = [self findPort:pointer toPorts:memPorts ps:ps difStrong:difStrong];
    if (findPort) {
        //2. 插到第一个
        [memPorts insertObject:findPort atIndex:0];
    }
}

/**
 *  MARK:--------------------从ports中找出符合的port或者new一个 通用方法--------------------
 */
+(AIPort*) findPort:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps {
    return [self findPort:pointer toPorts:ports ps:ps difStrong:1];
}
+(AIPort*) findPort:(AIPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
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
        
        //3. difStrong
        findPort.strong.value += difStrong;
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
                return node.content_ps;
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
    if (ISOK(absNode, AINodeBase.class)) {
        //1. 具象节点的 关联&存储
        conNodes = ARRTOOK(conNodes);
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
        [SMGUtils insertNode:absNode];
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
            [AINetUtils insertRefPorts_AllFoNode:hdNode.pointer order_ps:hdNode.content_ps ps:hdNode.content_ps];
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
