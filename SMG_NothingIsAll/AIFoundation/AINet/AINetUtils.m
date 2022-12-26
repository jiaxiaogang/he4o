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
    AIAlgNodeBase *algNode = [SMGUtils searchObjectForPointer:order_p fileName:kFNNode time:cRTNode];
    if (ISOK(algNode, AIAlgNodeBase.class)) {
        [AINetUtils insertPointer_Hd:foNode_p toPorts:algNode.refPorts ps:ps difStrong:difStrong];
        [SMGUtils insertObject:algNode pointer:algNode.pointer fileName:kFNNode time:cRTNode];
    }
}

+(void) insertRefPorts_AllMvNode:(AIKVPointer*)mvNode_p value_p:(AIPointer*)value_p difStrong:(NSInteger)difStrong{
    if (mvNode_p && value_p) {
        
        //1. 硬盘网络时,取出refPorts -> 并二分法强度序列插入 -> 存XGWedis;
        [self insertRefPorts_HdNode:mvNode_p passiveRefValue_p:value_p ps:nil difStrong:difStrong];
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
            [SMGUtils insertObject:conNode pointer:conNode.pointer fileName:kFNNode time:cRTNode];
        }
        
        //7. 抽象节点的 关联&存储
        [SMGUtils insertNode:absNode];
    }
}

/**
 *  MARK:--------------------cmv基本模型--------------------
 *  @version
 *      2022.05.11: cmv模型ralate时,将foNode的content.refPort标记mv指向 (参考26022-2);
 */
+(void) relateFo:(AIFoNodeBase*)foNode mv:(AICMVNodeBase*)mvNode{
    if (foNode && mvNode) {
        //1. 互指向
        mvNode.foNode_p = foNode.pointer;
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
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (ISOK(node, AINodeBase.class)) {
        [allPorts addObjectsFromArray:node.absPorts];
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
        [allPorts addObjectsFromArray:node.refPorts];
    }
    return allPorts;
}
+(NSArray*) refPorts_All4Alg_Normal:(AIAlgNodeBase*)node{
    AddTCDebug(@"时序识别2.1");
    NSArray *allPorts = [self refPorts_All4Alg:node];
    AddTCDebug(@"时序识别2.7");
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
    NSMutableArray *allPorts = [[NSMutableArray alloc] init];
    if (value_p) {
        //1. 收集db的;
        [allPorts addObjectsFromArray:[SMGUtils searchObjectForFilePath:value_p.filePath fileName:kFNRefPorts time:cRTReference]];
    }
    return allPorts;
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

/**
 *  MARK:--------------------获取near数据--------------------
 *  @desc 根据indexDic取得nearCount&sumNear (参考27177-todo3);
 *  @param callerIsAbs : 调用者是否是抽象;
 *  @result notnull 必有两个元素,格式为: [nearCount, sumNear],二者都是0时,则为无效返回;
 */
+(NSArray*) getNearDataByIndexDic:(NSDictionary*)indexDic absFo:(AIKVPointer*)absFo_p conFo:(AIKVPointer*)conFo_p callerIsAbs:(BOOL)callerIsAbs{
    //1. 数据准备;
    int nearCount = 0;  //总相近数 (匹配值<1)
    CGFloat sumNear = 0;//总相近度
    indexDic = DICTOOK(indexDic);
    AIFoNodeBase *absFo = [SMGUtils searchNode:absFo_p];
    AIFoNodeBase *conFo = [SMGUtils searchNode:conFo_p];
    
    //2. 逐个统计;
    for (NSNumber *key in indexDic.allKeys) {
        NSInteger absIndex = key.integerValue;
        NSInteger conIndex = NUMTOOK([indexDic objectForKey:key]).integerValue;
        AIKVPointer *absA_p = ARR_INDEX(absFo.content_ps, absIndex);
        AIKVPointer *conA_p = ARR_INDEX(conFo.content_ps, conIndex);
        
        //3. 复用取near值;
        CGFloat near = 0;
        if (callerIsAbs) {
            //5. 当前是抽象时_从抽象取复用;
            AIAlgNodeBase *absA = [SMGUtils searchNode:absA_p];
            near = [absA getConMatchValue:conA_p];
        }else{
            //4. 当前是具象时_从具象取复用;
            AIAlgNodeBase *conA = [SMGUtils searchNode:conA_p];
            near = [conA getAbsMatchValue:absA_p];
        }
        
        //6. 二者一样时,直接=1;
        if ([absA_p isEqual:conA_p]) near = 1;
        
        //7. 只记录near<1的 (取<1的原因未知,参考2619j-todo5);
        if (near < 1) {
            [AITest test14:near];
            sumNear += near;
            nearCount++;
        }
    }
    return @[@(nearCount), @(sumNear)];
}

@end
