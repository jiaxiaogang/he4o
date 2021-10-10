//
//  ThinkingUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "ThinkingUtils.h"
#import "AIKVPointer.h"
#import "AIFrontOrderNode.h"
#import "AICMVNode.h"
#import "AIMvFoManager.h"
#import "AIAbsCMVNode.h"
#import "AINetAbsFoNode.h"
#import "AIAbsAlgNode.h"
#import "AIAlgNode.h"
#import "AIPort.h"
#import "AINet.h"
#import "AINetUtils.h"
#import "AINetIndex.h"
#import "AINetIndexUtils.h"
#import "AIShortMatchModel.h"
#import "AIScore.h"
#import "TOAlgModel.h"
#import "ImvGoodModel.h"
#import "ImvBadModel.h"
#import "DemandModel.h"
#import "TOFoModel.h"

@implementation ThinkingUtils

/**
 *  MARK:--------------------更新能量值--------------------
 */
+(CGFloat) updateEnergy:(CGFloat)oriEnergy delta:(CGFloat)delta{
    oriEnergy += delta;
    return MAX(cMinEnergy, MIN(cMaxEnergy, oriEnergy));
}

+(AnalogyType) getInnerType:(AIKVPointer*)frontValue_p backValue_p:(AIKVPointer*)backValue_p{
    if (frontValue_p && backValue_p) {
        NSNumber *fValue = NUMTOOK([AINetIndex getData:frontValue_p]);
        NSNumber *bValue = NUMTOOK([AINetIndex getData:backValue_p]);
        if (fValue > bValue) {
            return ATLess;
        }else if(fValue < bValue){
            return ATGreater;
        }
    }
    return ATDefault;
}

/**
 *  MARK:--------------------atType转ds--------------------
 *  @version
 *      2021.09.23: 废弃,type集成到AIKVPointer后,ds不再充当type作用 (参考24019-使用部分-1);
 */
//+(NSString*) getAnalogyTypeDS:(AnalogyType)type{
//    if (type == ATDefault || type == ATSame) {
//        return DefaultDataSource;
//    }else{
//        return STRFORMAT(@"%ld",(long)type);
//    }
//}

/**
 *  MARK:--------------------ds转atType--------------------
 *  @version
 *      2021.09.23: 废弃,type集成到AIKVPointer后,ds不再充当type作用 (参考24019-使用部分-1);
 */
//+(AnalogyType) convertDS2AnalogyType:(NSString*)ds{
//    NSArray *tryResults = @[@(ATHav),@(ATNone),@(ATGreater),@(ATLess),@(ATSub),@(ATPlus),@(ATSame),@(ATDiff)];
//    for (NSNumber *tryResult in tryResults) {
//        if ([ATType2DS([tryResult intValue)] isEqualToString:ds]) {
//            return [tryResult intValue];
//        }
//    }
//    return ATDefault;
//}

+(AnalogyType) compare:(AIKVPointer*)valueA_p valueB_p:(AIKVPointer*)valueB_p{
    NSNumber *aValue = NUMTOOK([AINetIndex getData:valueA_p]);
    NSNumber *bValue = NUMTOOK([AINetIndex getData:valueB_p]);
    NSComparisonResult compareResult = [aValue compare:bValue];
    if (compareResult == NSOrderedDescending) {
        return ATLess;
    }else if (compareResult == NSOrderedAscending) {
        return ATGreater;
    }else{
        return ATDefault;
    }
}


@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (CMV) >
//MARK:===============================================================
@implementation ThinkingUtils (CMV)

+(BOOL) isBadWithAT:(NSString*)algsType{
    algsType = STRTOOK(algsType);
    if ([NSClassFromString(algsType) isSubclassOfClass:ImvBadModel.class]) {//饥饿感等
        return true;
    }else if ([NSClassFromString(algsType) isSubclassOfClass:ImvGoodModel.class]) {//爽感等;
        return false;
    }
    return false;
}

//是否有向下需求 (目标为下,但delta却+) (饿感上升)
+(BOOL) havDownDemand:(NSString*)algsType delta:(NSInteger)delta {
    BOOL isBad = [ThinkingUtils isBadWithAT:algsType];
    return isBad && delta > 0;
}

