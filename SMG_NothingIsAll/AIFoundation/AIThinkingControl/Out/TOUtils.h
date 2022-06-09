//
//  TOUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2020/4/2.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIAlgNodeBase,DemandModel,TOFoModel,AIShortMatchModel,TOModelBase,TOAlgModel,AISolutionModel,AIEffectStrong;
@interface TOUtils : NSObject

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


//MARK:===============================================================
//MARK:                     < 从TO短时记忆取demand >
//MARK:===============================================================
/**
 *  MARK:--------------------获取subOutModel的demand--------------------
 */
+(DemandModel*) getRootDemandModelWithSubOutModel:(TOModelBase*)subOutModel;

/**
 *  MARK:--------------------向着某方向取所有demands--------------------
 *  @result 含子任务和root任务 notnull;
 */
+(NSMutableArray*) getBaseDemands_AllDeep:(TOModelBase*)subModel;//base方向;
+(NSInteger) getBaseDemandsDeepCount:(TOModelBase*)subModel;


//MARK:===============================================================
//MARK:                     < 从TO短时记忆取outModel >
//MARK:===============================================================
/**
 *  MARK:--------------------找出已行为输出等待外循环结果的outModels--------------------
 *  @result notnull NSArray<TOModelBase#>
 *  @param validStatus : 为nil时,将收集一切类型;
 *  _param cutStopStatus : 为nil时,不进行任何中断;
 *  @result notnull
 */
+(NSArray*) getSubOutModels_AllDeep:(TOModelBase*)outModel validStatus:(NSArray*)validStatus;
+(NSArray*) getSubOutModels_AllDeep:(TOModelBase*)outModel validStatus:(NSArray*)validStatus cutStopStatus:(NSArray*)cutStopStatus;
+(NSMutableArray*) getSubOutModels:(TOModelBase*)outModel;
+(NSMutableArray*) getBaseOutModels_AllDeep:(TOModelBase*)subModel;


//MARK:===============================================================
//MARK:                     < convert >
//MARK:===============================================================

/**
 *  MARK:--------------------将TOModels转为Pointers--------------------
 *  @result notnull
 */
+(NSMutableArray*) convertPointersFromTOModels:(NSArray*)toModels;

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
 *  MARK:--------------------求fo的deltaTime之和--------------------
 */
+(double) getSumDeltaTime2Mv:(AIFoNodeBase*)fo cutIndex:(NSInteger)cutIndex;

/**
 *  MARK:--------------------获取指定获取的deltaTime之和--------------------
 *  _param startIndex   : 下标(不含);
 *  _param endIndex     : 下标(含);
 */
+(double) getSumDeltaTime:(AIFoNodeBase*)fo startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

/**
 *  MARK:--------------------toModel转key--------------------
 *  @desc 用于字典数据的key,可以避免因pointer防重失效 (比如scoreDic) (参考25056);
 *  @param toModel : notnull
 */
+(NSString*) toModel2Key:(TOModelBase*)toModel;

/**
 *  MARK:--------------------effectDic的HN求和--------------------
 */
+(NSRange) getSumEffectHN:(NSDictionary*)effectDic;

/**
 *  MARK:--------------------稳定性评分--------------------
 *  @param endSPIndex   : 目标index,比如感性mv时,则为fo.count (求结果时,需包含endSPIndex);
 *  @param startSPIndex : 起始index,比如理性时,常为0到fo.count-1之间 (求结果时,需包含startSPIndex);
 */
+(CGFloat) getStableScore:(AIFoNodeBase*)fo startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex;

/**
 *  MARK:--------------------SP好坏评分--------------------
 *  @param endSPIndex   : 目标index,比如感性mv时,则为fo.count (求结果时,需包含endSPIndex);
 *  @param startSPIndex : 起始index,比如理性时,常为0到fo.count-1之间 (求结果时,需包含startSPIndex);
 */
+(CGFloat) getSPScore:(AIFoNodeBase*)fo startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex;

/**
 *  MARK:--------------------有效率评分--------------------
 *  @param demandFo     : R任务时传pFo即可, H任务时传hDemand.base.baseFo;
 *  @param effectIndex  : R任务时传demandFo.count, H任务时传hDemand.base.baseFo.actionIndex;
 *  @param solutionFo   : 用于检查有效率的solutionFo;
 */
+(CGFloat) getEffectScore:(AIFoNodeBase*)demandFo effectIndex:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo;
+(CGFloat) getEffectScore:(AIEffectStrong*)strong;
+(AIEffectStrong*) getEffectStrong:(AIFoNodeBase*)demandFo effectIndex:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo;
+(NSString*) getEffectDesc:(AIFoNodeBase*)demandFo effectIndex:(NSInteger)effectIndex solutionFo:(AIKVPointer*)solutionFo;


/**
 *  MARK:--------------------获取fo衰减后的值--------------------
 *  @param fo_p         : 计算fo的衰减后的值;
 *  @param outOfFo_ps   : fo的竞争者 (包含fo);
 */
+(double) getColValue:(AIKVPointer*)fo_p outOfFos:(NSArray*)outOfFo_ps ;

/**
 *  MARK:--------------------获取衰减后的稳定性--------------------
 */
+(CGFloat) getColStableScore:(AIFoNodeBase*)fo outOfFos:(NSArray*)outOfFo_ps startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex;

/**
 *  MARK:--------------------获取衰减后的SP好坏评分--------------------
 */
+(CGFloat) getColSPScore:(AIFoNodeBase*)fo outOfFos:(NSArray*)outOfFo_ps startSPIndex:(NSInteger)startSPIndex endSPIndex:(NSInteger)endSPIndex;


//MARK:===============================================================
//MARK:                     < 思考算法 >
//MARK:===============================================================

/**
 *  MARK:--------------------对比节点相同度--------------------
 */
+(AISolutionModel*) compareRCansetFo:(AIKVPointer*)cansetFo_p protoFo:(AIKVPointer*)protoFo_p;
+(AISolutionModel*) compareHCansetFo:(AIKVPointer*)cansetFo_p targetFo:(TOFoModel*)targetFoM;
+(CGFloat) compareCansetAlg:(AIKVPointer*)cansetAlg_p protoAlg:(AIKVPointer*)protoAlg_p;
+(CGFloat) compareCansetValue:(AIKVPointer*)cansetV_p protoValue:(AIKVPointer*)protoV_p;

//MARK:===============================================================
//MARK:                     < 解决方案竞争 >
//MARK:===============================================================
+(NSArray*) solutionSlow_SortNarrow:(NSArray*)solutionModels needBack:(BOOL)needBack;
+(NSArray*) solutionTotalRanking:(NSArray*)solutionModels needBack:(BOOL)needBack fromSlow:(BOOL)fromSlow;

/**
 *  MARK:--------------------检查某toModel的末枝有没有ActYes状态--------------------
 */
+(BOOL) endHavActYes:(TOModelBase*)curModel;

/**
 *  MARK:--------------------将cansets中同fo的strong合并--------------------
 */
+(NSArray*) mergeCansets:(NSArray*)protoCansets;

@end
