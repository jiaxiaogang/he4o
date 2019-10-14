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
 */
@class AIAlgNodeBase,AICMVNodeBase;
@interface AIThinkInReason : NSObject

//理性概念
+(void) dataIn_NoMV:(AIKVPointer*)algNode_p fromGroup_ps:(NSArray*)fromGroup_ps finishBlock:(void(^)(AIAlgNodeBase *isNode,AICMVNodeBase *useNode))finishBlock;

//理性时序
+(void) TIR_Fo:(NSArray*)alg_ps finishBlock:(void(^)(AIFoNodeBase *curNode,AIFoNodeBase *matchFo,CGFloat matchValue))finishBlock;

@end
