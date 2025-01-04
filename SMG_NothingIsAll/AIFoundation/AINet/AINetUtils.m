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
 *  @status 2022.11.10: 应该早就是弃用状态,整个虚mv功能应该早没用了;
 */
+(BOOL) isVirtualMv:(AIKVPointer*)mv_p{
    AICMVNodeBase *mv = [SMGUtils searchNode:mv_p];
    if (mv) {
        NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mv.urgentTo_p]) integerValue];
        return urgentTo == 0;
    }
    return false;
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

//MARK:===============================================================
//MARK:                     < 取at&ds&type >
//MARK:===============================================================

/**
 *  MARK:--------------------从conNodes中取type--------------------
 *  @desc 具象是什么类型,抽象就是什么类型;
 *  @callers 目前在外类比中,任何type类型都可能调用;
 */
+(AnalogyType) getTypeFromConNodes:(NSArray*)conNodes{
    NSArray *types = [SMGUtils removeRepeat:[SMGUtils convertArr:conNodes convertBlock:^id(AINodeBase *obj) {
        return @(obj.pointer.type);
    }]];
    [AITest test6:types];
    if (types.count == 1) {
        return [NUMTOOK(ARR_INDEX(types, 0)) intValue];
    }
    return ATDefault;
}

/**
 *  MARK:--------------------从conNodes中取ds--------------------
 *  @desc 具象是什么类型,抽象就是什么类型;
 *  @callers 目前在外类比中,仅GL类型会调用;
 */
+(NSString*) getDSFromConNodes:(NSArray*)conNodes type:(AnalogyType)type{
    if (type == ATGreater || type == ATLess) {
        NSArray *dsList = [SMGUtils removeRepeat:[SMGUtils convertArr:conNodes convertBlock:^id(AIFoNodeBase *obj) {
            return obj.pointer.dataSource;
        }]];
        [AITest test6:dsList];
        if (dsList.count == 1) {
            return ARR_INDEX(dsList, 0);
        }
    }
    return DefaultDataSource;
}

/**
 *  MARK:--------------------从conNodes中取ds--------------------
 *  @desc 具象是什么类型,抽象就是什么类型;
 *  @callers 目前在外类比中,仅GL类型会调用;
 */
+(NSString*) getATFromConNodes:(NSArray*)conNodes type:(AnalogyType)type{
    if (type == ATGreater || type == ATLess) {
        NSArray *atList = [SMGUtils removeRepeat:[SMGUtils convertArr:conNodes convertBlock:^id(AIFoNodeBase *obj) {
            return obj.pointer.algsType;
        }]];
        [AITest test6:atList];
        if (atList.count == 1) {
            return ARR_INDEX(atList, 0);
        }
    }
    return DefaultAlgsType;
}

//MARK:===============================================================
//MARK:                     < pointer >
//MARK:===============================================================

/**
 *  MARK:--------------------pointer的对比算法--------------------
 *  @desc 之所以单独整理在此处,是为了不想调用equal()又想判断是否相等的时候调用这个 (比如下面的equal4Mv()方法就用这个);
 */
+(BOOL) equal4PitA:(AIPointer*)pitA pitB:(AIPointer*)pitB {
    //0. 检查;
    if (!POINTERISOK(pitA) || !POINTERISOK(pitB)) return false;
    
    //1. 对比
    if (pitA.pointerId == pitB.pointerId && pitA.params.count == pitB.params.count) {
        for (NSString *key in pitA.params.allKeys) {
            BOOL itemEqual = STRTOOK([pitA.params objectForKey:key]).hash == STRTOOK([pitB.params objectForKey:key]).hash;
            if (!itemEqual) {
                return false;//发现不同
            }
        }
        return true;//未发现不同,全一样;
    }
    return false;
}

/**
 *  MARK:--------------------对比mv和alg是否equal方法--------------------
 *  @desc 现在mv有两种节点类型,可能是M也可能是A,所以此处兼容一下,只要algsType和urgent一致,则返回true (参考31187);
 */
+(BOOL) equal4Mv:(AIKVPointer*)mv_p alg_p:(AIKVPointer*)alg_p {
    //1. 取出mvNode和其特征的refPorts;
    AICMVNodeBase *mv = [SMGUtils searchNode:mv_p];
    NSArray *urgentToRefs = Ports2Pits([AINetUtils refPorts_All4Value:mv.urgentTo_p]);
    NSArray *deltaRefs = Ports2Pits([AINetUtils refPorts_All4Value:mv.delta_p]);
    
    //2. 判断refPorts是否也指向了alg (注:不能用contains判断,因为它也是用equal判断的,会导致死循环);
    BOOL urgentContains = [SMGUtils filterSingleFromArr:urgentToRefs checkValid:^BOOL(AIKVPointer *item) {
        return [AINetUtils equal4PitA:alg_p pitB:item];
    }];
    BOOL deltaContains = [SMGUtils filterSingleFromArr:deltaRefs checkValid:^BOOL(AIKVPointer *item) {
        return [AINetUtils equal4PitA:alg_p pitB:item];
    }];
    
    //3. 指向了,则说明mv和alg两个节点一模一样;
    return urgentContains && deltaContains;
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
            [self insertRefPorts_HdNode:algNode_p passiveRefValue_p:value_p ps:sort_ps difStrong:difStrong];
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
    for (AIKVPointer *order_p in ARRTOOK(order_ps)) {
        [self insertRefPorts_AllFoNode:foNode_p order_p:order_p ps:ps difStrong:1];
    }
}
+(void) insertRefPorts_AllFoNode:(AIKVPointer*)foNode_p order_ps:(NSArray*)order_ps ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    order_ps = [SMGUtils removeRepeat:order_ps];
    for (AIKVPointer *order_p in ARRTOOK(order_ps)) {
        [self insertRefPorts_AllFoNode:foNode_p order_p:order_p ps:ps difStrong:difStrong];
    }
}
+(void) insertRefPorts_AllFoNode:(AIKVPointer*)foNode_p order_p:(AIKVPointer*)order_p ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:order_p fileName:kFNNode time:cRTNode(order_p)];
    if (ISOK(algNode, AIAlgNodeBase.class)) {
        [AINetUtils insertPointer_Hd:foNode_p toPorts:algNode.refPorts ps:ps difStrong:difStrong];
        [SMGUtils insertObject:algNode pointer:algNode.pointer fileName:kFNNode time:cRTNode(algNode.pointer)];
    }
}

