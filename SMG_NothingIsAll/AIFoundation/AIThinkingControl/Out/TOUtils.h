//
//  TOUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIAlgNodeBase,DemandModel,TOFoModel,AIShortMatchModel,TOModelBase,TOAlgModel;
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

+(BOOL) mIsC_1:(NSArray*)ms cs:(NSArray*)cs;

/**
 *  MARK:--------------------在具象Content中定位抽象Item的下标--------------------
 *  @result 如果找不到,默认返回-1;
 *  _param layerDiff: 检查层数,默认为1,支持0,1,2;
 */
+(NSInteger) indexOfAbsItem:(AIKVPointer*)absItem atConContent:(NSArray*)conContent;

/**
 *  MARK:--------------------下面3个方法的参数说明--------------------
 *  @param startIndex : 起始index:含 (不限制传0);
 *  @param endIndex : 终止index:含 (不限制传IntegerMax);
 */
//absItem是content中的抽象一员,返回index;
+(NSInteger) indexOfAbsItem:(AIKVPointer*)absItem atConContent:(NSArray*)conContent layerDiff:(int)layerDiff startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

//conItem是content中的具象一员,返回index;
+(NSInteger) indexOfConItem:(AIKVPointer*)conItem atAbsContent:(NSArray*)content layerDiff:(int)layerDiff startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

//conItem是content中的具象或抽象一员,返回index;
+(NSInteger) indexOfConOrAbsItem:(AIKVPointer*)item atContent:(NSArray*)content layerDiff:(int)layerDiff startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

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
//+(NSArray*) collectAbsPs:(AINodeBase*)protoNode type:(AnalogyType)type conLayer:(NSInteger)conLayer absLayer:(NSInteger)absLayer;
+(NSMutableArray*) collectAbsPorts:(NSArray*)proto_ps singleLimit:(NSInteger)singleLimit havTypes:(NSArray*)havTypes noTypes:(NSArray*)noTypes;

/**
 *  MARK:--------------------TOP.diff正负两个模式--------------------
 */
+(void) topPerceptModeV2:(DemandModel*)demandModel direction:(MVDirection)direction tryResult:(BOOL(^)(AIFoNodeBase *sameFo))tryResult canAss:(BOOL(^)())canAssBlock updateEnergy:(void(^)(CGFloat))updateEnergy;

/**
 *  MARK:--------------------获取subOutModel的demand--------------------
 */
+(DemandModel*) getDemandModelWithSubOutModel:(TOModelBase*)subOutModel;

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
+(NSMutableArray*) convertPointersFromTOModels:(NSArray*)toModels;

/**
 *  MARK:--------------------将TOModels中TOValue部分的sValue_p收集返回--------------------
 */
+(NSArray*) convertPointersFromTOValueModelSValue:(NSArray*)toModels validStatus:(NSArray*)validStatus;

/**
 *  MARK:--------------------是否HNGL节点--------------------
 *  @desc 其中isHNGL主要支持fo,alg都是hnglConAlg (参考21115);
 *  @todo
 *      2020.12.17: 此处对alg的支持,需要迭代 (否则原来调用这五个方法isHNGL,isH,isN,isG,isL的alg都会不准确);
 */
+(BOOL) isHNGL:(AIKVPointer*)p;
+(BOOL) isHNGLSP:(AIKVPointer*)p;
+(BOOL) isH:(AIKVPointer*)p;
+(BOOL) isN:(AIKVPointer*)p;
+(BOOL) isG:(AIKVPointer*)p;
+(BOOL) isL:(AIKVPointer*)p;
+(BOOL) isS:(AIKVPointer*)p;
+(BOOL) isP:(AIKVPointer*)p;

/**
 *  MARK:--------------------是否HNGL的TOModel--------------------
 */
+(BOOL) isHNGL_toModel:(TOModelBase*)toModel;
+(BOOL) isH_toModel:(TOModelBase*)toModel;
+(BOOL) isN_toModel:(TOModelBase*)toModel;
+(BOOL) isG_toModel:(TOModelBase*)toModel;
+(BOOL) isL_toModel:(TOModelBase*)toModel;

/**
 *  MARK:--------------------求fo的cutIndex到mv的deltaTime之和--------------------
 */
+(double) getSumDeltaTime2Mv:(AIFoNodeBase*)fo cutIndex:(NSInteger)cutIndex;

@end
