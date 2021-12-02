//
//  AIThinkInReason.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------理性ThinkIn控制器部分--------------------
 *  @desc 理性In流程的is和use部分;
 *  @desc 理性流程,即NOMV流程;
 *  @desc 注: 目前内类比,并未搬过来,但内类比本来就算是理性的,所以随后有机会迁过来;
 */
@class AIAlgNodeBase,AICMVNodeBase,AIShortMatchModel;
@interface AIThinkInReason : NSObject

//MARK:===============================================================
//MARK:                     < 概念识别 >
//MARK:===============================================================
+(void) TIR_Alg:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps complete:(void(^)(NSArray *matchAlgs,NSArray *partAlg_ps))complete;
//+(AIAlgNodeBase*) TIR_Alg_FromRethink:(AIAlgNodeBase*)rtAlg mUniqueV_p:(AIKVPointer*)mUniqueV_p;


//MARK:===============================================================
//MARK:                     < 时序识别 >
//MARK:===============================================================
+(AIShortMatchModel*) TIR_Fo_FromRethink:(AIFoNodeBase*)fo baseDemand:(ReasonDemandModel*)baseDemand;

+(void) partMatching_FoV1Dot5:(AIFoNodeBase*)maskFo except_ps:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel findCutIndex:(NSInteger(^)(AIFoNodeBase *matchFo,NSInteger lastMatchIndex))findCutIndex;


//MARK:===============================================================
//MARK:                     < 预测 >
//MARK:===============================================================
+(void) tir_OPushM:(AIShortMatchModel*)newInModel;

@end