/**
 *  MARK:--------------------mv和它的稀疏码(delta和urgent)插线--------------------
 *  @version
 *      2023.06.18: 支持ps生成header,原来是nil,导致分不清mv和空概念 (参考30026-修复);
 */
+(void) insertRefPorts_AllMvNode:(AICMVNodeBase*)mvNode value_p:(AIPointer*)value_p difStrong:(NSInteger)difStrong{
    if (mvNode && value_p) {
        //0. mv的ps也不为nil,传delta和urgent生成 (本来这俩就是它的内容,只是现在单独存着两个字段而已);
        NSArray *sort_ps = [SMGUtils sortPointers:mvNode.content_ps];
        //1. 硬盘网络时,取出refPorts -> 并二分法强度序列插入 -> 存XGWedis;
        [self insertRefPorts_HdNode:mvNode.pointer passiveRefValue_p:value_p ps:sort_ps difStrong:difStrong];
    }
}

/**
 *  MARK:--------------------硬盘节点_引用_微信息_插线 通用方法--------------------
 */
+(void) insertRefPorts_HdNode:(AIKVPointer*)hdNode_p passiveRefValue_p:(AIPointer*)passiveRefValue_p ps:(NSArray*)ps difStrong:(NSInteger)difStrong{
    if (ISOK(hdNode_p, AIKVPointer.class) && ISOK(passiveRefValue_p, AIKVPointer.class)) {
        NSArray *fnRefPorts = ARRTOOK([SMGUtils searchObjectForFilePath:passiveRefValue_p.filePath fileName:kFNRefPorts time:cRTReference]);
        NSMutableArray *refPorts = [[NSMutableArray alloc] initWithArray:fnRefPorts];
        [AINetUtils insertPointer_Hd:hdNode_p toPorts:refPorts ps:ps difStrong:difStrong];
        [SMGUtils insertObject:refPorts rootPath:passiveRefValue_p.filePath fileName:kFNRefPorts time:cRTReference saveDB:true];
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
    NSArray *cp = [fromPorts copy];
    for (AIPort *port in cp) {
        if ([port.target_p isEqual:pointer]) {
            return port;
        }
    }
    return nil;
}


//MARK:===============================================================
//MARK:                     < 抽具象关联 Relate (外界调用,支持alg/fo) >
//MARK:===============================================================
+(void) relateAlgAbs:(AIAlgNodeBase*)absNode conNodes:(NSArray*)conNodes isNew:(BOOL)isNew{
    if (isNew) {
        BOOL absIsJiE = [NVHeUtil algIsJiE:absNode.pointer];
        BOOL conIsJiE = [SMGUtils filterSingleFromArr:conNodes checkValid:^BOOL(AIAlgNodeBase *item) {
            return [NVHeUtil algIsJiE:item.pointer];
        }];
        if (absIsJiE != conIsJiE) {
            //TODOTOMORROW20240801: 查下此处为什么M1(饥饿)和A3955(皮果)会有mIsC关系? (参考32132);
            NSLog(@"当conNodes是饥饿,但absNode不是饥饿时,查下为什么二者会关联起来?此处如果到2024.09.01还没停过,则可删除掉了 (参考32132)");
        }
    }
    
    [self relateGeneralAbs:absNode absConPorts:absNode.conPorts conNodes:conNodes isNew:isNew difStrong:1];
}
+(void) relateFoAbs:(AIFoNodeBase*)absNode conNodes:(NSArray*)conNodes isNew:(BOOL)isNew{
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
            
            //2. hd_具象节点插"抽象端口";
            [AINetUtils insertPointer_Hd:absNode.pointer toPorts:conNode.absPorts ps:absContent_ps difStrong:difStrong];
            //3. hd_抽象节点插"具象端口";
            [AINetUtils insertPointer_Hd:conNode.pointer toPorts:absConPorts ps:conContent_ps difStrong:difStrong];
            //4. hd_存储
            [SMGUtils insertObject:conNode pointer:conNode.pointer fileName:kFNNode time:cRTNode(conNode.pointer)];
        }
        
        //7. 抽象节点的 关联&存储
        [SMGUtils insertNode:absNode];
    }
}

/**
 *  MARK:--------------------抽具象关联通用方法 (参考29031-todo3)--------------------
 */
+(void) relateGeneralCon:(AINodeBase*)conNode absNodes:(NSArray*)absNode_ps {
    //1. 数据准备;
    absNode_ps = ARRTOOK(absNode_ps);
    if (!ISOK(conNode, AINodeBase.class)) return;
    
    //2. 依次关联;
    for (AIKVPointer *absNode_p in absNode_ps) {
        //1. con与abs必须不同;
        AINodeBase *absNode = [SMGUtils searchNode:absNode_p];
        if ([conNode isEqual:absNode]) continue;
        
        //2. hd_具象节点插"抽象端口";
        [AINetUtils insertPointer_Hd:absNode.pointer toPorts:conNode.absPorts ps:absNode.content_ps difStrong:1];
        //3. hd_抽象节点插"具象端口";
        [AINetUtils insertPointer_Hd:conNode.pointer toPorts:absNode.conPorts ps:conNode.content_ps difStrong:1];
        //4. hd_存储
        [SMGUtils insertNode:absNode];
        [SMGUtils insertNode:conNode];
    }
}

