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
#import "AICMVManager.h"
#import "AIAbsCMVNode.h"
#import "AINetAbsFoNode.h"
#import "AIAbsAlgNode.h"
#import "AIAlgNode.h"
#import "AIPort.h"
#import "AINet.h"

@implementation ThinkingUtils

/**
 *  MARK:--------------------更新能量值--------------------
 */
+(NSInteger) updateEnergy:(NSInteger)oriEnergy delta:(NSInteger)delta{
    oriEnergy += delta;
    return MAX(cMinEnergy, MIN(cMaxEnergy, oriEnergy));
}

+(NSArray*) filterOutPointers:(NSArray*)proto_ps{
    NSMutableArray *out_ps = [[NSMutableArray alloc] init];
    for (AIKVPointer *pointer in ARRTOOK(proto_ps)) {
        if (ISOK(pointer, AIKVPointer.class) && pointer.isOut) {
            [out_ps addObject:pointer];
        }
    }
    return out_ps;
}

+(NSArray*) filterNotOutPointers:(NSArray*)proto_ps{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (AIKVPointer *pointer in ARRTOOK(proto_ps)) {
        if (ISOK(pointer, AIKVPointer.class) && !pointer.isOut) {
            [result addObject:pointer];
        }
    }
    return result;
}

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Analogy) >
//MARK:===============================================================
@implementation ThinkingUtils (Analogy)

