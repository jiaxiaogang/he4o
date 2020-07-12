//
//  ThinkingUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "ThinkingUtils.h"
#import "AIKVPointer.h"
#import "ImvAlgsModelBase.h"
#import "ImvAlgsHungerModel.h"
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

+(NSString*) getAnalogyTypeDS:(AnalogyType)type{
    if (type == ATDefault || type == ATSame) {
        return DefaultDataSource;
    }else{
        return STRFORMAT(@"%ld",(long)type);
    }
}

+(AnalogyType) getInnerTypeWithScore:(CGFloat)score{
    if (score > 0) {
        return ATPlus;
    }else if(score < 0){
        return ATSub;
    }
    return ATDefault;
}

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

+(AITargetType) getTargetType:(MVType)type{
    if(type == MVType_Hunger){
        return AITargetType_Down;
    }else if(type == MVType_Anxious){
        return AITargetType_Down;
    }else{
        return AITargetType_None;
    }
}

+(AITargetType) getTargetTypeWithAlgsType:(NSString*)algsType{
    algsType = STRTOOK(algsType);
    if([algsType isEqualToString:NSStringFromClass(ImvAlgsHungerModel.class)]){//饥饿感
        return AITargetType_Down;
    }
    return AITargetType_None;
}

+(MindHappyType) checkMindHappy:(NSString*)algsType delta:(NSInteger)delta{
    //1. 数据
    AITargetType targetType = [ThinkingUtils getTargetTypeWithAlgsType:algsType];
    
    //2. 判断返回结果
    if (targetType == AITargetType_Down) {
        return delta < 0 ? MindHappyType_Yes : delta > 0 ? MindHappyType_No : MindHappyType_None;
    }else if(targetType == AITargetType_Up){
        return delta > 0 ? MindHappyType_Yes : delta < 0 ? MindHappyType_No : MindHappyType_None;
    }
    return MindHappyType_None;
}

//是否有向下需求 (目标为下,但delta却+)
+(BOOL) havDownDemand:(NSString*)algsType delta:(NSInteger)delta {
    AITargetType targetType = [ThinkingUtils getTargetTypeWithAlgsType:algsType];
    return targetType == AITargetType_Down && delta > 0;
}

//是否有向上需求 (目标为上,但delta却-)
+(BOOL) havUpDemand:(NSString*)algsType delta:(NSInteger)delta {
    AITargetType targetType = [ThinkingUtils getTargetTypeWithAlgsType:algsType];
    return targetType == AITargetType_Up && delta < 0;
}