/**
 *  MARK:--------------------cmv基本模型--------------------
 *  @version
 *      2022.05.11: cmv模型relate时,将foNode的content.refPort标记mv指向 (参考26022-2);
 *      2023.08.11: mv支持多个指向foNode (参考30095-todo2);
 */
+(void) relateFo:(AIFoNodeBase*)foNode mv:(AICMVNodeBase*)mvNode{
    if (foNode && mvNode) {
        //1. 互指向
        [AINetUtils insertPointer_Hd:foNode.pointer toPorts:mvNode.foPorts ps:foNode.content_ps difStrong:1];
        foNode.cmvNode_p = mvNode.pointer;
        
        //2. 对content.refPort标记mv;
        [AINetUtils maskHavMv_AlgWithFo:foNode];
        
        //3. 存储foNode & cmvNode
        [SMGUtils insertNode:mvNode];
        [SMGUtils insertNode:foNode];
    }
}

@end


//MARK:===============================================================
//MARK:                     < Port >
//MARK:===============================================================
@implementation AINetUtils (Port)

+(NSArray*) absPorts_All:(AINodeBase*)node{
    return [node.absPorts copy];
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
+(NSArray*) absAndMePits:(AINodeBase*)node{
    NSMutableArray *result = [[NSMutableArray alloc] initWithObjects:node.pointer, nil];
    [result addObjectsFromArray:Ports2Pits([self absPorts_All:node])];
    return result;
}

+(NSArray*) conPorts_All:(AINodeBase*)node{
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (ISOK(node, AIAbsAlgNode.class)) {
        [allPorts addObjectsFromArray:((AIAbsAlgNode*)node).conPorts];
    }else if (ISOK(node, AINetAbsFoNode.class)) {
        [allPorts addObjectsFromArray:((AINetAbsFoNode*)node).conPorts];
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

/**
 *  MARK:--------------------refPorts--------------------
 *  @version
 *      2022.08.22: 因为防重性能差,优化"并集"防重算法 (参考27082-慢代码1);
 *      2022.10.09: 仅保留硬盘的refPorts (参考27124-todo4);
 */
+(NSArray*) refPorts_All4Alg:(AIAlgNodeBase*)node{
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (ISOK(node, AIAlgNodeBase.class)) {
        
        //2023.11.29: refPorts中有空元素,导致闪退...
        for (NSInteger i = 0; i < node.refPorts.count; i++) {
            AIPort *item = ARR_INDEX(node.refPorts, i);
            if (!item) {
                AIFoNodeBase *itemNode = [SMGUtils searchNode:item.target_p];
                ELog(@"以前没空过,突然这里闪退了,但不复现,以后复现时断点在这里,查下原因:%@ %@ %ld/%ld",Alg2FStr(node),Fo2FStr(itemNode),i,node.refPorts.count);
                NSLog(@"");
            }
        }
        [allPorts addObjectsFromArray:node.refPorts];
    }
    return allPorts;
}
+(NSArray*) refPorts_All4Alg_Normal:(AIAlgNodeBase*)node{
    NSArray *allPorts = [self refPorts_All4Alg:node];
    return [SMGUtils filterPorts_Normal:allPorts];
}

+(NSArray*) refPorts_All:(AIKVPointer*)node_p{
    if (PitIsValue(node_p)) {
        return [self refPorts_All4Value:node_p];
    }else if(PitIsAlg(node_p)){
        return [self refPorts_All4Alg:[SMGUtils searchNode:node_p]];
    }
    return nil;
}

+(NSArray*) refPorts_All4Value:(AIKVPointer*)value_p {
    if (!value_p) return nil;
    return [SMGUtils searchObjectForFilePath:value_p.filePath fileName:kFNRefPorts time:cRTReference];
}

/**
 *  MARK:--------------------对fo.content.refPort标记havMv--------------------
 *  @desc 根据fo标记alg.refPort的havMv (参考26022-2);
 */
+(void) maskHavMv_AlgWithFo:(AIFoNodeBase*)foNode{
    //1. 标记alg.refPort;
    for (AIKVPointer *alg_p in foNode.content_ps) {
        AIAlgNodeBase *algNode = [SMGUtils searchNode:alg_p];
        NSArray *algRefPorts = [AINetUtils refPorts_All4Alg:algNode];
        for (AIPort *algRefPort in algRefPorts) {
            
            //2. 当refPort是当前fo,则标记为true;
            if ([algRefPort.target_p isEqual:foNode.pointer]) {
                algRefPort.targetHavMv = true;
                //3. 保存algRefPorts到db;
                [SMGUtils insertNode:algNode];
                
                //4. 继续向微观标记;
                [self maskHavMv_ValueWithAlg:algNode];
            }
        }
    }
}

/**
 *  MARK:--------------------对alg.content.refPort标记havMv--------------------
 *  @desc 根据alg标记value.refPort的havMv (参考26022-2);
 *  @test 取了db+mem的refPorts,但保存时,都保存到了db中 (但应该没啥影响,先不管);
 *  @version
 *      2022.05.13: 将refPorts_All4Value()中防重处理,避免此处存到db后有重复 (参考26023);
 */
+(void) maskHavMv_ValueWithAlg:(AIAlgNodeBase*)algNode{
    //1. 标记value.refPort;
    for (AIKVPointer *value_p in algNode.content_ps) {
        NSArray *valueRefPorts = [AINetUtils refPorts_All4Value:value_p];
        for (AIPort *valueRefPort in valueRefPorts) {
            
            //2. 当refPort是当前alg,则标记为true;
            if ([valueRefPort.target_p isEqual:algNode.pointer]) {
                valueRefPort.targetHavMv = true;
                
                //3. 保存valueRefPorts到db;
                [SMGUtils insertObject:valueRefPorts rootPath:value_p.filePath fileName:kFNRefPorts time:cRTReference saveDB:true];
            }
        }
    }
}

@end


//MARK:===============================================================
//MARK:                     < Node >
//MARK:===============================================================
@implementation AINetUtils (Node)

/**
 *  MARK:--------------------获取cutIndex--------------------
 *  @title 根据indexDic取得截点cutIndex (参考27177-todo2);
 *  @desc
 *      1. 已发生截点 (含cutIndex已发生,所以cutIndex应该就是proto末位在assFo中匹配到的assIndex下标);
 *      2. 取用方式1: 取最大的key即是cutIndex (目前选用,因为它省得取出conFo);
 *      3. 取用方式2: 取protoFo末位为value,对应的key即为:cutIndex;
 *  @version
 *      2023.07.11: v2-根据protoOrRegroupCutIndex在indexDic中取absMatchFo.cutIndex并返回;
 *  @result 返回截点cutIndex (注: 此处永远返回抽象Fo的截点,因为具象在时序识别中没截点);
 */
+(NSInteger) getCutIndexByIndexDic:(NSDictionary*)indexDic {
    //1. 取indexDic;
    NSInteger result = -1;
    indexDic = DICTOOK(indexDic);
    
    //2. 取最大的key,即为cutIndex;
    for (NSNumber *absIndex in indexDic.allKeys) {
        if (result < absIndex.integerValue) result = absIndex.integerValue;
    }
    return result;
}

+(NSInteger) getCutIndexByIndexDicV2:(NSDictionary*)indexDic protoOrRegroupCutIndex:(NSInteger)protoOrRegroupCutIndex {
    //1. 找出<=且最接近protoOrRegroupCutIndex的value;
    NSInteger mostNear = -1;
    for (NSNumber *value in indexDic.allValues) {
        NSInteger conIndex = value.integerValue;
        //2. 当前conIndex大于已知 & 且<=protoOrRegroupCutIndex(必须<=已发生);
        if (conIndex > mostNear && conIndex <= protoOrRegroupCutIndex) {
            mostNear = conIndex;
        }
    }
    
    //2. mostNear对应的absIndex就是要返回的cutIndex;
    for (NSNumber *key in indexDic.allKeys) {
        NSInteger conIndex = NUMTOOK([indexDic objectForKey:key]).integerValue;
        if (conIndex == mostNear) {
            return key.integerValue;
        }
    }
    
    //3. 如果一条没找着,说明matchFo一帧都没已发生;
    return -1;
}

/**
 *  MARK:--------------------获取near数据 (直传fo版)--------------------
 *  @desc 调用说明: 对于有明确的absFo和conFo的,可以调用fo版;
 *  @desc 简述: 此方法,根据indexDic利用alg元素实时计算出fo匹配度, 另外还有个办法是直接从fo.matchValueDic中取复用,那个性能好,不用实时计算;
 *  @desc 根据indexDic取得nearCount&sumNear (参考27177-todo3);
 *  @version
 *      2023.01.18: 相似度默认值为1,且相似度改为相乘 (参考28035-todo2);
 *  @param callerIsAbs : 调用者是否是抽象;
 *  @result notnull 必有两个元素,格式为: [nearCount, sumNear],二者都是0时,则为无效返回;
 */
+(CGFloat) getMatchByIndexDic:(NSDictionary*)indexDic absFo:(AIKVPointer*)absFo_p conFo:(AIKVPointer*)conFo_p callerIsAbs:(BOOL)callerIsAbs {
    return NUMTOOK(ARR_INDEX([self getNearDataByIndexDic:indexDic absFo:absFo_p conFo:conFo_p callerIsAbs:callerIsAbs], 1)).floatValue;
}
+(NSArray*) getNearDataByIndexDic:(NSDictionary*)indexDic absFo:(AIKVPointer*)absFo_p conFo:(AIKVPointer*)conFo_p callerIsAbs:(BOOL)callerIsAbs{
    AIFoNodeBase *absFo = [SMGUtils searchNode:absFo_p];//400ms 4000次
    AIFoNodeBase *conFo = [SMGUtils searchNode:conFo_p];//400ms 4000次
    return [self getNearDataByIndexDic:indexDic getAbsAlgBlock:^AIKVPointer *(NSInteger absIndex) {
        return ARR_INDEX(absFo.content_ps, absIndex);
    } getConAlgBlock:^AIKVPointer *(NSInteger conIndex) {
        return ARR_INDEX(conFo.content_ps, conIndex);
    } callerIsAbs:callerIsAbs];
}
//不传indexDic时,默认从abs和con取全部indexDic复用之;
+(CGFloat) getMatchByIndexDic:(AIKVPointer*)absFo_p conFo:(AIKVPointer*)conFo_p callerIsAbs:(BOOL)callerIsAbs {
    if (callerIsAbs) {
        AIFoNodeBase *absF = [SMGUtils searchNode:absFo_p];
        return NUMTOOK(ARR_INDEX([self getNearDataByIndexDic:[absF getConIndexDic:conFo_p] absFo:absFo_p conFo:conFo_p callerIsAbs:callerIsAbs], 1)).floatValue;
    }else{
        AIFoNodeBase *conF = [SMGUtils searchNode:conFo_p];
        return NUMTOOK(ARR_INDEX([self getNearDataByIndexDic:[conF getAbsIndexDic:absFo_p] absFo:absFo_p conFo:conFo_p callerIsAbs:callerIsAbs], 1)).floatValue;
    }
}

/**
 *  MARK:--------------------获取near数据 (回调版)--------------------
 *  @desc 调用说明: 对于未生成明确的absFo或conFo的调用回调版 (比如: canset在transferAlg时,还没有生成为fo供传参,此处用回调去取Alg元素);
 *  @param indexDic 根据此dic逐条取itemNear数据;
 *  @param getAbsAlgBlock : 根据absIndex取对应的absAlg回调
 *  @param getConAlgBlock : 根据conIndex取对应的conAlg回调
 */
+(NSArray*) getNearDataByIndexDic:(NSDictionary*)indexDic getAbsAlgBlock:(AIKVPointer*(^)(NSInteger absIndex))getAbsAlgBlock getConAlgBlock:(AIKVPointer*(^)(NSInteger conIndex))getConAlgBlock callerIsAbs:(BOOL)callerIsAbs {
    //1. 数据准备;
    int nearCount = 0;  //总相近数 (匹配值<1)
    indexDic = DICTOOK(indexDic);
    CGFloat sumNear = indexDic.count > 0 ? 1 : 0;//总相近度 (有数据时默认1,无数据时默认0);
    
    //2. 逐个统计;
    for (NSNumber *key in indexDic.allKeys) {
        NSInteger absIndex = key.integerValue;
        NSInteger conIndex = NUMTOOK([indexDic objectForKey:key]).integerValue;
        AIKVPointer *absA_p = getAbsAlgBlock(absIndex);
        AIKVPointer *conA_p = getConAlgBlock(conIndex);
        
        //3. 复用取near值;
        CGFloat near = 0;
        if (callerIsAbs) {
            //5. 当前是抽象时_从抽象取复用;
            AIAlgNodeBase *absA = [SMGUtils searchNode:absA_p];//590ms 5000次
            near = [absA getConMatchValue:conA_p];//100ms 5000次
        }else{
            //4. 当前是具象时_从具象取复用;
            AIAlgNodeBase *conA = [SMGUtils searchNode:conA_p];
            near = [conA getAbsMatchValue:absA_p];
        }
        
        //7. 只记录near<1的 (取<1的原因未知,参考2619j-todo5);
        if (near < 1) {
            [AITest test14:near];
            sumNear *= near;
            nearCount++;
        }
    }
    return @[@(nearCount), @(sumNear)];
}

//MARK:===============================================================
//MARK:                     < Fo引用强度RefStrong的取值和更新 >
//MARK:===============================================================

/**
 *  MARK:--------------------获取sumRefStrong已发生部分强度--------------------
 *  @desc 根据indexDic取得sumRefStrong (参考2722f-todo13);
 */
+(NSInteger) getSumRefStrongByIndexDic:(NSDictionary*)indexDic matchFo:(AIKVPointer*)matchFo_p {
    //1. 数据准备;
    NSInteger sumRefStrong = 0;  //总强度
    AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];
    
    //2. 逐个统计;
    for (NSNumber *key in indexDic.allKeys) {
        NSInteger absIndex = key.integerValue;
        AIPort *itemPort = ARR_INDEX(matchFo.contentPorts, absIndex);
        sumRefStrong += itemPort.strong.value;
    }
    return sumRefStrong;
}

/**
 *  MARK:--------------------根据indexDic更新refPort强度值 (参考2722f-todo33)--------------------
 */
+(void) updateRefStrongByIndexDic:(NSDictionary*)indexDic matchFo:(AIKVPointer*)matchFo_p {
    //1. 根据indexDic取出已发生部分content_ps;
    AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];
    NSArray *frontContent_ps = [self filterContentAlgPsByIndexDic:indexDic matchFo:matchFo];
    
    //3. 将已发生部分增强refStrong;
    [AINetUtils insertRefPorts_AllFoNode:matchFo_p order_ps:frontContent_ps ps:matchFo.content_ps];
}

/**
 *  MARK:--------------------根据indexDic更新contentPort强度值 (参考2722f-todo32)--------------------
 */
+(void) updateContentStrongByIndexDic:(NSDictionary*)indexDic matchFo:(AIKVPointer*)matchFo_p {
    //1. 数据准备;
    AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];
    
    //2. 根据indexDic更新contentPort强度值 & 保存;
    for (NSNumber *key in indexDic.allKeys) {
        NSInteger absIndex = key.integerValue;
        AIPort *itemPort = ARR_INDEX(matchFo.contentPorts, absIndex);
        itemPort.strong.value++;
    }
    [SMGUtils insertNode:matchFo];
}

