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
#import "ThinkingUtils.h"
#import "AINetIndex.h"

@implementation AINetUtils

//MARK:===============================================================
//MARK:                     < CanOutput >
//MARK:===============================================================

+(BOOL) checkCanOutput:(NSString*)identify {
    AIKVPointer *canout_p = [SMGUtils createPointerForCerebelCanOut];
    NSArray *arr = [SMGUtils searchObjectForFilePath:canout_p.filePath fileName:kFNDefault time:cRTDefault];
    return ARRISOK(arr) && [arr containsObject:STRTOOK(identify)];
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

+(BOOL) checkAllOfOut:(NSArray*)conAlgs{
    if (ARRISOK(conAlgs)) {
        for (AIAbsAlgNode *checkNode in conAlgs) {
            if (!checkNode.pointer.isOut) {
                return false;
            }
        }
        return true;
    }
    return false;
}

+(NSInteger) getConMaxStrong:(AINodeBase*)node{
    NSInteger result = 1;
    if (node) {
        AIPort *firstPort = ARR_INDEX([self conPorts_All:node], 0);
        if (firstPort) result = firstPort.strong.value + 1;
    }
    return result;
}

+(NSInteger) getMaxStrong:(NSArray*)ports{
    NSInteger result = 1;
    ports = ARRTOOK(ports);
    for (AIPort *port in ports) {
        if (port.strong.value > result) {
            result = port.strong.value;
        }
    }
    return result;
}

/**
 *  MARK:--------------------获取absNode被conNode指向的强度--------------------
 */
+(NSInteger) getStrong:(AINodeBase*)absNode atConNode:(AINodeBase*)conNode type:(AnalogyType)type{
    if (absNode && conNode) {
        NSArray *absPorts = [AINetUtils absPorts_All:conNode type:type];
        AIPort *absPort = [AINetUtils findPort:absNode.pointer fromPorts:absPorts];
        if (absPort) return absPort.strong.value;
    }
    return 0;
}

/**
 *  MARK:--------------------是否虚mv--------------------
 *  @desc 虚mv判断标准 (迫切度是否为0);
 */
+(BOOL) isVirtualMv:(AIKVPointer*)mv_p{
    AICMVNodeBase *mv = [SMGUtils searchNode:mv_p];
    if (mv) {
        NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mv.urgentTo_p]) integerValue];
        return urgentTo == 0;
    }
    return true;
}

/**
 *  MARK:--------------------获取mv的delta--------------------
 */
+(NSInteger) getDeltaFromMv:(AIKVPointer*)mv_p{
    AICMVNodeBase *mv = [SMGUtils searchNode:mv_p];
    if (mv) {
        return [NUMTOOK([AINetIndex getData:mv.delta_p]) integerValue];
    }
    return 0;
}

@end


@implementation AINetUtils (Insert)

//MARK:===============================================================
//MARK:                     < 引用插线 (外界调用,支持alg/fo/mv) >
//MARK:===============================================================

/**
 *  MARK:--------------------概念_引用_微信息--------------------
 *  @version
 *      2020.08.05: content_ps添加去重功能,避免同一个"分"信息,被多次报引用强度叠加;
 */
+(void) insertRefPorts_AllAlgNode:(AIKVPointer*)algNode_p content_ps:(NSArray*)content_ps difStrong:(NSInteger)difStrong{
    content_ps = [SMGUtils removeRepeat:content_ps];
    if (algNode_p && ARRISOK(content_ps)) {
        NSArray *sort_ps = [SMGUtils sortPointers:content_ps];
        //1. 遍历value_p微信息,添加引用;
        for (AIPointer *value_p in content_ps) {
            //2. 硬盘网络时,取出refPorts -> 并二分法强度序列插入 -> 存XGWedis;
            if (!algNode_p.isMem) {
                [self insertRefPorts_HdNode:algNode_p passiveRefValue_p:value_p ps:sort_ps difStrong:difStrong];
            }else{
                //3. 内存网络时,取出memRefPorts -> 插入首位 -> 存XGRedis;
                [AINetUtils insertRefPorts_MemNode:algNode_p passiveRef_p:value_p ps:nil difStrong:difStrong];
            }
        }
    }
}