+(NSArray*) analogyOrdersA:(NSArray*)ordersA ordersB:(NSArray*)ordersB canAss:(BOOL(^)())canAssBlock buildAlgNode:(AIAbsAlgNode*(^)(NSArray* algSames,AIAlgNode *algA,AIAlgNode *algB))buildAlgNodeBlock{
    //1. 类比orders的规律
    NSMutableArray *orderSames = [[NSMutableArray alloc] init];
    if (ARRISOK(ordersA) && ARRISOK(ordersB)) {
        for (AIKVPointer *algNodeA_p in ordersA) {
            for (AIKVPointer *algNodeB_p in ordersB) {
                //2. A与B直接一致则直接添加 & 不一致则如下代码;
                if ([algNodeA_p isEqual:algNodeB_p]) {
                    [orderSames addObject:algNodeA_p];
                    break;
                }else{
                    ///1. 则检查能量值;
                    if (!canAssBlock || !canAssBlock()) {
                        break;
                    }
                    
                    ///2. 能量值足够,则取出algNodeA & algNodeB
                    AIAlgNode *algNodeA = [SMGUtils searchObjectForPointer:algNodeA_p fileName:FILENAME_Node time:cRedisNodeTime];
                    AIAlgNode *algNodeB = [SMGUtils searchObjectForPointer:algNodeB_p fileName:FILENAME_Node time:cRedisNodeTime];
                    
                    ///3. values->absPorts的认知过程
                    if (algNodeA && algNodeB) {
                        NSMutableArray *algSames = [[NSMutableArray alloc] init];
                        for (AIKVPointer *valueA_p in algNodeA.value_ps) {
                            for (AIKVPointer *valueB_p in algNodeB.value_ps) {
                                if ([valueA_p isEqual:valueB_p] && ![algSames containsObject:valueB_p]) {
                                    [algSames addObject:valueB_p];
                                    break;
                                }
                            }
                        }
                        if (buildAlgNodeBlock && ARRISOK(algSames)) {
                            buildAlgNodeBlock(algSames,algNodeA,algNodeB);
                        }
                    }
                    
                    ///4. absPorts->orderSames (根据强度优先)
                    for (AIPort *aPort in algNodeA.absPorts) {
                        for (AIPort *bPort in algNodeB.absPorts) {
                            if ([aPort.target_p isEqual:bPort.target_p]) {
                                [orderSames addObject:bPort.target_p];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return orderSames;
}

+(void) analogyInnerOrders:(NSArray*)orders buildAbsAlgBlock:(AIAbsAlgNode*(^)(NSArray* algSames,AIAlgNode *conAlg))buildAbsAlgBlock buildAbsFoBlock:(AINetAbsFoNode*(^)(NSArray* orderSames))buildAbsFoBlock{
    
}

+(BOOL) analogySubWithExpOrder:(NSArray*)expOrder checkOrder:(NSArray*)checkOrder canAss:(BOOL(^)())canAssBlock checkAlgNode:(BOOL(^)(NSArray* algSames,AIAlgNode *algA,AIAlgNode *algB))checkAlgNodeBlock{
    
    
    //1. 对当前解决方案的时序信息expOrder,与当前已有的条件checkOrder进行类比;
    
    //2. 将未能达到的条件,进行checkAlgNode,并进行联想解决方式; (微信息a=1,飞行,微信息a=2);
    
    //3. 直到所有的条件,都可以转换为out行为时;返回true;
    
    //4. 当中途有一个canAss为false时,则整体失败,返回false;
    
    //5. 当中途有一个条件无法转换为out行为时,则整体失败,返回false;
    
    
    return false;
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

+(BOOL) getDemand:(NSString*)algsType delta:(NSInteger)delta complete:(void(^)(BOOL upDemand,BOOL downDemand))complete{
    //1. 数据
    AITargetType targetType = [ThinkingUtils getTargetTypeWithAlgsType:algsType];
    BOOL downDemand = targetType == AITargetType_Down && delta > 0;
    BOOL upDemand = targetType == AITargetType_Up && delta < 0;
    //2. 有需求思考解决
    if (complete) {
        complete(upDemand,downDemand);
    }
    return downDemand || upDemand;
}


/**
 *  MARK:--------------------解析algsMVArr--------------------
 *  cmvAlgsArr->mvValue
 */
+(void) parserAlgsMVArrWithoutValue:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSString *algsType))success{
    //1. 数据
    AIKVPointer *delta_p = nil;
    AIKVPointer *urgentTo_p = 0;
    NSString *algsType = @"";
    
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
    //1. 数据
    __block AIKVPointer *delta_p = nil;
    __block AIKVPointer *urgentTo_p = nil;
    __block NSInteger delta = 0;
    __block NSInteger urgentTo = 0;
    __block NSString *algsType = @"";
    
    //2. 数据检查
    [self parserAlgsMVArrWithoutValue:algsArr success:^(AIKVPointer *findDelta_p, AIKVPointer *findUrgentTo_p, NSString *findAlgsType) {
        delta_p = findDelta_p;
        urgentTo_p = findUrgentTo_p;
        delta = [NUMTOOK([SMGUtils searchObjectForPointer:delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
        urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
        algsType = findAlgsType;
    }];
    
    //3. 逻辑执行
    if (success) success(delta_p,urgentTo_p,delta,urgentTo,algsType);
}

+(CGFloat) getScoreForce:(AIPointer*)cmvNode_p ratio:(CGFloat)ratio{
    AICMVNodeBase *cmvNode = [SMGUtils searchObjectForPointer:cmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    if (ISOK(cmvNode, AICMVNodeBase.class)) {
        return [ThinkingUtils getScoreForce:cmvNode.pointer.algsType urgentTo_p:cmvNode.urgentTo_p delta_p:cmvNode.delta_p ratio:ratio];
    }
    return 0;
}

+(CGFloat) getScoreForce:(NSString*)algsType urgentTo_p:(AIPointer*)urgentTo_p delta_p:(AIPointer*)delta_p ratio:(CGFloat)ratio{
    //1. 检查absCmvNode是否顺心
    NSInteger urgentTo = [NUMTOOK([SMGUtils searchObjectForPointer:urgentTo_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
    NSInteger delta = [NUMTOOK([SMGUtils searchObjectForPointer:delta_p fileName:FILENAME_Value time:cRedisValueTime]) integerValue];
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


@end




//MARK:===============================================================
//MARK:                     < ThinkingUtils (Association) >
//MARK:===============================================================
@implementation ThinkingUtils (Association)


//+(NSArray*) getFrontOrdersFromCmvNode:(AICMVNode*)cmvNode{
//    AIFrontOrderNode *foNode = [self getFoNodeFromCmvNode:cmvNode];
//    if (foNode) {
//        return foNode.orders_kvp;//out是不能以数组处理foNode.orders_p的,下版本改)
//    }
//    return nil;
//}

+(AIFrontOrderNode*) getFoNodeFromCmvNode:(AICMVNode*)cmvNode{
    if (ISOK(cmvNode, AICMVNode.class)) {
        //2. 取"解决经验"对应的前因时序列;
        AIFrontOrderNode *foNode = [SMGUtils searchObjectForPointer:cmvNode.foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        return foNode;
    }
    return nil;
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

+(NSArray*) algModelConvert2Pointers:(NSObject*)algsModel{
    NSArray *algsArr = [[AINet sharedInstance] getAlgsArr:algsModel];
    return algsArr;
}

+(AIPointer*) createAlgNodeWithValue_ps:(NSArray*)value_ps isOut:(BOOL)isOut{
    AIAlgNode *algNode = [theNet createAlgNode:value_ps isOut:isOut];
    if (algNode) {
        return algNode.pointer;
    }
    return nil;
}

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Out) >
//MARK:===============================================================
@implementation ThinkingUtils (Out)

+(CGFloat) dataOut_CheckScore_ExpOut:(AIPointer*)foNode_p {
    //1. 数据
    AIFoNodeBase *foNode = [SMGUtils searchObjectForPointer:foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    
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
    //    AINetAbsFoNode *absNode = [SMGUtils searchObjectForPointer:absPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
    //    if (absNode) {
    //        BOOL fromOut_ps = [SMGUtils containsSub_ps:absNode.orders_kvp parent_ps:out_ps];
    //
    //        ///3. 根据当前absNode的mv果,处理absCmvNode评价影响力;(系数0.2)
    //        if (fromOut_ps) {
    //            CGFloat scoreForce = [ThinkingUtils getScoreForce:absNode.cmvNode_p ratio:0.2f];
    //            score += scoreForce;
    //        }
    //    }
    //}
}

+(id) scheme_GetAValidNode:(NSArray*)check_ps except_ps:(NSMutableArray*)except_ps checkBlock:(BOOL(^)(id checkNode))checkBlock{
    //1. 数据检查
    if (!ARRISOK(check_ps) || !ARRISOK(except_ps)) {
        return nil;
    }
    
    //2. 依次判断是否已排除
    for (AIPointer *fo_p in check_ps) {
        if (![SMGUtils containsSub_p:fo_p parent_ps:except_ps]) {
            
            //3. 未排除,返回;
            [except_ps addObject:fo_p];
            id result = [SMGUtils searchObjectForPointer:fo_p fileName:FILENAME_Node time:cRedisNodeTime];
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
    
    //2. 每层向具象取前3条
    for (AIPointer *fo_p in curLayer_ps) {
        id curNode = [SMGUtils searchObjectForPointer:fo_p fileName:FILENAME_Node time:cRedisNodeTime];
        if (getConPsBlock) {
            NSArray *con_ps = ARRTOOK(getConPsBlock(curNode));
            [result addObjectsFromArray:con_ps];
        }
    }
    return result;
}

@end