//MARK:===============================================================
//MARK:                     < Alg抽具象强度ConStrong的取值和更新 >
//MARK:===============================================================

/**
 *  MARK:--------------------获取sumConStrong已发生部分强度--------------------
 *  @desc 根据indexDic取得sumConStrong (参考28086-todo1);
 */
+(NSInteger) getSumConStrongByIndexDic:(NSDictionary*)indexDic matchFo:(AIKVPointer*)matchFo_p cansetFo:(AIKVPointer*)cansetFo_p{
    //1. 数据准备;
    NSInteger sumStrong = 0;  //总强度
    AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
    
    //2. 逐个统计;
    for (NSNumber *key in indexDic.allKeys) {
        NSInteger absIndex = key.integerValue;
        NSInteger conIndex = NUMTOOK([indexDic objectForKey:key]).integerValue;
        AIAlgNodeBase *absAlg = [SMGUtils searchNode:ARR_INDEX(matchFo.content_ps, absIndex)];
        AIKVPointer *conAlg = ARR_INDEX(cansetFo.content_ps, conIndex);
        AIPort *findPort = [AINetUtils findPort:conAlg fromPorts:absAlg.conPorts];
        sumStrong += findPort.strong.value;
    }
    return sumStrong;
}

/**
 *  MARK:--------------------根据indexDic更新conPort和absPort强度值--------------------
 *  @desc canset方案最终激活时,将其conPorts和absPorts的强度+1 (参考28086-todo2);
 */