/**
 *  MARK:--------------------时序_引用_概念--------------------
 *  @version
 *      2020.08.05: order_ps添加去重功能,避免同一个"分"信息,被多次报引用强度叠加;
 */
+(void) insertRefPorts_AllFoNode:(AIKVPointer*)foNode_p order_ps:(NSArray*)order_ps ps:(NSArray*)ps {
    order_ps = [SMGUtils removeRepeat:order_ps];
    for (AIPointer *order_p in ARRTOOK(order_ps)) {
        [self insertRefPorts_AllFoNode:foNode_p order_p:order_p ps:ps difStrong:1];
    }
}
+(void) insertRefPorts_AllFoNode:(AIKVPointer*)foNode_p order_ps:(NSArray*)order_ps ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    order_ps = [SMGUtils removeRepeat:order_ps];
    for (AIPointer *order_p in ARRTOOK(order_ps)) {
        [self insertRefPorts_AllFoNode:foNode_p order_p:order_p ps:ps difStrong:difStrong];
    }
}
+(void) insertRefPorts_AllFoNode:(AIKVPointer*)foNode_p order_p:(AIPointer*)order_p ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    if (!foNode_p.isMem) {
        AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:order_p fileName:kFNNode time:cRTNode];
        if (ISOK(algNode, AIAlgNodeBase.class)) {
            [AINetUtils insertPointer_Hd:foNode_p toPorts:algNode.refPorts ps:ps difStrong:difStrong];
            [SMGUtils insertObject:algNode pointer:algNode.pointer fileName:kFNNode time:cRTNode];
        }
    }else{
        [self insertRefPorts_MemNode:foNode_p passiveRef_p:order_p ps:ps difStrong:difStrong];
    }
    if (foNode_p.isMem != order_p.isMem) {
        WLog(@"alg被fo引用时,内存状态各异; foIsMem:%d",foNode_p.isMem);
    }
}

+(void) insertRefPorts_AllMvNode:(AIKVPointer*)mvNode_p value_p:(AIPointer*)value_p difStrong:(NSInteger)difStrong{
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
+(void) insertRefPorts_HdNode:(AIKVPointer*)hdNode_p passiveRefValue_p:(AIPointer*)passiveRefValue_p ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
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
        NSMutableArray *memRefPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:passiveRef_p fileName:kFNMemRefPorts time:cRTMemPort]];
        [AINetUtils insertPointer_Mem:memNode_p toPorts:memRefPorts ps:ps difStrong:difStrong];
        [SMGUtils insertObject:memRefPorts rootPath:passiveRef_p.filePath fileName:kFNMemRefPorts time:cRTMemPort saveDB:false];//存储
    }
}

//abs插入con.absPorts;
+(void) insertAbsPorts_MemNode:(AIPointer*)abs_p con_p:(AIPointer*)con_p absNodeContent:(NSArray*)absNodeContent difStrong:(NSInteger)difStrong{
    if (ISOK(abs_p, AIKVPointer.class) && ISOK(con_p, AIKVPointer.class)) {
        NSMutableArray *memAbsPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:con_p fileName:kFNMemAbsPorts time:cRTMemPort]];
        [AINetUtils insertPointer_Mem:abs_p toPorts:memAbsPorts ps:absNodeContent difStrong:difStrong];
        [SMGUtils insertObject:memAbsPorts rootPath:con_p.filePath fileName:kFNMemAbsPorts time:cRTMemPort saveDB:false];//存储
    }
}

