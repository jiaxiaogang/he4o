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
@class AICMVNode;
@interface AIMvFoManager : NSObject

/**
 *  MARK:--------------------create foNode->cmvNode 基本模型--------------------
 *  @param mv : 触发了create的mv;
 *  @param order : 瞬时记忆序列
 *  @result : 返回foNode;
 */
-(AIFoNodeBase*) create:(NSTimeInterval)inputTime order:(NSArray*)order mv:(AICMVNodeBase*)mv;

/**
 *  MARK:--------------------构建具象mv--------------------
 */
-(AICMVNodeBase*) createConMv:(NSArray*)imvAlgsArr;
-(AICMVNodeBase*) createConMv:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p at:(NSString*)at;

/**
 *  MARK:--------------------构建conFo--------------------
 *  @result notnull
 */
+(AIFoNodeBase*) createConFo_NoRepeat:(NSArray*)order noRepeatArea_ps:(NSArray*)noRepeatArea_ps difStrong:(NSInteger)difStrong;
+(AIFoNodeBase*) createConFoForCanset:(NSArray*)order sceneFo:(AIFoNodeBase*)sceneFo sceneTargetIndex:(NSInteger)sceneTargetIndex;

/**
 *  MARK:--------------------根据order取本地有没创建过canset并返回--------------------
 */
+(AIFoNodeBase*) getLocalCanset:(NSArray*)order sceneFo:(AIFoNodeBase*)sceneFo sceneTargetIndex:(NSInteger)sceneTargetIndex;

@end
