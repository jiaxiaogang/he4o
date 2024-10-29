//
//  AIAlgNodeManager.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/12/14.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAlgNodeManager.h"

@implementation AIAlgNodeManager

/**
 *  MARK:--------------------构建抽象概念--------------------
 *  @param value_ps     : 要构建absAlgNode的content_ps (稀疏码组) notnull;
 *  @param conAlgs      : 具象AIAlgNode数组:(外类比时的algA&algB / 内类比时仅有一个元素) //不可为空数组
 *  _param dataSource   : 概念节点的dataSource就是稀疏码信息的algsType; (不传时,从algsArr提取) (废弃,参考24021);
 *  @param ds           : 为nil时,默认为DefaultDataSource;
 *  @param isOutBlock   : 指定isOut (默认从conAlgs获取) (概念节点的isOut状态; (思维控制器知道它是行为还是认知));
 *
 *  @问题记录:
 *    1. 思考下,conAlgs中去重,能不能将md5匹配的conAlg做为absAlg的问题?
 *      a. 不能: (参考: 思考计划2/191126更新表)
 *      b. 能: (则导致会形成坚果是坚果的多层抽象)
 *      c. 结论: 能,问题转移到n17p19
 *  注: TODO:判断algSames是否就是algsA或algB本身; (等conAlgNode和absAlgNode统一不区分后,再判断本身)
 *  @version
 *      2021.01.03: 判断abs已存在抽象节点时,加上ATDS的匹配判断,因为不同类型节点不必去重 (参考2120B-BUG2);
 *      2021.09.26: 从conAlgs中防重返回时,要判断at&ds&type (参考24022-BUG3);
 *  @result notnull
 */
+(AIAbsAlgNode*) createAbsAlgNode:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs at:(NSString*)at ds:(NSString*)ds isOutBlock:(BOOL(^)())isOutBlock type:(AnalogyType)type{
    //1. 数据准备
    BOOL isOut = isOutBlock ? isOutBlock() : [AINetUtils checkAllOfOut:conAlgs];
    conAlgs = ARRTOOK(conAlgs);
    value_ps = ARRTOOK(value_ps);
    if (!at) at = DefaultAlgsType;
    if (!ds) ds = DefaultDataSource;
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
            if ([samesMd5 isEqualToString:checkMd5] && [checkNode.pointer.algsType isEqualToString:at] && [checkNode.pointer.dataSource isEqualToString:ds] && checkNode.pointer.type == type) {
                
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
                if ([samesMd5 isEqualToString:absPort.header] && [absPort.target_p.algsType isEqualToString:at] && [absPort.target_p.dataSource isEqualToString:ds] && absPort.target_p.type == type) {
                    AIAbsAlgNode *absNode = [SMGUtils searchNode:absPort.target_p];
                    
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
        result.pointer = [SMGUtils createPointerForAlg:kPN_ALG_ABS_NODE at:at dataSource:ds isOut:isOut type:type];
        
        //4. 概念是否交层,可以使用长度来判断 (有一条conAlg为交层 或 当前sames长度小于具象特征数 => 则当前为交层) (参考33111-TODO1);
        result.pointer.isJiao = [SMGUtils filterSingleFromArr:conAlgs checkValid:^BOOL(AIAlgNodeBase *item) {
            return item.pointer.isJiao || sortSames.count < item.count;
        }];
        
        [result setContent_ps:sortSames];
        NSLog(@"构建新概念:A%ld fromConAlgs:%@",result.pointer.pointerId,CLEANSTR([SMGUtils convertArr:conAlgs convertBlock:^id(AIAlgNodeBase *obj) {
            return STRFORMAT(@"A%ld",obj.pointer.pointerId);
        }]));
    }
    
    //4. value.refPorts (更新/加强微信息的引用序列)
    NSInteger difStrong = 1;//absIsNew ? validConAlgs.count : 1;//20200106改回1,自由竞争无论是抽象还是具象;世上没有两片一样的树叶,所以对于抽象来说,本来就是讨便宜,易联想匹配的;
    [AINetUtils insertRefPorts_AllAlgNode:result.pointer content_ps:result.content_ps difStrong:difStrong];
    
    //5. 关联 & 存储
    [AINetUtils relateAlgAbs:result conNodes:validConAlgs isNew:absIsNew];
    //[theApp.heLogView addLog:STRFORMAT(@"构建抽象概念:%@,内容:%@",result.pointer.identifier,Alg2FStr(result))];
    [SMGUtils insertNode:result];
    return result;
}

/**
 *  MARK:--------------------构建抽象概念_防重--------------------
 *  @todo
 *      2021.04.25: alg暂不支持对ds不同区间的防重,以后可考虑支持 (参考getAbsoluteMatching_General的ds参数);
 *  @version
 *      2021.08.06: 本地去重,支持ds防重,因为不去重导致同内容的S和P混乱 (参考23205);
 *      2021.09.22: 支持type防重 (参考24019);
 */
+(AIAbsAlgNode*)createAbsAlg_NoRepeat:(NSArray*)value_ps conAlgs:(NSArray*)conAlgs at:(NSString*)at ds:(NSString*)ds isOutBlock:(BOOL(^)())isOutBlock type:(AnalogyType)type{
    //1. 数据检查
    value_ps = ARRTOOK(value_ps);
    NSArray *sort_ps = [SMGUtils sortPointers:value_ps];
    if (!at) at = DefaultAlgsType;
    if (!ds) ds = DefaultDataSource;
    
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
    } at:at ds:ds type:type];
    
    //3. 有则加强;
    if (ISOK(localAlg, AIAbsAlgNode.class)) {
        [AINetUtils relateAlgAbs:localAlg conNodes:conAlgs isNew:false];
        return localAlg;
    }else{
        //4. 无则构建
        return [self createAbsAlgNode:value_ps conAlgs:conAlgs at:at ds:ds isOutBlock:isOutBlock type:type];
    }
}

