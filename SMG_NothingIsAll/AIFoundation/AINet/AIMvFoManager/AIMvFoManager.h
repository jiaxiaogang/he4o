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
 *  @param imvAlgsArr : imv此次输入信息
 *  @param order : 瞬时记忆序列
 *  @result : 返回foNode;
 */
-(AIFrontOrderNode*) create:(NSArray*)imvAlgsArr inputTime:(NSTimeInterval)inputTime order:(NSArray*)order;

/**
 *  MARK:--------------------构建具象mv--------------------
 */
-(AICMVNode*) createConMv:(NSArray*)imvAlgsArr;
-(AICMVNode*) createConMv:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p at:(NSString*)at isMem:(BOOL)isMem;

/**
 *  MARK:--------------------构建conFo--------------------
 *  @result notnull
 */
+(AIFrontOrderNode*) createConFo:(NSArray*)order isMem:(BOOL)isMem;

@end