+(void) updateConAndAbsStrongByIndexDic:(NSDictionary*)indexDic matchFo:(AIKVPointer*)matchFo_p cansetFo:(AIKVPointer*)cansetFo_p{
    //1. 数据准备;
    AIFoNodeBase *matchFo = [SMGUtils searchNode:matchFo_p];
    AIFoNodeBase *cansetFo = [SMGUtils searchNode:cansetFo_p];
    
    //2. 将已发生部分增强refStrong;
    for (NSNumber *key in indexDic.allKeys) {
        NSInteger absIndex = key.integerValue;
        NSInteger conIndex = NUMTOOK([indexDic objectForKey:key]).integerValue;
        AIAlgNodeBase *absAlg = [SMGUtils searchNode:ARR_INDEX(matchFo.content_ps, absIndex)];
        AIAlgNodeBase *conAlg = [SMGUtils searchNode:ARR_INDEX(cansetFo.content_ps, conIndex)];
        [AINetUtils relateAlgAbs:absAlg conNodes:@[conAlg] isNew:false];
    }
}

//MARK:===============================================================
//MARK:                     < Alg引用强度RefStrong更新 >
//MARK:===============================================================

/**
 *  MARK:--------------------根据indexDic更新refPort强度值 (参考28103-3)--------------------
 */
