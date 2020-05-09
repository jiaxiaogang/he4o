//
//  ThinkingUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2018/3/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIFrontOrderNode,AIAlgNodeBase,AIShortMatchModel;
@interface ThinkingUtils : NSObject

/**
 *  MARK:--------------------更新能量值--------------------
 */
+(CGFloat) updateEnergy:(CGFloat)oriEnergy delta:(CGFloat)delta;

//根据前后稀疏码值,得到该变大还是变小;
+(AnalogyType) getInnerType:(AIKVPointer*)frontValue_p backValue_p:(AIKVPointer*)backValue_p;

//根据analogyType取其构建Alg/Fo的dataSource; notnull
+(NSString*) getAnalogyTypeDS:(AnalogyType)type;

//根据评分,得到该开心,还是不开心;
+(AnalogyType) getInnerTypeWithScore:(CGFloat)score;

//根据稀疏码对比反思类比大小结果;
+(AnalogyType) compare:(AIKVPointer*)valueA_p valueB_p:(AIKVPointer*)valueB_p;

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
+(BOOL) havDownDemand:(NSString*)algsType delta:(NSInteger)delta;
+(BOOL) havUpDemand:(NSString*)algsType delta:(NSInteger)delta;
+(MVDirection) havDemand:(NSString*)algsType delta:(NSInteger)delta;

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
+(CGFloat) getScoreForce:(NSString*)algsType urgentTo_p:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p ratio:(CGFloat)ratio;


@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Association) >
//MARK:===============================================================
@class AICMVNode;
@interface ThinkingUtils (Association)

//根据端口,获取到target指向的节点;
+(id) getNodeFromPort:(AIPort*)port;

//根据proto联想matchAlg节点;
//+(AIAlgNodeBase*) getMatchAlgWithProtoAlg:(AIAlgNodeBase*)protoAlg;

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
 *  MARK:--------------------构建硬盘概念节点_去重--------------------
 *  @callers : 无调用;
 */
+(AIAlgNodeBase*) createHdAlgNode_NoRepeat:(NSArray*)value_ps;

/**
 *  MARK:--------------------构建时序_去重--------------------
 *  @callers : 被外类比构建器调用;
 *  @功能说明: 1. 未支持内存去重;
 *  @param difStrong : 构建fo的被引用初始强度;
 *  @version
 *      20200426 - 去掉时序的全局去重;
 */
+(AINetAbsFoNode*)createAbsFo_NoRepeat_General:(NSArray*)conFos content_ps:(NSArray*)content_ps ds:(NSString*)ds difStrong:(NSInteger)difStrong;
//+(AIFrontOrderNode*)createConFo_NoRepeat_General:(NSArray*)content_ps isMem:(BOOL)isMem;

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
 *  MARK:--------------------指定ratio的评价重载--------------------
 *  @desc 对MC的评价时:
 *      1. 理性评价: 由MC匹配方法中,进行类比ms&cs&mcs决定;
 *      2. 感性评价: 由此处进行计算得出;
 *          如: 判断变脏后,不能吃; 参考17202表中示图 (被吃mv为负 (理性是间接的感性) (导致负价值))
 *          如: 判断cpu损坏,会浪费钱;
 *          如: 带皮坚果,不能吃, (根本,不能吃,比如坚果皮 (抽象为:吃皮,导致负mv))
 *
 *  @desc 对ExpOut评价时:
 *      1. 以默认ratio=0.2,进行评价;
 */
+(CGFloat) getScoreForce:(AIPointer*)cmvNode_p ratio:(CGFloat)ratio;

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


/**
 *  MARK:--------------------获取到某标识下的ATHav/ATNone/ATGreater/ATLess概念--------------------
 *  @desc : 根据概念标识,获取概念的"有无大小"节点
 */
+(AIAlgNodeBase*) dataOut_GetAlgNodeWithInnerType:(AnalogyType)type algsType:(NSString*)algsType dataSource:(NSString*)dataSource;

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Contains) >
//MARK:===============================================================
@interface ThinkingUtils (Contains)

//判断absAlg是否具象指向conAlg;
+(BOOL) containsConAlg:(AIKVPointer*)conAlg_p absAlg:(AIPointer*)absAlg_p;

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Filter) >
//MARK:===============================================================
@interface ThinkingUtils (Filter)

/**
 *  MARK:--------------------筛选出outPointers--------------------
 *  @param proto_ps : 从中筛选
 *  @param isOut : false时筛选出非out的pointers
 *  注:未判定是否连续;
 */
+(NSArray*) filterPointers:(NSArray*)proto_ps isOut:(BOOL)isOut;

//从from_ps中查找与check_p同标识区的指针并返回;
+(AIKVPointer*) filterPointer:(NSArray*)from_ps identifier:(NSString*)identifier;

//从alg_ps中查找含valueIdentifier标识稀疏码的概念并返回;
+(NSArray*) filterAlg_Ps:(NSArray*)alg_ps valueIdentifier:(NSString*)valueIdentifier itemValid:(void(^)(AIAlgNodeBase *alg,AIKVPointer *value_p))itemValid;

@end
