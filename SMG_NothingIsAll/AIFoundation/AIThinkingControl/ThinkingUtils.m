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

+(id) getNodeFromPort:(AIPort*)port{
    if (port) {
        return [SMGUtils searchNode:port.target_p];
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

+(AIAlgNodeBase*) createHdAlgNode_NoRepeat:(NSArray*)value_ps{
    //1. 绝对匹配取已存在
    value_ps = ARRTOOK(value_ps);
    AIAlgNodeBase *target = [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValuePs:value_ps];
    
    //2. 已存在,则转到硬盘
    if (target) {
        target = [AINetUtils move2HdNodeFromMemNode_Alg:target];
    }else{
        //3. 不存在则新构建
        target = [theNet createAlgNode:value_ps isOut:false isMem:false];
    }
    return target;
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

+(BOOL) dataOut_CheckScore_LSPRethink:(AIShortMatchModel*)mModel {
    //TODOTOMORROW:
    if (mModel) {
        //1. 进行理性评价 (参考手稿);
        //看是否预测到鸡蛋变脏,或者cpu损坏;
        
        //判断变脏后,不能吃; 参考17202表中示图
        //判断cpu损坏,会浪费钱;
        
        //c. 向抽象取到"脏食物",
        //c1 被吃mv为负 (理性是间接的感性) (导致负价值);
        //c2 根本,不能吃,比如坚果皮 (抽象不指向食物);
        
        
        
        
        //2. 进行感性评价 (参考手稿);
        //看是否预测到不好的价值,比如宁饿死不吃屎;
    }
    return true;
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
+(AIAlgNodeBase*) dataOut_GetAlgNodeWithInnerType:(AnalogyInnerType)type algsType:(NSString*)algsType dataSource:(NSString*)dataSource{
    //1. 获取innerType的值;
    NSInteger typeValue = [self getInnerTypeValue:type];
    
    //2. 获取相应的微信息;
    AIPointer *value_p = [theNet getNetDataPointerWithData:@(typeValue) algsType:algsType dataSource:dataSource];
    
    //3. 从微信息,联想refPorts绝对匹配的概念节点;
    return [AINetIndexUtils getAbsoluteMatchingAlgNodeWithValueP:value_p];
}

+(NSInteger) getInnerTypeValue:(AnalogyInnerType)type{
    if (type == AnalogyInnerType_Hav) {
        return cHav;
    }else if (type == AnalogyInnerType_None) {
        return cNone;
    }else if (type == AnalogyInnerType_Greater) {
        return cGreater;
    }else if (type == AnalogyInnerType_Less) {
        return cLess;
    }
    return 0;
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
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (AIKVPointer *pointer in ARRTOOK(proto_ps)) {
        if (ISOK(pointer, AIKVPointer.class) && pointer.isOut == isOut) {
            [result addObject:pointer];
        }
    }
    return result;
}

+(AIKVPointer*) filterPointer:(NSArray*)from_ps identifier:(NSString*)identifier{
    if (ARRISOK(from_ps) && STRISOK(identifier)) {
        for (AIKVPointer *from_p in from_ps) {
            if ([identifier isEqualToString:from_p.identifier]) {
                return from_p;
            }
        }
    }
    return nil;
}

@end