+(void) updateAlgRefStrongByIndexArr:(NSArray*)indexArr fo:(AIKVPointer*)fo_p {
    //1. 根据indexDic取出已发生部分content_ps;
    AIFoNodeBase *fo = [SMGUtils searchNode:fo_p];
    NSArray *frontContent_ps = [self filterContentAlgPsByIndexArr:indexArr fo:fo];
    
    //2. 将已发生部分Alg增强refStrong;
    for (AIKVPointer *item in frontContent_ps) {
        AIAlgNodeBase *itemAlg = [SMGUtils searchNode:item];
        [AINetUtils insertRefPorts_AllAlgNode:item content_ps:itemAlg.content_ps difStrong:1];
    }
}

//MARK:===============================================================
//MARK:                     < PrivateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------根据indexDic筛选fo的content--------------------
 */
+(NSArray*) filterContentAlgPsByIndexDic:(NSDictionary*)indexDic matchFo:(AIFoNodeBase*)matchFo {
    return [self filterContentAlgPsByIndexArr:indexDic.allKeys fo:matchFo];
}

+(NSArray*) filterContentAlgPsByIndexArr:(NSArray*)indexArr fo:(AIFoNodeBase*)fo {
    //1. 把下标从小到大排序;
    indexArr = [SMGUtils sortSmall2Big:indexArr compareBlock:^double(NSNumber *obj) {
        return obj.integerValue;
    }];
    
    //2. 根据下标indexArr取出已发生部分content_ps;
    return [SMGUtils convertArr:indexArr convertBlock:^id(NSNumber *index) {
        return ARR_INDEX(fo.content_ps, index.integerValue);
    }];
}

/**
 *  MARK:--------------------类比出absFo时,此处取得具象fo与absFo的indexDic映射--------------------
 *  @desc 作用1: 生成抽象canset与conCanset的indexDic (参考29032-todo1.1)
 *  @desc 作用2: 生成外类比AnalogyOutside()里的absFo与protoFo/assFo的映射 (参考29032-todo1.2);
 *  @desc 比如输入[3,5,1],则返回<1:1, 2:3, 3:5>;
 *  @param conFoIndexes : 具象帧的下标数组 (每个元素,都对应了抽象的一帧);
 */
+(NSDictionary*) getIndexDic4AnalogyAbsFo:(NSArray*)conFoIndexes {
    NSMutableDictionary *result = [NSMutableDictionary new];
    //1. 具象下标数组从小到大排序下 (比如3,5,1排成1,3,5);
    NSArray *sort = [SMGUtils sortSmall2Big:conFoIndexes compareBlock:^double(NSNumber *obj) {
        return obj.integerValue;
    }];
    //2. 根据每帧映射生成indexDic结果返回;
    for (NSInteger i = 0; i < sort.count; i++) {
        [result setObject:ARR_INDEX(sort, i) forKey:@(i)];
    }
    return result;
}

//MARK:===============================================================
//MARK:                     < 抽象Fo时,更新SP值 >
//MARK:===============================================================

/**
 *  MARK:--------------------absFo根据indexDic继承conFo的sp值 (参考29032-todo2.2)--------------------
 */
+(void) extendSPByIndexDic:(NSDictionary*)assIndexDic assFo:(AIFoNodeBase*)assFo absFo:(AIFoNodeBase*)absFo {
    //1. ass与abs的每条映射都要继承;
    for (NSNumber *absIndex in assIndexDic.allKeys) {
        
        //2. 取出ass中旧有的spStrong模型;
        NSNumber *assIndex = [assIndexDic objectForKey:absIndex];
        AISPStrong *spStrong = [assFo.spDic objectForKey:assIndex];
        
        //3. 将spStrong继承给absFo;
        [absFo updateSPStrong:absIndex.integerValue difStrong:spStrong.sStrong type:ATSub caller:@"extendSPByIndexDic"];
        [absFo updateSPStrong:absIndex.integerValue difStrong:spStrong.pStrong type:ATPlus caller:@"extendSPByIndexDic"];
    }
}

/**
 *  MARK:--------------------抽象fo时: 根据protoFo增强absFo的SP值+1 (参考29032-todo2.3)--------------------
 */
+(void) updateSPByIndexDic:(NSDictionary*)conIndexDic conFo:(AIFoNodeBase*)conFo absFo:(AIFoNodeBase*)absFo {
    for (NSNumber *absIndex in conIndexDic.allKeys) {
        [absFo updateSPStrong:absIndex.integerValue difStrong:1 type:ATPlus caller:@"updateSPByIndexDic"];
    }
}

/**
 *  MARK:--------------------判断时序中有空概念--------------------
 */
+(BOOL) foHasEmptyAlg:(AIKVPointer*)fo_p {
    AIFoNodeBase *fo = [SMGUtils searchNode:fo_p];
    return [SMGUtils filterSingleFromArr:fo.contentPorts checkValid:^BOOL(AIPort *item) {
        return [item.header isEqualToString:[NSString md5:@""]];
    }];
}

/**
 *  MARK:--------------------初始化itemOutSPDic (在转实时,默认以cansetFrom的itemOutSPDic初始化) (参考33062-TODO3)--------------------
 *  @desc 用于canset转实后: 把cansetFrom的outSPDic迁移继承给cansetTo (注意要防重);
 */
