//
//  AINetAbsIndex.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/6/5.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 宏信息索引 >
//MARK:===============================================================
@class AIKVPointer,AINetAbsNode,AIPort;
@interface AINetAbsIndex : NSObject

//根据refs_p(查找或创建)absValue,并返回地址;
-(AIKVPointer*) getAbsValuePointer:(NSArray*)refs_p;


/**
 *  MARK:--------------------根据absValuePointer操作其被引用的相关;--------------------
 *  @param indexPointer : value地址
 *  @param target_p : 引用者地址(如:xxAbsNode.pointer)
 */
-(void) setIndexReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue;


/**
 *  MARK:--------------------获取absValue所被引用的absNode地址;--------------------
 */
-(AIKVPointer*) getAbsNodePointer:(AIKVPointer*)absValue_p;

@end