///**
// *  MARK:--------------------构建空概念_防重 (参考29027-方案3)--------------------
// *  @version
// *      2023.03.31: 迭代空概念防重机制为场景内同抽象仅生成一条空概念 (参考29044-todo1 & todo2);
// *      2023.04.01: 废弃原来的ds防重,因为它无效 (参考29044-todo3);
// *      2023.04.01: 废弃ds拼接,因为它本来也没啥用了 (参数29044-todo4);
// *  @result notnull
// */
//+(AIAlgNodeBase*)createEmptyAlg_NoRepeat:(NSArray*)conAlgs {
//    //1. 当有一条是空概念 && 且别的都已经抽象指向它时 => 则复用 (参考29044-todo2);
//    AIAlgNodeBase *localAlg = nil;
//    for (AIAlgNodeBase *conAlgA in conAlgs) {
//        if (!ARRISOK(conAlgA.content_ps) && !ARRISOK([SMGUtils filterSingleFromArr:conAlgs checkValid:^BOOL(AIAlgNodeBase *item) {
//            return ![TOUtils mIsC_1:item.pointer c:conAlgA.pointer];
//        }])) {
//            localAlg = conAlgA;
//            break;
//        }
//    }
//    
//    //2. 根据具象conAlgs取得共同抽象;
//    NSArray *absAlgPorts = nil;
//    for (AIAlgNodeBase *conAlg in conAlgs) {
//        NSArray *itemAbsPorts = [AINetUtils absPorts_All:conAlg];
//        if (!absAlgPorts) {
//            absAlgPorts = itemAbsPorts;
//        } else {
//            absAlgPorts = [SMGUtils filterArrA:itemAbsPorts arrB:absAlgPorts];
//        }
//    }
//    [AITest test24:absAlgPorts];
//    
//    if (!localAlg) {
//        //3. 从共同抽象中找已有空概念: 防重 (参考29044-todo1);
//        AIPort *localPort = [SMGUtils filterSingleFromArr:absAlgPorts checkValid:^BOOL(AIPort *item) {
//            return [item.header isEqualToString:[NSString md5:@""]];
//        }];
//        if (localPort) {
//            localAlg = [SMGUtils searchNode:localPort.target_p];
//        }
//    }
//    
//    //4. 找到本地防重的则加强: 具象指向conAlgs & 抽象指向absAlgs (参考29031-todo2 & todo3);
//    if (ISOK(localAlg, AIAlgNodeBase.class)) {
//        [AINetUtils relateAlgAbs:localAlg conNodes:conAlgs isNew:false];
//        [AINetUtils relateGeneralCon:localAlg absNodes:Ports2Pits(absAlgPorts)];
//        return localAlg;
//    }
//    
//    //5. 无则构建: 具象指向conAlgs(在构建方法已集成) & 抽象指向absAlgs (参考29031-todo1 & todo3);
//    AIAlgNodeBase *createAlg = [self createAbsAlgNode:@[] conAlgs:conAlgs at:nil ds:DefaultDataSource isOutBlock:nil type:ATDefault];
//    [AINetUtils relateGeneralCon:createAlg absNodes:Ports2Pits(absAlgPorts)];
//    return createAlg;
//}

@end
