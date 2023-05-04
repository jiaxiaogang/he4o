//
//  AIMvFoManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------foNode->cmvNode的模型--------------------
 */
@class AIFrontOrderNode,AICMVNode;
@interface AIMvFoManager : NSObject

/**
 *  MARK:--------------------create foNode->cmvNode 基本模型--------------------
 *  @param mv : 触发了create的mv;
 *  @param order : 瞬时记忆序列
 *  @result : 返回foNode;
 */
-(AIFrontOrderNode*) create:(NSTimeInterval)inputTime order:(NSArray*)order mv:(AICMVNode*)mv;

/**
 *  MARK:--------------------构建具象mv--------------------
 */
-(AICMVNode*) createConMv:(NSArray*)imvAlgsArr;
-(AICMVNode*) createConMv:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p at:(NSString*)at;

/**
 *  MARK:--------------------构建conFo--------------------
 *  @result notnull
 */
+(AIFrontOrderNode*) createConFo:(NSArray*)order;
+(AIFoNodeBase*) createConFo_NoRepeat:(NSArray*)order;

@end