+(void) initItemOutSPDicForTransfered:(TOFoModel*)canset {
    //0. 先关掉这里 (参考33114-TODO1);
    BOOL isSwitch = false;
    if (!isSwitch) return;
    
    //1. 检查有没初始化过 (只初始一次,用于防重);
    AIFoNodeBase *sceneTo = [SMGUtils searchNode:canset.sceneTo];
    NSString *cansetToOutSPKey = [self getOutSPKey:Simples2Pits(canset.transferXvModel.cansetToOrders)];
    if ([sceneTo.outSPDic objectForKey:cansetToOutSPKey]) return;
    
    //2. 取旧;
    AIFoNodeBase *sceneFrom = [SMGUtils searchNode:canset.sceneFrom];
    AIFoNodeBase *cansetFrom = [SMGUtils searchNode:canset.cansetFrom];
    NSString *cansetFromOutSPKey = [self getOutSPKey:cansetFrom.content_ps];
    NSMutableDictionary *initOutSPDic = [sceneFrom.outSPDic objectForKey:cansetFromOutSPKey];
    if (!DICISOK(initOutSPDic)) return;
    
    //3. 移新;
    [sceneTo.outSPDic setObject:initOutSPDic forKey:cansetToOutSPKey];
}

/**
 *  MARK:--------------------初始化itemOutSPDic (在canset类比抽象时) (参考33062-TODO4)--------------------
 *  @desc 用于canset类比抽象后: 把conCanset的itemOutSPDic设为新构建的absCanset的初始itemOutSPDic (参考33062-TODO4);
 */
+(void) initItemOutSPDicForAbsCanset:(AIFoNodeBase*)scene conCanset:(AIFoNodeBase*)conCanset absCanset:(AIFoNodeBase*)absCanset {
    //1. 检查有没初始化默认过具象的itemOutSPDic (只初始一次,用于防重) (参考33062-TODO4.1);
    NSString *absCansetOutSPKey = [self getOutSPKey:absCanset.content_ps];
    if ([scene.outSPDic objectForKey:absCansetOutSPKey]) return;
    
    //2. 取conCanset的itemOutSPDic;
    NSString *conCansetOutSPKey = [self getOutSPKey:conCanset.content_ps];
    NSDictionary *fromItemOutSPDic = [scene.outSPDic objectForKey:conCansetOutSPKey];
    if (!DICISOK(fromItemOutSPDic)) return;
    
    //3. 取conCanset和absCanset的映射 (因为有映射的,才继承它的sp值,没映射的不处理);
    NSDictionary *conAbsCansetIndexDic = [conCanset getAbsIndexDic:absCanset.p];
    if (!DICISOK(conAbsCansetIndexDic)) return;
    
    //4. 有映射的,逐帧继承sp值;
    for (NSNumber *absIndex in conAbsCansetIndexDic.allKeys) {
        NSNumber *conIndex = [conAbsCansetIndexDic objectForKey:absIndex];
        AISPStrong *fromItemSPStrong = [fromItemOutSPDic objectForKey:conIndex];
        if (!fromItemSPStrong) continue;
        
        //4. 把s和p都继承下;
        [scene updateOutSPStrong:absIndex.integerValue difStrong:fromItemSPStrong.pStrong type:ATPlus canset:absCanset.content_ps debugMode:false caller:@"AbsRCanset初始化itemOutSPDic"];
        [scene updateOutSPStrong:absIndex.integerValue difStrong:fromItemSPStrong.sStrong type:ATSub canset:absCanset.content_ps debugMode:false caller:@"AbsRCanset初始化itemOutSPDic"];
    }
}

/**
 *  MARK:--------------------取outSPDic的key (参考33065-TODO1)--------------------
 *  @param content_ps 传cansetTo的内容 (或者新构建的absCanset,newCanset的内容这些直接挂在scene下的canset的内容即可);
 */
+(NSString*) getOutSPKey:(NSArray*)content_ps {
    return STRTOOK([NSString md5:[SMGUtils convertPointers2String:content_ps]]);
}

@end

//MARK:===============================================================
//MARK:                     < Canset >
//MARK:===============================================================
@implementation AINetUtils (Canset)

/**
 *  MARK:--------------------迁移关联--------------------
 *  @version
 *      2024.11.13: V2,把fromto命名成F/I两层,避免F/I层混乱 (参考33112-TODO4.4);
 */
+(void) relateTransfer_R:(AIFoNodeBase*)fScene fCanset:(AIFoNodeBase*)fCanset iScene:(AIFoNodeBase*)iScene iCanset:(NSArray*)cansetToContent_ps {
    //1. 数据准备;
    AITransferPort *transferPort = [AITransferPort newWithFScene:fScene.p fCanset:fCanset iScene:iScene.p iCansetContent_ps:cansetToContent_ps];
    
    //================ 进行迁移关联 (以实现防重,避免重复性能浪费等) ================
    //2024.11.13: 迁移都是迁移到I层,所以可以用transferIPorts来判断防重;
    
    //2. 插入传节点的承端口;
    if (![fScene.transferIPorts containsObject:transferPort]) {
        [fScene.transferIPorts addObject:transferPort];
        [SMGUtils insertNode:fScene];
    }
    
    //3. 插入承节点的传端口;
    if (![iScene.transferFPorts containsObject:transferPort]) {
        [iScene.transferFPorts addObject:transferPort];
        [SMGUtils insertNode:iScene];
    }
    [AITest test33:iScene fScene:fScene.p];
}

/**
 *  MARK:--------------------H任务时,调用此方法 (参考33144-TODO1)--------------------
 */
