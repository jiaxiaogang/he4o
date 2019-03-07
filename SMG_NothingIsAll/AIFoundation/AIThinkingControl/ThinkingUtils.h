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

//筛选出非out的pointers
+(NSArray*) filterNotOutPointers:(NSArray*)proto_ps;

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Analogy) >
//MARK:===============================================================
@interface ThinkingUtils (Analogy)

/**
 *  MARK:--------------------fo外类比 (外中有内)--------------------
 *  @param canAssBlock          : 向tc询问一次是否允许联想 (一层层联想abs的过程需要消耗energy)
 *  @param buildAlgNodeBlock    : 类比到规律,进行抽象节点的构建;
 *  @result notnull             : 返回orderSames用于构建absFo
 *
 *  1. 连续信号中,找重复;(连续也是拆分,多事务处理的)
 *  2. 两条信息中,找交集;
 *  3. 在连续信号的处理中,实时将拆分单信号存储到内存区,并提供可检索等,其形态与最终存硬盘是一致的;
 *  4. 类比处理(瓜是瓜)
 *  注: 类比的处理,是足够细化的,对思维每个信号作类比操作;(而将类比到的最基本的结果,输出给thinking,以供为构建网络的依据,最终是以网络为目的的)
 *  注: 随后可以由一个sames改为多个sames并实时使用block抽象 (并消耗energy);
 */
+(NSArray*) analogyOrdersA:(NSArray*)ordersA ordersB:(NSArray*)ordersB canAss:(BOOL(^)())canAssBlock buildAlgNode:(AIAbsAlgNode*(^)(NSArray* algSames,AIAlgNode *algA,AIAlgNode *algB))buildAlgNodeBlock;

/**
 *  MARK:--------------------fo内类比 (内中有外)--------------------
 *  @param orders           : 要处理的fo.orders;
 *  @param buildAbsAlgBlock : 构建抽象祖母回调;
 *  @param buildAbsFoBlock  : 构建抽象时序回调;
 *
 *  1. 此方法对一个fo内的orders进行内类比,并将找到的变化进行抽象构建网络;
 *  2. 如: 绿瓜变红瓜,如远坚果变近坚果;
 *  3. 每发现一个有效变化目标,则构建2个absAlg和2个absFo; (参考n15p18内类比构建图)
 */
+(void) analogyInnerOrders:(NSArray*)orders buildAbsAlgBlock:(AIAbsAlgNode*(^)(NSArray* algSames,AIAlgNode *conAlg))buildAbsAlgBlock buildAbsFoBlock:(AINetAbsFoNode*(^)(NSArray* orderSames))buildAbsFoBlock;

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


//MARK:===============================================================
//MARK:                     < ThinkingUtils (In) >
//MARK:===============================================================
@interface ThinkingUtils (In)

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
 *  需要对祖母节点指定当前的isOut状态; (思维控制器知道它是行为还是认知)
 */
+(AIPointer*) createAlgNodeWithValue_ps:(NSArray*)value_ps isOut:(BOOL)isOut;

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Out) >
//MARK:===============================================================
@interface ThinkingUtils (Out)

/**
 *  MARK:--------------------可行性判定 (经验执行方案)--------------------
 *  作用: 评价,评分;
 *  注:TODO:后续可以增加energy的值,并在此方法中每一次scoreForce就energy--;以达到更加精细的思维控制;
 *
 *  A:根据out_ps联想(分析可行性)
 *  >assHavResult : 其有没有导致mv-和mv+;
 *    > mv-则:联想conPort,思考具象;
 *    > mv+则:score+分;
 *  >assNoResult :
 *
 */
+(CGFloat) dataOut_CheckScore_ExpOut:(AIPointer*)foNode_p;


/**
 *  MARK:--------------------获取一条不在不应期的foNode/algNode--------------------
 *  @param checkBlock : 对结果进行检查,有效则返回,无效则循环至下一条; (checkBlock为nil时,只要result不为nil,即有效)
 */
+(id) scheme_GetAValidNode:(NSArray*)check_ps except_ps:(NSMutableArray*)except_ps checkBlock:(BOOL(^)(id checkNode))checkBlock;

/**
 *  MARK:--------------------获取下一层具象时序--------------------
 *  @result : 将下一层具象的foNode的指针数组返回;
 *  注: 每一个conPorts取前3条;
 */
+(NSArray*) foScheme_GetNextLayerPs:(NSArray*)curLayer_ps;
+(NSArray*) algScheme_GetNextLayerPs:(NSArray*)curLayer_ps;

@end