//是否有向上需求 (目标为上,但delta却-) (快乐下降)
+(BOOL) havUpDemand:(NSString*)algsType delta:(NSInteger)delta {
    BOOL isGood = ![ThinkingUtils isBadWithAT:algsType];
    return isGood && delta < 0;
}

//是否有任意需求;
+(BOOL) havDemand:(NSString*)algsType delta:(NSInteger)delta{
    return [self havDownDemand:algsType delta:delta] || [self havUpDemand:algsType delta:delta];
}

+(MVDirection) getDemandDirection:(NSString*)algsType delta:(NSInteger)delta {
    BOOL downDemand = [self havDownDemand:algsType delta:delta];
    BOOL upDemand = [self havUpDemand:algsType delta:delta];
    if (downDemand) {
        return MVDirection_Negative;
    }else if(upDemand){
        return MVDirection_Positive;
    }else{
        return MVDirection_None;
    }
}

/**
 *  MARK:--------------------转为direction--------------------
 */
//获取目标方向 (有了目标方向后,可根据此取索引)
+(MVDirection) getTargetDirection:(NSString*)algsType{
    algsType = STRTOOK(algsType);
    if ([NSClassFromString(algsType) isSubclassOfClass:ImvBadModel.class]) {//饥饿感等
        return MVDirection_Negative;
    }else if ([NSClassFromString(algsType) isSubclassOfClass:ImvGoodModel.class]) {//爽感等;
        return MVDirection_Positive;
    }
    return MVDirection_None;
}

//获取索引方向 (有了索引方向后,可供目标方向取用)
+(MVDirection) getMvReferenceDirection:(NSInteger)delta {
    //目前的索引就仅是按照delta正负来构建的;
    if (delta < 0) return MVDirection_Negative;
    else if(delta > 0) return MVDirection_Positive;
    else return MVDirection_None;
}

/**
 *  MARK:--------------------解析algsMVArr--------------------
 *  cmvAlgsArr->mvValue
 */
+(void) parserAlgsMVArrWithoutValue:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSString *algsType))success{
    //1. 数据
    AIKVPointer *delta_p = nil;
    AIKVPointer *urgentTo_p = 0;
    NSString *algsType = DefaultAlgsType;
    
    //2. 数据检查
    for (AIKVPointer *pointer in algsArr) {
        if ([NSClassFromString(pointer.algsType) isSubclassOfClass:ImvAlgsModelBase.class]) {
            if ([@"delta" isEqualToString:pointer.dataSource]) {
                delta_p = pointer;
            }else if ([@"urgentTo" isEqualToString:pointer.dataSource]) {
                urgentTo_p = pointer;
            }
        }
        algsType = pointer.algsType;
    }
    
    //3. 逻辑执行
    if (success) success(delta_p,urgentTo_p,algsType);
}

//cmvAlgsArr->mvValue
+(void) parserAlgsMVArr:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSInteger delta,NSInteger urgentTo,NSString *algsType))success{
    //1. 解析
    [self parserAlgsMVArrWithoutValue:algsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSString *algsType) {
        
        //2. 转换格式
        NSInteger delta = [NUMTOOK([AINetIndex getData:delta_p]) integerValue];
        NSInteger urgentTo = [NUMTOOK([AINetIndex getData:urgentTo_p]) integerValue];
        
        //3. 回调
        if (success) success(delta_p,urgentTo_p,delta,urgentTo,algsType);
    }];
}

@end




//MARK:===============================================================
//MARK:                     < ThinkingUtils (Association) >
//MARK:===============================================================
@implementation ThinkingUtils (Association)

+(id) getNodeFromPort:(AIPort*)port{
    if (port) {
        return [SMGUtils searchNode:port.target_p];
    }
    return nil;
}

//+(AIAlgNodeBase*) getMatchAlgWithProtoAlg:(AIAlgNodeBase*)protoAlg{
//    if (protoAlg) {
//        NSArray *absPorts = [AINetUtils absPorts_All:protoAlg];
//        if (absPorts.count == 1) {
//            AIPort *matchPort = ARR_INDEX(absPorts, 0);
//            return [SMGUtils searchNode:matchPort.target_p];
//        }
//    }
//    return nil;
//}

