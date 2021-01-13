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
+(AnalogyType) convertDS2AnalogyType:(NSString*)ds;

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

/**
 *  MARK:--------------------按照模糊匹配度排序--------------------
 */
+(NSArray*) getFuzzySortWithMaskValue:(AIKVPointer*)maskValue_p fromProto_ps:(NSArray*)proto_ps;

/**
 *  MARK:--------------------收集节点指针地址--------------------
 *  @param absLimit : 抽象追加收集多少个;
 *  @desc 目前仅收集Normal类型的节点,因为一般情况下都是使用Normal类型,别的类型反射会干扰;
 */
+(NSArray*) collectionNodes:(AIKVPointer*)node_p absLimit:(NSInteger)absLimit conLimit:(NSInteger)conLimit;

/**
 *  MARK:--------------------收集概念的refFos--------------------
 *  @param itemRefLimit : 每条概念最多可收集refs条数;
 */
+(NSMutableArray*) collectionAlgRefs:(NSArray*)alg_ps itemRefLimit:(NSInteger)itemRefLimit except_p:(AIKVPointer*)except_p;

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

/**
 *  MARK:--------------------获取mv1和mv2是否同向或反向--------------------
 *  @result 默认返回false;
 */
//+(BOOL) sameOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p;      //同区且同向
+(BOOL) sameScoreOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p; //同向
+(BOOL) sameOfScore1:(CGFloat)score1 score2:(CGFloat)score2;        //同向

+(BOOL) diffScoreOfMV1:(AIKVPointer*)mv1_p mv2:(AIKVPointer*)mv2_p; //反向
+(BOOL) diffOfScore1:(CGFloat)score1 score2:(CGFloat)score2;        //反向

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
//+(CGFloat) dataOut_CheckScore_ExpOut:(AIPointer*)foNode_p;

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

/**
 *  MARK:--------------------PM算法获取有效SP概念--------------------
 */
+(NSArray*) pm_GetValidSPAlg_ps:(AIAlgNodeBase*)curAlg curFo:(AIFoNodeBase*)curFo type:(AnalogyType)type;

//+(TOAlgModel*) getAnalogyReasonRethink_

@end


//MARK:===============================================================
//MARK:                     < ThinkingUtils (Contains) >
//MARK:===============================================================
@interface ThinkingUtils (Contains)

//判断absAlg是否具象指向conAlg;
+(BOOL) containsConAlg:(AIKVPointer*)conAlg_p absAlg:(AIPointer*)absAlg_p;

@end
