//
//  TOUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIAlgNodeBase,DemandModel,TOFoModel,AIShortMatchModel,TOModelBase;
@interface TOUtils : NSObject

/**
 *  MARK:--------------------找价值确切的具象概念--------------------
 *  @desc 时序的抽具象是价值确切的,而概念不是,所以本方法,在时序的具象指引下,找具象概念,以使概念也是价值确切的;
 *  @note 参考:18206示图;
 */
+(void) findConAlg_StableMV:(AIAlgNodeBase*)curAlg curFo:(AIFoNodeBase*)curFo itemBlock:(BOOL(^)(AIAlgNodeBase* validAlg))itemBlock;

/**
 *  MARK:--------------------判断mIsC--------------------
 *  @desc 从M向上,找匹配C,支持三层 (含本层):
 *  @version
 *      2020.06.12 : 将取absPorts_All_Normal改为absPorts_All(),以支持innerTypeNode的mIsC判断;
 */
+(BOOL) mIsC:(AIKVPointer*)m c:(AIKVPointer*)c layerDiff:(int)layerDiff;
+(BOOL) mIsC_0:(AIKVPointer*)m c:(AIKVPointer*)c;
+(BOOL) mIsC_1:(AIKVPointer*)m c:(AIKVPointer*)c;
+(BOOL) mIsC_2:(AIKVPointer*)m c:(AIKVPointer*)c;

/**
 *  MARK:--------------------在具象Content中定位抽象Item的下标--------------------
 *  @result 如果找不到,默认返回-1;
 *  _param layerDiff: 检查层数,默认为1,支持0,1,2;
 */
+(NSInteger) indexOfAbsItem:(AIKVPointer*)absItem atConContent:(NSArray*)conContent;
+(NSInteger) indexOfAbsItem:(AIKVPointer*)absItem atConContent:(NSArray*)conContent layerDiff:(int)layerDiff startIndex:(NSInteger)startIndex;

/**
 *  MARK:--------------------判断mc同级--------------------
 */
+(BOOL) mcSameLayer:(AIKVPointer*)m c:(AIKVPointer*)c;

/**
 *  MARK:--------------------收集概念节点的稀疏码--------------------
 */
+(NSArray*) convertValuesFromAlg_ps:(NSArray*)alg_ps;

/**
 *  MARK:--------------------收集多层的absPorts--------------------
 *  @desc 从alg取指定type的absPorts,再从具象,从抽象,各取指定层absPorts,收集返回;
 *  @param conLayer : 从具象取几层 (不含当前层),一般取:1层当前层+1层具象层=共两层即可;
 */
+(NSArray*) collectAbsPs:(AINodeBase*)protoNode type:(AnalogyType)type conLayer:(NSInteger)conLayer absLayer:(NSInteger)absLayer;


/**
 *  MARK:--------------------获取兄弟节点(以负取正)--------------------
 *  @desc 防重,防空版;
 */
+(void) getPlusBrotherBySubProtoFo_NoRepeatNotNull:(AIFoNodeBase*)subProtoFo tryResult:(BOOL(^)(AIFoNodeBase *checkFo,AIFoNodeBase *subNode,AIFoNodeBase *plusNode))tryResult;

/**
 *  MARK:--------------------获取兄弟节点(以负取正)--------------------
 */
+(void) getPlusBrotherBySubProtoFo:(AIFoNodeBase*)subProtoFo tryResult:(BOOL(^)(AIKVPointer *checkFo_p,AIFoNodeBase *subNode,AIFoNodeBase *plusNode))tryResult;

/**
 *  MARK:--------------------TOP.diff正负两个模式--------------------
 */
+(void) topPerceptModeV2:(DemandModel*)demandModel direction:(MVDirection)direction tryResult:(BOOL(^)(AIFoNodeBase *sameFo))tryResult canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy;

/**
 *  MARK:--------------------对TOFoModel进行反思评价--------------------
 */
+(BOOL) toAction_RethinkScore:(TOFoModel*)outModel rtBlock:(AIShortMatchModel*(^)(void))rtBlock;

/**
 *  MARK:--------------------找出已行为输出等待外循环结果的outModels--------------------
 *  @result notnull NSArray<TOModelBase#>
 */
+(NSArray*) getSubOutModels_AllDeep:(TOModelBase*)outModel validStatus:(NSArray*)validStatus;
+(NSArray*) getSubOutModels_AllDeep:(TOModelBase*)outModel validStatus:(NSArray*)validStatus cutStopStatus:(NSArray*)cutStopStatus;

/**
 *  MARK:--------------------将TOModels转为Pointers--------------------
 *  @result notnull
 */
+(NSArray*) convertPointersFromTOModels:(NSArray*)toModels;

/**
 *  MARK:--------------------将TOModels中TOValue部分的sValue_p收集返回--------------------
 */
+(NSArray*) convertPointersFromTOValueModelSValue:(NSArray*)toModels invalidStatus:(NSArray*)invalidStatus;

/**
 *  MARK:--------------------是否HNGL节点--------------------
 */
+(BOOL) isHNGL:(AIKVPointer*)p;
+(BOOL) isH:(AIKVPointer*)p;
+(BOOL) isN:(AIKVPointer*)p;
+(BOOL) isG:(AIKVPointer*)p;
+(BOOL) isL:(AIKVPointer*)p;

@end
