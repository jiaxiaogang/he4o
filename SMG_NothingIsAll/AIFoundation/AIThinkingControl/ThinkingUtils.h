//
//  ThinkingUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIFrontOrderNode,AIAbsAlgNode,AIAlgNode;
@interface ThinkingUtils : NSObject

/**
 *  MARK:--------------------更新能量值--------------------
 */
+(NSInteger) updateEnergy:(NSInteger)oriEnergy delta:(NSInteger)delta;


/**
 *  MARK:--------------------筛选出outPointers--------------------
 *  注:未判定是否连续;
 */
+(NSArray*) filterOutPointers:(NSArray*)proto_ps;


/**
 *  MARK:--------------------检测算法结果的result_ps是否为mv输入--------------------
 *  (饿或不饿)
 */
+(BOOL) dataIn_CheckMV:(NSArray*)algResult_ps;


/**
 *  MARK:--------------------算法模型的装箱--------------------
 *  转为指针数组(每个值都是指针)(在dataIn后第一件事就是装箱)
 */
+(NSArray*) algModelConvert2Pointers:(NSObject*)algsModel;


/**
 *  MARK:--------------------创建祖母节点--------------------
 *  将微信息组,转换成祖母节点;
 */
+(AIPointer*) createAlgNodeWithValue_ps:(NSArray*)value_ps;

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Analogy) >
//MARK:===============================================================
@interface ThinkingUtils (Analogy)

/**
 *  MARK:--------------------类比处理(瓜是瓜)--------------------
 *  @param canAssBlock          : 向tc询问一次是否允许联想 (一层层联想abs的过程需要消耗energy)
 *  @param buildAlgNodeBlock    : 类比到规律,进行抽象节点的构建;
 *  @result notnull
 *
 *  1. 连续信号中,找重复;(连续也是拆分,多事务处理的)
 *  2. 两条信息中,找交集;
 *  3. 在连续信号的处理中,实时将拆分单信号存储到内存区,并提供可检索等,其形态与最终存硬盘是一致的;
 *  注: 类比的处理,是足够细化的,对思维每个信号作类比操作;(而将类比到的最基本的结果,输出给thinking,以供为构建网络的依据,最终是以网络为目的的)
 *  注: 随后可以由一个sames改为多个sames并实时使用block抽象 (并消耗energy);
 */
+(NSArray*) analogyOrdersA:(NSArray*)ordersA ordersB:(NSArray*)ordersB canAss:(BOOL(^)())canAssBlock buildAlgNode:(AIAbsAlgNode*(^)(NSArray* algSames,AIAlgNode *algA,AIAlgNode *algB))buildAlgNodeBlock;


/**
 *  MARK:--------------------类比相减 得出解决方案的条件判定--------------------
 */
+(BOOL) analogySubWithExpOrder:(NSArray*)expOrder checkOrder:(NSArray*)checkOrder canAss:(BOOL(^)())canAssBlock checkAlgNode:(BOOL(^)(NSArray* algSames,AIAlgNode *algA,AIAlgNode *algB))checkAlgNodeBlock;

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


/**
 *  MARK:--------------------获取到cmvNode的评价力--------------------
 */
+(CGFloat) getScoreForce:(AIPointer*)cmvNode_p ratio:(CGFloat)ratio;
+(CGFloat) getScoreForce:(NSString*)algsType urgentTo_p:(AIPointer*)urgentTo_p delta_p:(AIPointer*)delta_p ratio:(CGFloat)ratio;


@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Association) >
//MARK:===============================================================
@class AICMVNode;
@interface ThinkingUtils (Association)


/**
 *  MARK:--------------------根据cmvNode联想其对应的前因时序列;--------------------
 */
//+(NSArray*) getFrontOrdersFromCmvNode:(AICMVNode*)cmvNode;


/**
 *  MARK:--------------------根据cmvNode联想其对应的foNode--------------------
 */
+(AIFrontOrderNode*) getFoNodeFromCmvNode:(AICMVNode*)cmvNode;


@end
