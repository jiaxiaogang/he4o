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
@class AIAlgNodeBase,AICMVNodeBase;
@interface AIThinkInReason : NSObject

//理性概念
+(void) dataIn_NoMV:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps finishBlock:(void(^)(AIAlgNodeBase *isNode,AICMVNodeBase *useNode))finishBlock;

//理性时序
+(void) TIR_Fo_FromRethink:(NSArray*)protoAlg_ps finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue))finishBlock;
+(void) TIR_Fo_FromShortMem:(NSArray*)protoAlg_ps finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue))finishBlock;

@end
