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
#import "AINetIndexUtils.h"

@implementation AIAlgNodeManager

/**
 *  MARK:--------------------构建algNode--------------------
 *  1. 自动将algsArr中的元素分别生成absAlgNode
 *  2. absAlgNode根据索引的去重而去重;
 *  3. 具象algNode根据网络中联想而去重; (for(abs1.cons) & for(abs2.cons))
 *  4. abs和con都要有关联强度序列; (目前不需要,以后有需求的时候再加上)
 *  5. 微信息引用处理: value索引中,加上refPorts;类似algNode.refPorts的方式使用;并且使用单文件的方式存储和插线;
 *
 *  @param algsArr      : 算法值的装箱数组;
 *  @param isMem        : 为false时,持久化构建(如commitOutput),为true时仅内存网络中(如dataIn);
 *  _param dataSource  : 概念节点的dataSource就是稀疏码信息的algsType (不传时,从algsArr提取)
 *  @result notnull     : 返回具象algNode
 */
//+(AIAlgNode*) createAlgNode:(NSArray*)algsArr dataSource:(NSString*)dataSource isOut:(BOOL)isOut isMem:(BOOL)isMem{
//    //1. 数据
//    algsArr = ARRTOOK(algsArr);
//    
//    //2. 构建具象节点 (优先用本地已有,否则new)
//    AIAlgNode *conNode = [[AIAlgNode alloc] init];
//    conNode.pointer = [SMGUtils createPointerForAlg:kPN_ALG_NODE dataSource:dataSource isOut:isOut isMem:isMem];
//    
//    //3. 指定value_ps
//    conNode.content_ps = [[NSMutableArray alloc] initWithArray:[SMGUtils sortPointers:algsArr]];
// 
//    //4. value.refPorts (更新引用序列)
//    [AINetUtils insertRefPorts_AllAlgNode:conNode.pointer content_ps:conNode.content_ps difStrong:1];
//    
//    //5. 存储
//    [SMGUtils insertNode:conNode];
//    return conNode;
//}

/**
 *  MARK:--------------------构建抽象概念--------------------
 *  @param value_ps     : 要构建absAlgNode的content_ps (稀疏码组) notnull;
 *  @param conAlgs      : 具象AIAlgNode数组:(外类比时的algA&algB / 内类比时仅有一个元素) //不可为空数组
 *  @param isMem        : 是否持久化,(如thinkIn中,视觉场景下的subView就不进行持久化,只存在内存网络中)
 *  _param dataSource   : 概念节点的dataSource就是稀疏码信息的algsType; (不传时,从algsArr提取)
 *  @param dsBlock      : 指定ds (默认从value_ps获取);
 *  @param isOutBlock   : 指定isOut (默认从value_ps获取) (概念节点的isOut状态; (思维控制器知道它是行为还是认知));
 *
 *  @问题记录:
 *    1. 思考下,conAlgs中去重,能不能将md5匹配的conAlg做为absAlg的问题?
 *      a. 不能: (参考: 思考计划2/191126更新表)
 *      b. 能: (则导致会形成坚果是坚果的多层抽象)
 *      c. 结论: 能,问题转移到n17p19
 *  注: TODO:判断algSames是否就是algsA或algB本身; (等conAlgNode和absAlgNode统一不区分后,再判断本身)
 *  @version
 *      2021.01.03: 判断abs已存在抽象节点时,加上ATDS的匹配判断,因为不同类型节点不必去重 (参考2120B-BUG2);
 */
