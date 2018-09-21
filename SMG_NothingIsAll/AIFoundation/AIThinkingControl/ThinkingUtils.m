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
#import "AINetCMV.h"
#import "AIAbsCMVNode.h"

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

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Analogy) >
//MARK:===============================================================
@implementation ThinkingUtils (Analogy)

+(BOOL) analogyCharA:(char)a b:(char)b{
    return a == b;
}

+(void) analogyCMVA:(NSArray*)a b:(NSArray*)b{
    //1. 忽略
    //2. 
}

+(void) test{
    //1. 连续信号中,找重复;(连续也是拆分,多事务处理的)
    //2. 两条信息中,找交集;
    //3. 在连续信号的处理中,实时将拆分单信号存储到内存区,并提供可检索等,其形态与最终存硬盘是一致的;
    
    //类比的处理,是足够细化的,对思维每个信号作类比操作;(而将类比到的最基本的结果,输出给thinking,以供为构建网络的依据,最终是以网络为目的的)
}

//类比处理(瓜是瓜)
+(NSArray*) analogyFoNode_A:(AIFrontOrderNode*)foNode_A foNode_B:(AIFrontOrderNode*)foNode_B{
    //1. 类比orders的规律
    NSMutableArray *sames = [[NSMutableArray alloc] init];
    if (ISOK(foNode_A, AIFrontOrderNode.class) && ISOK(foNode_B, AIFrontOrderNode.class)) {
        for (AIKVPointer *dataA_p in foNode_A.orders_kvp) {
            //6. 是否已收集
            BOOL already = false;
            for (AIKVPointer *same_p in sames) {
                if ([same_p isEqual:dataA_p]) {
                    already = true;
                    break;
                }
            }
            //7. 未收集过,则查找是否有一致微信息(有则收集)
            if (!already) {
                for (AIKVPointer *dataB_p in foNode_B.orders_kvp) {
                    if ([dataA_p isEqual:dataB_p]) {
                        [sames addObject:dataB_p];
                        break;
                    }
                }
            }
        }
    }
    return sames;
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

+(CGFloat) getScoreForce:(AIPointer*)absCmvNode_p ratio:(CGFloat)ratio{
    AIAbsCMVNode *absCmvNode = [SMGUtils searchObjectForPointer:absCmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    if (ISOK(absCmvNode, AIAbsCMVNode.class)) {
        return [ThinkingUtils getScoreForce:absCmvNode.pointer.algsType urgentTo_p:absCmvNode.urgentTo_p delta_p:absCmvNode.delta_p ratio:ratio];
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


+(NSArray*) getFrontOrdersFromCmvNode:(AICMVNode*)cmvNode{
    AIFrontOrderNode *foNode = [self getFoNodeFromCmvNode:cmvNode];
    if (foNode) {
        return foNode.orders_kvp;//out是不能以数组处理foNode.orders_p的,下版本改)
    }
    return nil;
}

+(AIFrontOrderNode*) getFoNodeFromCmvNode:(AICMVNode*)cmvNode{
    AIKVPointer *foNode_p = [self getFoNodePointerFromCmvNode:cmvNode];
    if (foNode_p) {
        //2. 取"解决经验"对应的前因时序列;
        AIFrontOrderNode *foNode = [SMGUtils searchObjectForPointer:foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        return foNode;
    }
    return nil;
}

+(AIKVPointer*) getFoNodePointerFromCmvNode:(AICMVNode*)cmvNode{
    if (cmvNode && cmvNode.cmvModel_p) {
        //1. 取"解决经验"对应的cmv基本模型;
        AINetCMVModel *cmvModel = [SMGUtils searchObjectForPointer:cmvNode.cmvModel_p fileName:FILENAME_CMVModel time:cRedisNodeTime];
        if (cmvModel) {
            return cmvModel.foNode_p;
        }
    }
    return nil;
}

@end