//con插入abs.conPorts;
+(void) insertConPorts_MemNode:(AIPointer*)con_p abs_p:(AIPointer*)abs_p conNodeContent:(NSArray*)conNodeContent difStrong:(NSInteger)difStrong{
    if (ISOK(con_p, AIKVPointer.class) && ISOK(abs_p, AIKVPointer.class)) {
        NSMutableArray *memConPorts = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:abs_p fileName:kFNMemConPorts time:cRTMemPort]];
        [AINetUtils insertPointer_Mem:con_p toPorts:memConPorts ps:conNodeContent difStrong:difStrong];
        [SMGUtils insertObject:memConPorts rootPath:abs_p.filePath fileName:kFNMemConPorts time:cRTMemPort saveDB:false];//存储
    }
}

//sub插入base.subPorts;
+(void) insertDiffSubPorts_MemNode:(AIKVPointer*)sub_p base_p:(AIKVPointer*)base_p subContent:(NSArray*)subContent difStrong:(NSInteger)difStrong{
    if (ISOK(sub_p, AIKVPointer.class) && ISOK(base_p, AIKVPointer.class)) {
        NSMutableArray *ports = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:base_p fileName:kFNMemDSPorts time:cRTMemPort]];
        [AINetUtils insertPointer_Mem:sub_p toPorts:ports ps:subContent difStrong:difStrong];
        [SMGUtils insertObject:ports rootPath:base_p.filePath fileName:kFNMemDSPorts time:cRTMemPort saveDB:false];//存储
    }
}

//base插入sub.basePorts;
+(void) insertDiffBasePorts_MemNode:(AIKVPointer*)base_p sub_p:(AIKVPointer*)sub_p baseContent:(NSArray*)baseContent difStrong:(NSInteger)difStrong{
    if (ISOK(base_p, AIKVPointer.class) && ISOK(sub_p, AIKVPointer.class)) {
        NSMutableArray *ports = [[NSMutableArray alloc] initWithArray:[SMGUtils searchObjectForPointer:sub_p fileName:kFNMemDBPorts time:cRTMemPort]];
        [AINetUtils insertPointer_Mem:base_p toPorts:ports ps:baseContent difStrong:difStrong];
        [SMGUtils insertObject:ports rootPath:sub_p.filePath fileName:kFNMemDBPorts time:cRTMemPort saveDB:false];//存储
    }
}