+(MVDirection) havDemand:(NSString*)algsType delta:(NSInteger)delta {
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
 *  @param maskValue_p  : 排序基准 (稀疏码);
 *  @param proto_ps     : 对proto_ps进行排序 (元素为概念);
 *  @desc 功能: 比如基准=d58, proto=[(d33),(d59),(a88)], 得到的结果result=[(d59),(d33)];
 *  @desc 性能: 含硬盘io操作,proto_ps每条元素,都要searchNode取alg;
 *  @result notnull
 */
+(NSArray*) getFuzzySortWithMaskValue:(AIKVPointer*)maskValue_p fromProto_ps:(NSArray*)proto_ps{
    //a. 对result2筛选出包含同标识value值的: result3;
    __block NSMutableArray *validConDatas = [[NSMutableArray alloc] init];
    [ThinkingUtils filterAlg_Ps:proto_ps valueIdentifier:maskValue_p.identifier itemValid:^(AIAlgNodeBase *alg, AIKVPointer *value_p) {
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

+(AIAlgNodeBase*) createHdAlgNode_NoRepeat:(NSArray*)value_ps{
    return [theNet createAbsAlg_NoRepeat:value_ps conAlgs:nil isMem:false isOut:false];
}
+(AINetAbsFoNode*)createAbsFo_NoRepeat_General:(NSArray*)conFos content_ps:(NSArray*)content_ps ds:(NSString*)ds difStrong:(NSInteger)difStrong{
    //1. 数据准备
    //AINetAbsFoNode *result = nil;
    //if (ARRISOK(conFos) && ARRISOK(content_ps)) {
    //    //2. 有则加强;
    //    AIFoNodeBase *absoluteFo = [AINetIndexUtils getAbsoluteMatchingFoNodeWithContent_ps:content_ps except_ps:conFos isMem:false];
    //    if (ISOK(absoluteFo, AINetAbsFoNode.class)) {
    //        result = (AINetAbsFoNode*)absoluteFo;
    //        [AINetUtils relateFoAbs:result conNodes:conFos isNew:false];
    //        [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
    //    }else{
    //        //3. 无则构建
    //        result = [theNet createAbsFo_General:conFos content_ps:content_ps difStrong:difStrong ds:ds];
    //    }
    //}
    //return result;
    return [theNet createAbsFo_General:conFos content_ps:content_ps difStrong:difStrong ds:ds];
}
//+(AIFrontOrderNode*)createConFo_NoRepeat_General:(NSArray*)content_ps isMem:(BOOL)isMem{
//    //1. 数据准备
//    AIFrontOrderNode *result = nil;
//    if (ARRISOK(content_ps)) {
//        //2. 有则加强;
//        AIFoNodeBase *localFo = [AINetIndexUtils getAbsoluteMatchingFoNodeWithContent_ps:content_ps except_ps:nil isMem:false];
//        if (ISOK(localFo, AIFrontOrderNode.class)) {
//            result = (AIFrontOrderNode*)localFo;
//            [AINetUtils insertRefPorts_AllFoNode:result.pointer order_ps:result.content_ps ps:result.content_ps];
//        }else{
//            //3. 无则构建
//            result = [theNet createConFo:content_ps isMem:isMem];
//        }
//    }
//    return result;
//}

//+(BOOL) sameOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
//    if (mv1_p && mv2_p && [mv1_p.algsType isEqualToString:mv2_p.algsType]) {
//        return [self sameScoreOfMV1:mv1_p mv2:mv2_p];
//    }
//    return false;
//}
+(BOOL) sameScoreOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
    if (mv1_p && mv2_p) {
        CGFloat mScore = [ThinkingUtils getScoreForce:mv1_p ratio:1.0f];
        CGFloat sScore = [ThinkingUtils getScoreForce:mv2_p ratio:1.0f];
        BOOL isSame = ((mScore > 0 && sScore > 0) || (mScore < 0 && sScore < 0));
        return isSame;
    }
    return false;
}
+(BOOL) sameOfScore1:(CGFloat)score1 score2:(CGFloat)score2{
    BOOL isSame = ((score1 > 0 && score2 > 0) || (score1 < 0 && score2 < 0));
    return isSame;
}

+(BOOL) diffScoreOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p{
    if (mv1_p && mv2_p) {
        CGFloat mScore = [ThinkingUtils getScoreForce:mv1_p ratio:1.0f];
        CGFloat pScore = [ThinkingUtils getScoreForce:mv2_p ratio:1.0f];
        return [self diffOfScore1:mScore score2:pScore];
    }
    return false;
}
+(BOOL) diffOfScore1:(CGFloat)score1 score2:(CGFloat)score2{
    BOOL isDiff = ((score1 > 0 && score2 < 0) || (score1 < 0 && score2 > 0));
    return isDiff;
}

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Out) >
//MARK:===============================================================
@implementation ThinkingUtils (Out)

+(CGFloat) dataOut_CheckScore_ExpOut:(AIPointer*)foNode_p {
    //1. 数据
    AIFoNodeBase *foNode = [SMGUtils searchNode:foNode_p];
    
    //2. 评价 (根据当前foNode的mv果,处理cmvNode评价影响力;(系数0.2))
    CGFloat score = 0;
    if (foNode) {
        score = [ThinkingUtils getScoreForce:foNode.cmvNode_p ratio:0.2f];
    }
    return score;
    
    ////4. v1.0评价方式: (目前outLog在foAbsNode和index中,无法区分,所以此方法仅对foNode的foNode.out_ps直接抽象部分进行联想,作为可行性判定原由)
    /////1. 取foNode的抽象节点absNodes;
    //for (AIPort *absPort in ARRTOOK(foNode.absPorts)) {
    //
    //    ///2. 判断absNode是否是由out_ps抽象的 (根据"微信息"组)
    //    AINetAbsFoNode *absNode = [SMGUtils searchObjectForPointer:absPort.target_p fileName:kFNNode time:cRTNode];
    //    if (absNode) {
    //        BOOL fromOut_ps = [SMGUtils containsSub_ps:absNode.content_ps parent_ps:out_ps];
    //
    //        ///3. 根据当前absNode的mv果,处理absCmvNode评价影响力;(系数0.2)
    //        if (fromOut_ps) {
    //            CGFloat scoreForce = [ThinkingUtils getScoreForce:absNode.cmvNode_p ratio:0.2f];
    //            score += scoreForce;
    //        }
    //    }
    //}
}

+(CGFloat) getScoreForce:(AIPointer*)cmvNode_p ratio:(CGFloat)ratio{
    AICMVNodeBase *cmvNode = [SMGUtils searchNode:cmvNode_p];
    if (ISOK(cmvNode, AICMVNodeBase.class)) {
        return [ThinkingUtils getScoreForce:cmvNode.pointer.algsType urgentTo_p:cmvNode.urgentTo_p delta_p:cmvNode.delta_p ratio:ratio];
    }
    return 0;
}

+(CGFloat) getScoreForce:(NSString*)algsType urgentTo_p:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p ratio:(CGFloat)ratio{
    //1. 检查absCmvNode是否顺心
    NSInteger delta = [NUMTOOK([AINetIndex getData:delta_p]) integerValue];
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:urgentTo_p]) integerValue];
    return [self getScoreForce:algsType urgentTo:urgentTo delta:delta ratio:ratio];
}

