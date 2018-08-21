//
//  ThinkingUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIFrontOrderNode;
@interface ThinkingUtils : NSObject

/**
 *  MARK:--------------------更新能量值--------------------
 */
+(NSInteger) updateEnergy:(NSInteger)oriEnergy delta:(NSInteger)delta;

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Analogy) >
//MARK:===============================================================
@interface ThinkingUtils (Analogy)

+(BOOL) analogyCharA:(char)a b:(char)b;

+(void) analogyCMVA:(NSArray*)a b:(NSArray*)b;

//类比处理(瓜是瓜)
+(NSArray*) analogyFoNode_A:(AIFrontOrderNode*)foNode_A foNode_B:(AIFrontOrderNode*)foNode_B;

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (CMV) >
//MARK:===============================================================
@interface ThinkingUtils (CMV)


/**
 *  MARK:--------------------取mvType或algsType对应的targetType--------------------
 */
+(AITargetType) getTargetType:(MVType)type;
+(AITargetType) getTargetTypeWithAlgsType:(NSString*)algsType;

/**
 *  MARK:--------------------检查是否顺心--------------------
 */
+(MindHappyType) checkMindHappy:(NSString*)algsType delta:(NSInteger)delta;


/**
 *  MARK:--------------------检查有没需求--------------------
 */
+(BOOL) getDemand:(NSString*)algsType delta:(NSInteger)delta complete:(void(^)(BOOL upDemand,BOOL downDemand))complete;


/**
 *  MARK:--------------------解析algsMVArr--------------------
 *  cmvAlgsArr->mvValue
 */
+(void) parserAlgsMVArrWithoutValue:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSString *algsType))success;
+(void) parserAlgsMVArr:(NSArray*)algsArr success:(void(^)(AIKVPointer *delta_p,AIKVPointer *urgentTo_p,NSInteger delta,NSInteger urgentTo,NSString *algsType))success;

@end
