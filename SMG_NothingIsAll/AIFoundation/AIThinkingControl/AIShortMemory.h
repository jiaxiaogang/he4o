//
//  AIShortMemory.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/23.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------瞬时记忆--------------------
 *  1. 存最多8条algNode_p;
 */
@class AIPointer;
@interface AIShortMemory : NSObject


/**
 *  MARK:--------------------获取瞬时记忆序列--------------------
 */
-(NSMutableArray*) shortCache;

/**
 *  MARK:--------------------shortCache瞬时记忆--------------------
 *  1. 存由algsDic生成的algNode_p;
 */
-(void) addToShortCache_Ps:(NSArray*)ps;

/**
 *  MARK:--------------------清空记忆--------------------
 */
-(void) clear;

@end