/**
 *  MARK:--------------------按照模糊匹配度排序--------------------
 *  @param maskValue_p  : 排序基准 (稀疏码) (在PM中传firstJustPValue过来);
 *  @param proto_ps     : 对proto_ps进行排序 (元素为概念);
 *  @desc 功能: 比如基准=d58, proto=[(d33),(d59),(a88)], 得到的结果result=[(d59),(d33)];
 *  @desc 性能: 含硬盘io操作,proto_ps每条元素,都要searchNode取alg;
 *  @version
 *      2021.01.01: 废弃,在PM_V3中,由值域求和来替代作评价 (参考2120A & n21p21);
 *  @result notnull
 */
+(NSArray*) getFuzzySortWithMaskValue:(AIKVPointer*)maskValue_p fromProto_ps:(NSArray*)proto_ps{
    //a. 对result2筛选出包含同标识value值的: result3;
    __block NSMutableArray *validConDatas = [[NSMutableArray alloc] init];
    [SMGUtils filterAlg_Ps:proto_ps valueIdentifier:maskValue_p.identifier itemValid:^(AIAlgNodeBase *alg, AIKVPointer *value_p) {
        NSNumber *value = [AINetIndex getData:value_p];
        if (alg && value) {
            [validConDatas addObject:@{@"a":alg,@"v":value}];
        }
    }];

    //b. 对result3进行取值value并排序: result4 (根据差的绝对值小的排前面);
    double pValue = [NUMTOOK([AINetIndex getData:maskValue_p]) doubleValue];
    NSArray *sortConDatas = [validConDatas sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        double v1 = [NUMTOOK([obj1 objectForKey:@"v"]) doubleValue];
        double v2 = [NUMTOOK([obj2 objectForKey:@"v"]) doubleValue];
        double absV1 = fabs(v1 - pValue);
        double absV2 = fabs(v2 - pValue);
        return absV1 > absV2 ? NSOrderedDescending : absV1 < absV2 ? NSOrderedAscending : NSOrderedSame;
    }];

    //c. 转成sortConAlgs
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *sortConData in sortConDatas) {
        AIAlgNodeBase *algNode = [sortConData objectForKey:@"a"];
        [result addObject:algNode];
    }

    //d. 调试日志
    for (AIAlgNodeBase *item in result) {
        if (Log4FuzzyAlg) NSLog(@"---> 同层基准:%@ => %@",Pit2FStr(maskValue_p),Alg2FStr(item));
    }
    return result;
}

//+(NSArray*) collectionNodes:(AIKVPointer*)node_p absLimit:(NSInteger)absLimit conLimit:(NSInteger)conLimit{
//    //1. 数据准备
//    NSMutableArray *result = [[NSMutableArray alloc] init];
//    AINodeBase *node = [SMGUtils searchNode:node_p];
//    if (!node) return result;
//    
//    //2. 收集本身
//    [result addObject:node_p];
//    
//    //3. 收集抽象
//    if (absLimit > 0) {
//        NSArray *abs_ps = [SMGUtils convertPointersFromPorts:[AINetUtils absPorts_All_Normal:node]];
//        [result addObjectsFromArray:ARR_SUB(abs_ps, 0, absLimit)];
//    }
//    
//    //4. 收集具象
//    if (conLimit > 0) {
//        NSArray *con_ps = [SMGUtils convertPointersFromPorts:[AINetUtils conPorts_All_Normal:node]];
//        [result addObjectsFromArray:ARR_SUB(con_ps, 0, conLimit)];
//    }
//    return result;
//}

//+(NSMutableArray*) collectionAlgRefs:(NSArray*)alg_ps itemRefLimit:(NSInteger)itemRefLimit except_p:(AIKVPointer*)except_p{
//    //1. 数据准备
//    alg_ps = ARRTOOK(alg_ps);
//    NSMutableArray *result = [[NSMutableArray alloc] init];
//    
//    //2. 收集
//    NSMutableArray *iRef_ps = [[NSMutableArray alloc] init];
//    for (AIKVPointer *item_p in alg_ps) {
//        AIAlgNodeBase *item = [SMGUtils searchNode:item_p];
//        NSArray *itemRefs = [SMGUtils convertPointersFromPorts:[AINetUtils refPorts_All4Alg_Normal:item]];
//        
//        //3. 去除不应期 & 保留itemRefLimit个;
//        if (except_p) [result removeObject:except_p];
//        [result addObjectsFromArray:ARR_SUB(itemRefs, 0, itemRefLimit)];
//    }
//    return result;
//}

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (In) >
//MARK:===============================================================
@implementation ThinkingUtils (In)

