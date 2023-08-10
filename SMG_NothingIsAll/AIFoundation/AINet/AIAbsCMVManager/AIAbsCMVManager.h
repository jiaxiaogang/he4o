//
//  AIAbsCMVManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/27.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  MARK:--------------------生成AINetAbsCMVNode--------------------
 *  1. 抽象cmv节点不需要去重,(昨天三分饿和今天三分饿,是两个节点)
 *  2. cmv相较普通node数据,是快消品;
 *
 *  注: 因为absCmvNode是不去重的;
 *  > 1. 所以,absCmvNode不具有集体性抽象;
 *  > 2. 所以,absCmvNode的更高维抽象不存在;(不存在饿的饿的饿)(爱的爱的爱)
 *  > 3. 所以,absCmvNode的抽象是依托于"前因时序节点"的抽象的;
 */
@class AIAbsCMVNode,AIKVPointer;
@interface AIAbsCMVManager : NSObject

/**
 *  MARK:--------------------在两个cmvNode基础上构建抽象--------------------
 *  @params absFo_p : 抽象宏节点(前因)
 *  @params aMv_p : cmv节点A
 *  @params bMv_p : cmv节点B
 *  注: 融合方式,可参考:n16p1
 */
-(AIAbsCMVNode*) create:(AIKVPointer*)absFo_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p ;
-(AIAbsCMVNode*) create:(AIKVPointer*)absFo_p conMvPs:(NSArray*)conMv_ps;

@end