+(CGFloat) getScoreForce:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta ratio:(CGFloat)ratio{
    //1. 检查absCmvNode是否顺心
    MindHappyType type = [ThinkingUtils checkMindHappy:algsType delta:delta];
    
    //2. 根据检查到的数据取到score;
    ratio = MIN(1,MAX(ratio,0));
    if (type == MindHappyType_Yes) {
        return urgentTo * ratio;
    }else if(type == MindHappyType_No){
        return  -urgentTo * ratio;
    }
    return 0;
}

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
+(AIAlgNodeBase*) dataOut_GetAlgNodeWithInnerType:(AnalogyType)type algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    //1. 获取相应的微信息;
    AIPointer *value_p = [theNet getNetDataPointerWithData:@(type) algsType:algsType dataSource:dataSource];
    
    //2. 从微信息,联想refPorts绝对匹配的概念节点;
    return [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValueP:value_p];
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
//MARK:                     < ThinkingUtils (Filter) >
//MARK:===============================================================
@implementation ThinkingUtils (Filter)

+(NSArray*) filterPointers:(NSArray*)proto_ps isOut:(BOOL)isOut{
    return [SMGUtils filterPointers:proto_ps checkValid:^BOOL(AIKVPointer *item_p) {
        return item_p.isOut == isOut;
    }];
}

+(NSArray*) filterPointer:(NSArray*)from_ps identifier:(NSString*)identifier{
    return [SMGUtils filterPointers:from_ps checkValid:^BOOL(AIKVPointer *item_p) {
        return [identifier isEqualToString:item_p.identifier];
    }];
}

+(NSArray*) filterAlg_Ps:(NSArray*)alg_ps valueIdentifier:(NSString*)valueIdentifier itemValid:(void(^)(AIAlgNodeBase *alg,AIKVPointer *value_p))itemValid{
    return [SMGUtils filterPointers:alg_ps checkValid:^BOOL(AIKVPointer *item_p) {
        AIAlgNodeBase *alg = [SMGUtils searchNode:item_p];
        if (alg) {
            for (AIKVPointer *itemValue_p in alg.content_ps) {
                if ([valueIdentifier isEqualToString:itemValue_p.identifier]) {
                    itemValid(alg,itemValue_p);
                    return true;
                }
            }
        }
        return false;
    }];
}

@end