//MARK:===============================================================
//MARK:                     < 通用 仅插线到ports >
//MARK:===============================================================
+(void) insertPointer_Hd:(AIKVPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps{
    [self insertPointer_Hd:pointer toPorts:ports ps:ps difStrong:1];
}
+(void) insertPointer_Hd:(AIKVPointer*)pointer toPorts:(NSMutableArray*)ports ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    if (ISOK(pointer, AIPointer.class) && ISOK(ports, NSMutableArray.class)) {
        //1. 找到/新建port
        AIPort *findPort = [self findPort:pointer fromPorts:ports ps:ps];
        if (!findPort) {
            return;
        }
        
        //TODOTOMORROW: 对强度>100的打断点,重新训练,查20151-BUG9方向索引强度异常的问题;
        if (difStrong > 1 && [kPN_CMV_NODE isEqualToString:pointer.folderName] && findPort.strong.value > 1) {
            NSLog(@"------引用强度异常更新 %@_%ld: %ld + %ld = %ld",findPort.target_p.folderName,findPort.target_p.pointerId,difStrong,findPort.strong.value,findPort.strong.value + difStrong);
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

+(void) insertPointer_Mem:(AIKVPointer*)pointer toPorts:(NSMutableArray*)memPorts ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    //1. 找出/生成port
    AIPort *findPort = [self findPort:pointer fromPorts:memPorts ps:ps];
    if (findPort) {
        //2. 强度更新
        findPort.strong.value += difStrong;
        
        //3. 插到第一个
        [memPorts insertObject:findPort atIndex:0];
    }
}

//MARK:===============================================================
//MARK:                     < 找出port >
//MARK:===============================================================

//找出port (并从ports中移除 & 无则新建);
+(AIPort*) findPort:(AIKVPointer*)pointer fromPorts:(NSMutableArray*)fromPorts ps:(NSArray*)ps{
    if (ISOK(pointer, AIPointer.class) && ISOK(fromPorts, NSMutableArray.class)) {
        //1. 找出旧有;
        AIPort *findPort = [self findPort:pointer fromPorts:fromPorts];
        if (findPort) [fromPorts removeObject:findPort];
        
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
//找出port
+(AIPort*) findPort:(AIKVPointer*)pointer fromPorts:(NSArray*)fromPorts{
    fromPorts = ARRTOOK(fromPorts);
    for (AIPort *port in fromPorts) {
        if ([port.target_p isEqual:pointer]) {
            return port;
        }
    }
    return nil;
}


//MARK:===============================================================
//MARK:                     < 抽具象关联 Relate (外界调用,支持alg/fo) >
//MARK:===============================================================
+(void) relateAlgAbs:(AIAbsAlgNode*)absNode conNodes:(NSArray*)conNodes isNew:(BOOL)isNew{
    [self relateGeneralAbs:absNode absConPorts:absNode.conPorts conNodes:conNodes isNew:isNew difStrong:1];
}
+(void) relateFoAbs:(AINetAbsFoNode*)absNode conNodes:(NSArray*)conNodes isNew:(BOOL)isNew{
    [self relateGeneralAbs:absNode absConPorts:absNode.conPorts conNodes:conNodes isNew:isNew difStrong:1];
}
+(void) relateMvAbs:(AIAbsCMVNode*)absNode conNodes:(NSArray*)conNodes isNew:(BOOL)isNew{
    [self relateGeneralAbs:absNode absConPorts:absNode.conPorts conNodes:conNodes isNew:isNew difStrong:1];
}

+(void) relateFoAbs:(AINetAbsFoNode*)absNode conNodes:(NSArray*)conNodes isNew:(BOOL)isNew strongPorts:(NSArray*)strongPorts{
    NSInteger difStrong = [self getMaxStrong:strongPorts];
    [self relateGeneralAbs:absNode absConPorts:absNode.conPorts conNodes:conNodes isNew:isNew difStrong:difStrong];
}

/**
 *  MARK:--------------------抽具象关联通用方法--------------------
 *  @param absConPorts : notnull
 *  @param isNew : absNode是否为新构建;
 *  @version
 *      2021.01.11: 当SP节点时,difStrong为1 (参考22032);
 */
+(void) relateGeneralAbs:(AINodeBase*)absNode absConPorts:(NSMutableArray*)absConPorts conNodes:(NSArray*)conNodes isNew:(BOOL)isNew difStrong:(NSInteger)difStrong{
    if (ISOK(absNode, AINodeBase.class)) {
        //1. 具象节点的 关联&存储
        conNodes = ARRTOOK(conNodes);
        for (AINodeBase *conNode in conNodes) {
            //1. con与abs必须不同;
            if ([absNode isEqual:conNode]) continue;
            NSArray *absContent_ps = absNode.content_ps;
            NSArray *conContent_ps = conNode.content_ps;
            
            //2. 计算disStrong (默认为1 & 当新节点且不是SP时从具象取maxStrong);
            AnalogyType type = absNode.pointer.type;//DS2ATType(absNode.pit.ds);
            if (isNew && type != ATSub && type != ATPlus) {
                difStrong = [self getConMaxStrong:conNode];
            }
            if (!conNode.pointer.isMem) {
                //2. hd_具象节点插"抽象端口";
                [AINetUtils insertPointer_Hd:absNode.pointer toPorts:conNode.absPorts ps:absContent_ps difStrong:difStrong];
                //3. hd_抽象节点插"具象端口";
                [AINetUtils insertPointer_Hd:conNode.pointer toPorts:absConPorts ps:conContent_ps difStrong:difStrong];
                //4. hd_存储
                [SMGUtils insertObject:conNode pointer:conNode.pointer fileName:kFNNode time:cRTNode];
            }else{
                //5. mem_抽象插到具象上
                [self insertAbsPorts_MemNode:absNode.pointer con_p:conNode.pointer absNodeContent:absContent_ps difStrong:difStrong];
                //6. mem_具象插到抽象上
                [self insertConPorts_MemNode:conNode.pointer abs_p:absNode.pointer conNodeContent:conContent_ps difStrong:difStrong];
            }
        }
        
        //7. 抽象节点的 关联&存储
        [SMGUtils insertNode:absNode];
    }
}

+(void) relateFo:(AIFoNodeBase*)foNode mv:(AICMVNodeBase*)mvNode{
    if (foNode && mvNode) {
        //1. 互指向
        mvNode.foNode_p = foNode.pointer;
        foNode.cmvNode_p = mvNode.pointer;
        
        //2. 存储foNode & cmvNode
        [SMGUtils insertNode:mvNode];
        [SMGUtils insertNode:foNode];
    }
}

/**
 *  MARK:--------------------Diff嵌套关联--------------------
 *  @desc 构建虚mv时序时,虚mv是解决实mv的,所以protoFo要嵌套在matchFo之下;
 *  @param strongPorts : 用来取difStrong的节点集
 *              1. 当外类比时传入参与外类比的ports,difStrong=MaxStrong;
 *              2. 否则传空即可,difStrong=1;
 */
+(void) relateDiff:(AIFoNodeBase*)subNode baseNode:(AIFoNodeBase*)baseNode strongPorts:(NSArray*)strongPorts{
    //1. 数据准备;
    if (!baseNode || !subNode) return;
    NSInteger difStrong = [self getMaxStrong:strongPorts];
    
    //2. 关联&存储
    if (!baseNode.pointer.isMem) {
        //2. hd_具象节点插"抽象端口";
        [AINetUtils insertPointer_Hd:subNode.pointer toPorts:baseNode.diffSubPorts ps:subNode.content_ps difStrong:difStrong];
        //3. hd_抽象节点插"具象端口";
        [AINetUtils insertPointer_Hd:baseNode.pointer toPorts:subNode.diffBasePorts ps:baseNode.content_ps difStrong:difStrong];
        //4. hd_存储
        [SMGUtils insertNode:baseNode];
        [SMGUtils insertNode:subNode];
    }else{
        //5. 内存插端口;
        [self insertDiffBasePorts_MemNode:baseNode.pointer sub_p:subNode.pointer baseContent:baseNode.content_ps difStrong:difStrong];
        [self insertDiffSubPorts_MemNode:subNode.pointer base_p:baseNode.pointer subContent:subNode.content_ps difStrong:difStrong];
    }
}

@end


//MARK:===============================================================
//MARK:                     < 转移 >
//MARK:===============================================================
@implementation AINetUtils (Move)

+(NSArray*) move2Hd4Alg_ps:(NSArray*)alg_ps{
    //1. 数据检查
    NSMutableArray *result = [[NSMutableArray alloc] init];
    alg_ps = ARRTOOK(alg_ps);
    
    //2. 循环检查;
    for (AIKVPointer *item_p in alg_ps) {
        //a. 内存则迁移,再添加;
        if (item_p.isMem) {
            AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item_p];
            itemAlg = [AINetUtils move2HdNodeFromMemNode_Alg:itemAlg];
            if (itemAlg) [result addObject:itemAlg.pointer];
        }else{
            //b. 不在内存直接添加;
            [result addObject:item_p];
        }
    }
    return result;
}

+(id) move2HdNodeFromMemNode_Alg:(AINodeBase*)memNode {
    return [self move2HdNodeFromMemNode_General:memNode insertRefPortsBlock:^(AIAlgNodeBase *hdNode) {
        if (ISOK(hdNode, AIAlgNodeBase.class)) {
            [AINetUtils insertRefPorts_AllAlgNode:hdNode.pointer content_ps:hdNode.content_ps difStrong:1];
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

//MARK:===============================================================
//MARK:                     < Port >
//MARK:===============================================================
@implementation AINetUtils (Port)

+(NSArray*) absPorts_All:(AINodeBase*)node{
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (ISOK(node, AINodeBase.class)) {
        [allPorts addObjectsFromArray:node.absPorts];
        [allPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:node.pointer fileName:kFNMemAbsPorts time:cRTMemPort]];
    }
    return allPorts;
}
+(NSArray*) absPorts_All_Normal:(AINodeBase*)node{
    NSArray *allPorts = [self absPorts_All:node];
    return [SMGUtils filterPorts_Normal:allPorts];
}
+(NSArray*) absPorts_All:(AINodeBase*)node type:(AnalogyType)type{
    return [self absPorts_All:node havTypes:@[@(type)] noTypes:nil];
}
+(NSArray*) absPorts_All:(AINodeBase*)node havTypes:(NSArray*)havTypes noTypes:(NSArray*)noTypes{
    NSArray *allPorts = [self absPorts_All:node];
    return [SMGUtils filterPorts:allPorts havTypes:havTypes noTypes:noTypes];
}

+(NSArray*) conPorts_All:(AINodeBase*)node{
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (ISOK(node, AIAbsAlgNode.class)) {
        [allPorts addObjectsFromArray:((AIAbsAlgNode*)node).conPorts];
    }else if (ISOK(node, AINetAbsFoNode.class)) {
        [allPorts addObjectsFromArray:((AINetAbsFoNode*)node).conPorts];
    }
    if (node) {
        [allPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:node.pointer fileName:kFNMemConPorts time:cRTMemPort]];
    }
    return allPorts;
}
+(NSArray*) conPorts_All_Normal:(AINodeBase*)node{
    NSArray *allPorts = [self conPorts_All:node];
    return [SMGUtils filterPorts_Normal:allPorts];
}
+(NSArray*) conPorts_All:(AINodeBase*)node havTypes:(NSArray*)havTypes noTypes:(NSArray*)noTypes{
    NSArray *allPorts = [self conPorts_All:node];
    return [SMGUtils filterPorts:allPorts havTypes:havTypes noTypes:noTypes];
}

+(NSArray*) refPorts_All4Alg:(AIAlgNodeBase*)node{
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (ISOK(node, AIAlgNodeBase.class)) {
        [allPorts addObjectsFromArray:node.refPorts];
        [allPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:node.pointer fileName:kFNMemRefPorts time:cRTMemPort]];
    }
    return allPorts;
}
+(NSArray*) refPorts_All4Alg_Normal:(AIAlgNodeBase*)node{
    NSArray *allPorts = [self refPorts_All4Alg:node];
    return [SMGUtils filterPorts_Normal:allPorts];
}

+(NSArray*) refPorts_All4Value:(AIKVPointer*)value_p{
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    [allPorts addObjectsFromArray:[self refPorts_All4Value:value_p isMem:false]];
    [allPorts addObjectsFromArray:[self refPorts_All4Value:value_p isMem:true]];
    return allPorts;
}
+(NSArray*) refPorts_All:(AIKVPointer*)node_p{
    if (PitIsValue(node_p)) {
        return [self refPorts_All4Value:node_p];
    }else if(PitIsAlg(node_p)){
        return [self refPorts_All4Alg:[SMGUtils searchNode:node_p]];
    }
    return nil;
}

+(NSArray*) refPorts_All4Value:(AIKVPointer*)value_p isMem:(BOOL)isMem{
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (value_p) {
        [allPorts addObjectsFromArray:[SMGUtils searchObjectForFilePath:value_p.filePath fileName:kFNRefPorts_All(isMem) time:cRTReference_All(isMem)]];
    }
    return allPorts;
}

+(NSArray*) dsPorts_All:(AIFoNodeBase*)node{
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (node) {
        [allPorts addObjectsFromArray:node.diffSubPorts];
        [allPorts addObjectsFromArray:[SMGUtils searchObjectForPointer:node.pointer fileName:kFNMemDSPorts time:cRTMemPort]];
    }
    return allPorts;
}

@end
