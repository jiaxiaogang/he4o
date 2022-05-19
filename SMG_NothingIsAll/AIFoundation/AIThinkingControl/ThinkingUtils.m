//
//  ThinkingUtils.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "ThinkingUtils.h"
#import "ImvGoodModel.h"
#import "ImvBadModel.h"

@implementation ThinkingUtils

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

//是否有任意需求 (坏增加 或 好减少);
+(BOOL) havDemand:(NSString*)algsType delta:(NSInteger)delta{
    return [self havDownDemand:algsType delta:delta] || [self havUpDemand:algsType delta:delta];
}
+(BOOL) havDemand:(AIKVPointer*)cmvNode_p{
    AICMVNodeBase *cmvNode = [SMGUtils searchNode:cmvNode_p];
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    return [self havDemand:cmvNode_p.algsType delta:delta];
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

@end
