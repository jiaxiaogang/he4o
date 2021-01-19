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
//MARK:                     < 理性概念识别 >
//MARK:===============================================================
+(void) TIR_Alg:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps complete:(void(^)(NSArray *matchAlgs,NSArray *partAlg_ps))complete;
//+(AIAlgNodeBase*) TIR_Alg_FromRethink:(AIAlgNodeBase*)rtAlg mUniqueV_p:(AIKVPointer*)mUniqueV_p;


//MARK:===============================================================
//MARK:                     < 理性时序识别与预测 >
//MARK:===============================================================
+(void) TIR_Fo_FromRethink:(NSArray*)order finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue,NSInteger cutIndex))finishBlock;
+(void) TIR_Fo_FromShortMem:(AIFoNodeBase*)protoFo except_ps:(NSArray*)except_ps decoratorInModel:(AIShortMatchModel*)inModel;


//MARK:===============================================================
//MARK:                     < 内类比 >
//MARK:===============================================================
+(void) analogyInner:(AIShortMatchModel*)mModel;

@end