+(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isMem:(BOOL)isMem dsBlock:(NSString*(^)())dsBlock isOutBlock:(BOOL(^)())isOutBlock{
    //1. 数据准备
    NSString *dataSource = dsBlock ? dsBlock() : [self getDataSource:value_ps];
    BOOL isOut = isOutBlock ? isOutBlock() : [AINetUtils checkAllOfOut:value_ps];
    conAlgs = ARRTOOK(conAlgs);
    value_ps = ARRTOOK(value_ps);
    NSArray *sortSames = ARRTOOK([SMGUtils sortPointers:value_ps]);
    NSString *samesStr = [SMGUtils convertPointers2String:sortSames];
    NSString *samesMd5 = STRTOOK([NSString md5:samesStr]);
    NSMutableArray *validConAlgs = [[NSMutableArray alloc] initWithArray:conAlgs];
    AIAbsAlgNode *result = nil;
    
    //2. 判断具象节点中,已有一个抽象sames节点,则不需要再构建新的;
    for (AIAbsAlgNode *checkNode in conAlgs) {
        //a. checkNode是抽象节点时;
        if (ISOK(checkNode, AIAbsAlgNode.class)) {
            
            //b. 并且md5与orderSames相同时,即发现checkNode本身就是抽象节点;
            NSString *checkMd5 = STRTOOK([NSString md5:[SMGUtils convertPointers2String:[SMGUtils sortPointers:checkNode.content_ps]]]);
            if ([samesMd5 isEqualToString:checkMd5]) {
                
                //c. 则把conAlgs去掉checkNode;
                [validConAlgs removeObject:checkNode];
                
                //d. 找到result
                result = checkNode;
            }
        }
    }
    
    //2. 判断具象节点的absPorts中,是否已有一个"sames"节点,有则无需构建新的;
    if (!result) {
        for (AIAlgNodeBase *conNode in conAlgs) {
            NSArray *absPorts_All = [AINetUtils absPorts_All:conNode];
            for (AIPort *absPort in absPorts_All) {
                //1> 遍历找抽象是否已存在;
                if ([samesMd5 isEqualToString:absPort.header] && [absPort.target_p.dataSource isEqualToString:dataSource]) {
                    AIAbsAlgNode *absNode = [SMGUtils searchNode:absPort.target_p];
                    //2> 已存在,则转移到硬盘网络;
                    if (absNode.pointer.isMem) {
                        absNode = [AINetUtils move2HdNodeFromMemNode_Alg:absNode];
                    }
                    //3> findAbsNode成功;
                    result = absNode;
                    if (!ISOK(absNode, AIAbsAlgNode.class) ) {
                        WLog(@"发现非抽象类型的抽象节点错误,,,请检查出现此情况的原因;");
                    }
                    break;
                }
            }
        }
    }
    
    //3. 无则创建
    BOOL absIsNew = false;
    if (!result) {
        absIsNew = true;
        result = [[AIAbsAlgNode alloc] init];
        result.pointer = [SMGUtils createPointerForAlg:kPN_ALG_ABS_NODE dataSource:dataSource isOut:isOut isMem:isMem];
        result.content_ps = [[NSMutableArray alloc] initWithArray:sortSames];
    }
    
    ////4. 概念的嵌套 (190816取消概念嵌套,参见n16p17-bug16)
    //for (AIAlgNode *item in conAlgs) {
    //    ///1. 可替换时,逐个进行替换; (比如ATLess/ATGreater时,就不可替换)
    //    if ([SMGUtils containsSub_ps:value_ps parent_ps:item.content_ps]) {
    //        NSMutableArray *newValue_ps = [SMGUtils removeSub_ps:value_ps parent_ps:[[NSMutableArray alloc] initWithArray:item.content_ps]];
    //        [newValue_ps addObject:findAbsNode.pointer];
    //        item.content_ps = [SMGUtils sortPointers:newValue_ps];
    //    }
    //}
    
    //4. value.refPorts (更新/加强微信息的引用序列)
    NSInteger difStrong = 1;//absIsNew ? validConAlgs.count : 1;//20200106改回1,自由竞争无论是抽象还是具象;世上没有两片一样的树叶,所以对于抽象来说,本来就是讨便宜,易联想匹配的;
    [AINetUtils insertRefPorts_AllAlgNode:result.pointer content_ps:result.content_ps difStrong:difStrong];
    
    //5. 关联 & 存储
    [AINetUtils relateAlgAbs:result conNodes:validConAlgs isNew:absIsNew];
    [theApp.heLogView addLog:STRFORMAT(@"构建抽象概念:%@,存储于:%d,内容:%@",result.pointer.identifier,result.pointer.isMem,Alg2FStr(result))];
    [SMGUtils insertNode:result];
    return result;
}

/**
 *  MARK:--------------------构建抽象概念_防重--------------------
 */
+(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs isMem:(BOOL)isMem dsBlock:(NSString*(^)())dsBlock isOutBlock:(BOOL(^)())isOutBlock{
    //1. 数据检查
    value_ps = ARRTOOK(value_ps);
    NSArray *sort_ps = [SMGUtils sortPointers:value_ps];
    
    //2. 去重找本地 (仅抽象);
    AIAbsAlgNode *localAlg = [AINetIndexUtils getAbsoluteMatching_General:value_ps sort_ps:sort_ps except_ps:nil getRefPortsBlock:^NSArray *(AIKVPointer *item_p) {
        NSArray *refPorts = [AINetUtils refPorts_All4Value:item_p];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (AIPort *refPort in refPorts) {
            if ([kPN_ALG_ABS_NODE isEqualToString:refPort.target_p.folderName]) {
                [result addObject:refPort];
            }
        }
        return result;
    }];
    
    //3. 有则加强;
    if (ISOK(localAlg, AIAbsAlgNode.class)) {
        [AINetUtils relateAlgAbs:localAlg conNodes:conAlgs isNew:false];
        //4. 向硬盘转移
        if (!isMem) localAlg = [AINetUtils move2HdNodeFromMemNode_Alg:localAlg];
        return localAlg;
    }else{
        //4. 无则构建
        return [self createAbsAlgNode:value_ps conAlgs:conAlgs isMem:isMem dsBlock:dsBlock isOutBlock:isOutBlock];
    }
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

//从稀疏码组中,提取概念节点的dataSource;
+(NSString*) getDataSource:(NSArray*)value_ps{
    //1. 数据准备
    value_ps = ARRTOOK(value_ps);
    NSString *dataSource = DefaultDataSource;
    
    //2. 假如全一样,提出来;
    for (NSInteger i = 0; i < value_ps.count; i++) {
        AIKVPointer *value_p = ARR_INDEX(value_ps, i);
        if (i == 0) {
            dataSource = value_p.algsType;
        }else if([dataSource isEqualToString:value_p.algsType]){
            dataSource = DefaultDataSource;
        }
    }
    return dataSource;
}

@end

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
//                AIAlgNode *single = [SMGUtils searchObjectForPointer:checkPointer fileName:kFNNode time:cRTNode];
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