+(BOOL) dataIn_CheckMV:(NSArray*)algResult_ps{
    for (AIKVPointer *pointer in ARRTOOK(algResult_ps)) {
        if ([NSClassFromString(pointer.algsType) isSubclassOfClass:ImvAlgsModelBase.class]) {
            return true;
        }
    }
    return false;
}

//+(BOOL) sameOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
//    if (mv1_p && mv2_p && [mv1_p.algsType isEqualToString:mv2_p.algsType]) {
//        return [self sameIdenSameScore:mv1_p mv2:mv2_p];
//    }
//    return false;
//}

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Out) >
//MARK:===============================================================
@implementation ThinkingUtils (Out)

//+(CGFloat) dataOut_CheckScore_ExpOut:(AIPointer*)foNode_p {
//    //1. 数据
//    AIFoNodeBase *foNode = [SMGUtils searchNode:foNode_p];
//    
//    //2. 评价 (根据当前foNode的mv果,处理cmvNode评价影响力;(系数0.2))
//    CGFloat score = 0;
//    if (foNode) {
//        score = [AIScore score4MV:foNode.cmvNode_p ratio:0.2f];
//    }
//    return score;
//    
//    ////4. v1.0评价方式: (目前outLog在foAbsNode和index中,无法区分,所以此方法仅对foNode的foNode.out_ps直接抽象部分进行联想,作为可行性判定原由)
//    /////1. 取foNode的抽象节点absNodes;
//    //for (AIPort *absPort in ARRTOOK(foNode.absPorts)) {
//    //
//    //    ///2. 判断absNode是否是由out_ps抽象的 (根据"微信息"组)
//    //    AINetAbsFoNode *absNode = [SMGUtils searchObjectForPointer:absPort.target_p fileName:kFNNode time:cRTNode];
//    //    if (absNode) {
//    //        BOOL fromOut_ps = [SMGUtils containsSub_ps:absNode.content_ps parent_ps:out_ps];
//    //
//    //        ///3. 根据当前absNode的mv果,处理absCmvNode评价影响力;(系数0.2)
//    //        if (fromOut_ps) {
//    //            CGFloat scoreForce = [AIScore score4MV:absNode.cmvNode_p ratio:0.2f];
//    //            score += scoreForce;
//    //        }
//    //    }
//    //}
//}

+(id) scheme_GetAValidNode:(NSArray*)check_ps except_ps:(NSMutableArray*)except_ps checkBlock:(BOOL(^)(id checkNode))checkBlock{
    //1. 数据检查
    if (!ARRISOK(check_ps)) {
        return nil;
    }
    
    //2. 依次判断是否已排除
    for (AIPointer *fo_p in check_ps) {
        if (![SMGUtils containsSub_p:fo_p parent_ps:except_ps]) {
            
            //3. 未排除,返回;
            id result = [SMGUtils searchNode:fo_p];
            if (checkBlock) {
                if (checkBlock(result)) {
                    return result;
                }
            }else if(result){
                return result;
            }
        }
    }
    return nil;
}

+(NSArray*) foScheme_GetNextLayerPs:(NSArray*)curLayer_ps{
    return [self scheme_GetNextLayerPs:curLayer_ps getConPsBlock:^NSArray *(id curNode) {
        if (ISOK(curNode, AINetAbsFoNode.class)) {
            return [SMGUtils convertPointersFromPorts:ARR_SUB(((AINetAbsFoNode*)curNode).conPorts, 0, cDataOutAssFoCount)];
        }
        return nil;
    }];
}