+(void) relateTransfer_H:(AIFoNodeBase*)fScene fCanset:(AIFoNodeBase*)fCanset iScene:(AIFoNodeBase*)iScene iCanset:(NSArray*)cansetToContent_ps
                 fRScene:(AIFoNodeBase*)fRScene iRScene:(AIFoNodeBase*)iRScene {
    //1. 数据准备;
    AITransferPort_H *transferPort = [AITransferPort_H newWithFScene_H:fScene.p fCanset:fCanset iScene:iScene.p iCansetContent_ps:cansetToContent_ps fRScene:fRScene iRScene:iRScene];
    
    //2. 插入传节点的承端口;
    if (![fScene.transferIPorts containsObject:transferPort]) {
        [fScene.transferIPorts addObject:transferPort];
        [SMGUtils insertNode:fScene];
    }
    
    //3. 插入承节点的传端口;
    if (![iScene.transferFPorts containsObject:transferPort]) {
        [iScene.transferFPorts addObject:transferPort];
        [SMGUtils insertNode:iScene];
    }
    [AITest test33:iRScene fScene:fRScene.p];
}

/**
 *  MARK:--------------------outSP子即父--------------------
 *  @desc 子即父,推举到F层SP也+1: iCanset的outSP更新时,将它的fCanset的outSP也+1 (参考33112-TODO4.3);
 *  @desc I层即sceneTo,F层则从transferPort迁移关联来取 (参考33112-TODO3);
 */
+(void) updateOutSPStrong_4IF:(AIFoNodeBase*)iScene iCansetContent_ps:(NSArray*)iCansetContent_ps caller:(NSString*)caller spIndex:(NSInteger)spIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type debugMode:(BOOL)debugMode except4SP2F:(NSMutableArray*)except4SP2F{
    //0. i层计SP;
    [iScene updateOutSPStrong:spIndex difStrong:difStrong type:type canset:iCansetContent_ps debugMode:debugMode caller:caller];
    
    //1. 取f (有迁移复用);
    NSArray *fatherPorts = [AINetUtils transferPorts_4Father:iScene iCansetContent_ps:iCansetContent_ps];
    for (AITransferPort *fatherPort in fatherPorts) {
        //2024.12.05: 避免F值快速重复累计到很大,sp更新(同场景下的)防重推 (参考33137-方案v5TODO2);
        //2024.12.15: 把except4SP2F废弃掉,因为spMemRecord已经做了防重和回滚,不需要这个再防重了 (参考33137-问题2-补充);
        //NSString *itemExcept = STRFORMAT(@"%ld_%ld_%ld",fatherPort.fScene.pointerId,fatherPort.fCanset.pointerId,spIndex);
        //if ([except4SP2F containsObject:itemExcept]) continue;
        //[except4SP2F addObject:itemExcept];
        
        AIFoNodeBase *fatherScene = [SMGUtils searchNode:fatherPort.fScene];
        AIFoNodeBase *fatherCanset = [SMGUtils searchNode:fatherPort.fCanset];
        
        //2. cansetFrom和cansetTo是等长的,所以直接iCanset的index可以当fCanset的index来用;
        [fatherScene updateOutSPStrong:spIndex difStrong:1 type:type canset:fatherCanset.content_ps debugMode:false caller:STRFORMAT(@"%@(推举父)",caller)];
    }
}

/**
 *  MARK:--------------------inSP子即父--------------------
 *  @desc 子即父,推举到F层SP也+1: iScene的inSP更新时,将它的fScene的inSP也+1 (参考33111-TODO2 & 33134-FIX2a & TCRethink代码);
 */
+(void) updateInSPStrong_4IF:(AIFoNodeBase*)conFo conSPIndex:(NSInteger)conSPIndex difStrong:(NSInteger)difStrong type:(AnalogyType)type except4SP2F:(NSMutableArray*)except4SP2F {
    //1. 具象先更新;
    [conFo updateSPStrong:conSPIndex difStrong:difStrong type:type caller:@"updateInSPStrong_4IF-I"];
    if (!except4SP2F) except4SP2F= [[NSMutableArray alloc] init];
    
    //2. 抽象也更新 (参考29069-todo11.4);
    //2024.11.08: 佐证: 子即父 (参考33111-TODO2);
    [TCRethinkUtil spEff4Abs:conFo curFoIndex:conSPIndex itemRunBlock:^(AIFoNodeBase *absFo, NSInteger absIndex) {
        //2024.12.05: 避免F值快速重复累计到很大,sp更新(同场景下的)防重推 (参考33137-方案v5TODO1);
        //2024.12.15: 把except4SP2F废弃掉,因为spMemRecord已经做了防重和回滚,不需要这个再防重了 (参考33137-问题2-补充);
        //NSString *itemExcept = STRFORMAT(@"%ld_%ld",absFo.pId,absIndex);
        //if ([except4SP2F containsObject:itemExcept]) return;
        //[except4SP2F addObject:itemExcept];
        
        [absFo updateSPStrong:absIndex difStrong:difStrong type:type caller:@"updateInSPStrong_4IF-F"];
    }];
}

/**
 *  MARK:--------------------根据iScene取有迁移关联的father层--------------------
 *  @desc i层的from(继承源)和to(推举目标)都是father;
 */
//取哪些canset迁移成iCanset过;
+(NSArray*) transferPorts_4Father:(AIFoNodeBase*)iScene iCansetContent_ps:(NSArray*)iCansetContent_ps {
    NSString *foModelHeader = [NSString md5:[SMGUtils convertPointers2String:iCansetContent_ps]];
    return [SMGUtils filterArr:iScene.transferFPorts checkValid:^BOOL(AITransferPort *item) {
        //性能说明: 用header相等,可快至45ms/653次 | 原本用content_ps相等,速度为330ms/653次
        return [foModelHeader isEqualToString:item.iCansetHeader];
    }];
}

//取从fScene迁移过来iScene哪些canset;
+(NSArray*) transferPorts_4Father:(AIFoNodeBase*)iScene fScene:(AIFoNodeBase*)fScene {
    return [SMGUtils filterArr:iScene.transferFPorts checkValid:^BOOL(AITransferPort *item) {
        return [item.fScene isEqual:fScene.p];
    }];
}

@end
