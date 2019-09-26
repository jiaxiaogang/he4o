//
//  AIThinkInPercept.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------感性ThinkIn控制器部分--------------------
 *  @desc 感性In流程的learning类比,抽象;
 *  @desc 理性流程,即FindMV流程;
 */
@class AIFrontOrderNode,AICMVNode;
@interface AIThinkInPercept : NSObject

/**
 *  MARK:--------------------入口--------------------
 *  @param canAss       : NotNull
 *  @param updateEnergy : NotNull
 */
+(void) dataIn_FindMV:(NSArray*)algsArr
   createMvModelBlock:(AIFrontOrderNode*(^)(NSArray *algsArr))createMvModelBlock
          finishBlock:(void(^)(AICMVNode *commitMvNode))finishBlock
               canAss:(BOOL(^)())canAss
         updateEnergy:(void(^)(CGFloat delta))updateEnergy;

@end