+(NSArray*) algScheme_GetNextLayerPs:(NSArray*)curLayer_ps{
    return [self scheme_GetNextLayerPs:curLayer_ps getConPsBlock:^NSArray *(id curNode) {
        if (ISOK(curNode, AIAbsAlgNode.class)) {
            return [SMGUtils convertPointersFromPorts:ARR_SUB(((AIAbsAlgNode*)curNode).conPorts, 0, cDataOutAssAlgCount)];
        }
        return nil;
    }];
}

+(NSArray*) scheme_GetNextLayerPs:(NSArray*)curLayer_ps getConPsBlock:(NSArray*(^)(id))getConPsBlock{
    //1. 数据准备
    NSMutableArray *result = [[NSMutableArray alloc] init];
    curLayer_ps = ARRTOOK(curLayer_ps);
    
    //2. 每层向具象取前5条
    for (AIPointer *fo_p in curLayer_ps) {
        id curNode = [SMGUtils searchNode:fo_p];
        if (getConPsBlock) {
            NSArray *con_ps = ARRTOOK(getConPsBlock(curNode));
            [result addObjectsFromArray:con_ps];
        }
    }
    return result;
}

/**
 *  MARK:--------------------根据概念标识,获取概念的"有无大小"节点--------------------
 *  BUG记录190726:
 *      问题: 因概念节点中,algsType&dataSource多为@" ",导致无法准确定位到对应结果;
 *      解决: 在概念节点的create中,将@"{pId}"作为概念节点的algsType;
 */
//+(AIAlgNodeBase*) dataOut_GetAlgNodeWithInnerType:(AnalogyType)type algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
//    //1. 获取相应的微信息;
//    AIPointer *value_p = [theNet getNetDataPointerWithData:@(type) algsType:algsType dataSource:dataSource];
//
//    //2. 从微信息,联想refPorts绝对匹配的概念节点;
//    return [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValueP:value_p];
//}

/**
 *  MARK:--------------------PM算法获取有效SP概念--------------------
 *  @param curAlgs : 传入解决方案dsFo的当前截点alg 或 传入R任务的源rMatchFo的所有用于验证有效的contentAlgs (参考24053-方案);
 *  @desc
 *      1. 向性: 从右向左;
 *      2. 参考20206-步骤图-第1步
 *  @version
 *      2020.12.27: 把cPM_CheckSPFoLimit从3调整为100 (参考21207);
 *      2021.01.01: 返回由AIPinters改为AIPorts;
 *      2021.04.30: 修复返回结果有重复的BUG (参考23062);
 *      2021.10.10: 支持rMatchFo获取spPorts (参考24053-方案) (废弃,参考24053-实践1);
 */
+(NSArray*) pm_GetValidSPAlg_ps:(NSArray*)curAlgs curFo:(AIFoNodeBase*)curFo type:(AnalogyType)type{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (ARRISOK(curAlgs) && curFo && (type == ATSub || type == ATPlus)) {
        //1. 根据curFo取抽象SubFo3条,PlusFo3条;
        NSArray *spFo_ps = Ports2Pits([AINetUtils absPorts_All:curFo type:type]);
        spFo_ps = ARR_SUB(spFo_ps, 0, cPM_CheckSPFoLimit);
        NSArray *spFos = [SMGUtils searchNodes:spFo_ps];
        
        //2. 查对应在curAlg上是否长过教训S / 被助攻过P;
        NSMutableArray *spAlgPorts = [[NSMutableArray alloc] init];
        for (AIAlgNodeBase *curAlg in curAlgs) {
            spAlgPorts = [SMGUtils collectArrA_NoRepeat:spAlgPorts arrB:[AINetUtils absPorts_All:curAlg type:type]];
        }
        
        //3. 从algSPs中,筛选有效的部分validAlgSPs
        result = [SMGUtils filterArr:spAlgPorts checkValid:^BOOL(AIPort *item) {
            for (AIFoNodeBase *spFo in spFos) {
                if ([spFo.content_ps containsObject:item.target_p]) {
                    return true;
                }
            }
            return false;
        }];
    }
    return result;
}

/**
 *  MARK:--------------------取reModel--------------------
 *  @version
 *      2021.05.19: 改为取末位,比如距离从20->10->0,最终P反省时,更重要的是给距0加分;
 *      2021.05.19: 改回取首位,因为F15[A8]中本来就包含距0,所以即使不给距0加分,也不影响觅食训练;
 *      2021.05.19: 改回取末位,因为以最终稀疏码为准,比如Y30时已经开始飞,飞的过程中Y跟着变成了Y0,Y0为P不表示Y30也为P,所以末位更准确;
 */
+(TOAlgModel*) analogyReasonRethink_GetFirstReModelIfHav:(TOAlgModel*)baseAlg{
    if (ISOK(baseAlg, TOAlgModel.class)) {
        TOAlgModel *reModel = ARR_INDEX_REVERSE(baseAlg.subModels, 0);
        if (ISOK(reModel, TOAlgModel.class)) {
            if (baseAlg.subModels.count > 1) {
                //TODO: 当reModel条数>1时,比如距20,距10各一条,那么在ORT中应该可以都支持;
                //1. 更全面的发现X368和X378都ok;
                //2. 全面发现距20距10全修正了,不影响;
                //3. 暂时先不做,随后有空再做;
                WLog(@"--------->>> 反省类比取reModel时,subModels长度>1,看是否需要更全面处理>1的情况");
            }
            return reModel;
        }
    }
    return baseAlg;
}

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Contains) >
//MARK:===============================================================
@implementation ThinkingUtils (Contains)

+(BOOL) containsConAlg:(AIKVPointer*)conAlg_p absAlg:(AIPointer*)absAlg_p{
    //1. 判定有效
    if (conAlg_p && absAlg_p) {
        
        //2. 判断memConPorts是否指向conAlg_p (absAlg有具象指向:conAlg_p);
        NSArray *memConPorts = [SMGUtils searchObjectForPointer:absAlg_p fileName:kFNMemConPorts time:cRTMemPort];
        NSArray *memCon_ps = [SMGUtils convertPointersFromPorts:memConPorts];
        if ([SMGUtils containsSub_p:conAlg_p parent_ps:memCon_ps]) {
            return true;
        }
        
        //3. 判断硬盘absAlg.conPorts (absAlg有具象指向:conAlg_p);
        AIAbsAlgNode *absAlg = [SMGUtils searchNode:absAlg_p];
        if (ISOK(absAlg, AIAbsAlgNode.class)) {
            NSArray *hdCon_ps = [SMGUtils convertPointersFromPorts:absAlg.conPorts];
            if ([SMGUtils containsSub_p:conAlg_p parent_ps:hdCon_ps]) {
                return true;
            }
        }
    }
    return false;
}

@end

//MARK:===============================================================
//MARK:                     < ThinkingUtils (Demand) >
//MARK:===============================================================
@implementation ThinkingUtils (Demand)

/**
 *  MARK:--------------------收集当前demand可适用于别的任务--------------------
 *  @desc demand下dsFo为finish/actYes状态时,收集它能解决的所有问题
 *  @version
 *      2021.08.15: 不止ActYes,扩展本方法对Runing的支持 (参考23217);
 */
+(NSMutableArray*) collectDiffBaseFoWhenDSFoIsFinishOrActYes:(DemandModel*)curDemand{
    //1. 数据检查;
    NSMutableArray *diffBaseFo_ps = [[NSMutableArray alloc] init];
    if (!curDemand) return diffBaseFo_ps;
    
    //2. 对curDemands.actionFoModels下的dsFo做逐一判断;
    for (TOFoModel *dsFoModel in curDemand.actionFoModels) {
        
        //3. 检查dsFo是否为actYes状态;
        NSArray *subActYes = [TOUtils getSubOutModels_AllDeep:dsFoModel validStatus:@[@(TOModelStatus_ActYes),@(TOModelStatus_Runing)] cutStopStatus:@[@(TOModelStatus_ActNo),@(TOModelStatus_ScoreNo)]];
        
        //4. 当dsFo为finish或actYes状态时,将diffBasePorts收集到返回结果中;
        if (dsFoModel.status == TOModelStatus_Finish || ARRISOK(subActYes)) {
            AIFoNodeBase *dsFo = [SMGUtils searchNode:dsFoModel.content_p];
            [diffBaseFo_ps addObjectsFromArray:Ports2Pits(dsFo.diffBasePorts)];
        }
    }
    return diffBaseFo_ps;
}

@end
