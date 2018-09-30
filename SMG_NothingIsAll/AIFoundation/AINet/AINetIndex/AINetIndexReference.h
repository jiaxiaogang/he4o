//
//  AINetIndexReference.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK:===============================================================
//MARK:                     < 微信息引用_itemData区(第二序列) >
//MARK:===============================================================
@class AIKVPointer,AIPort;
@interface AINetIndexReference : NSObject

/**
 *  MARK:--------------------根据absValuePointer操作其被引用的相关;--------------------
 *  @param indexPointer : value地址
 *  @param target_p : 引用者地址(如:xxNode.pointer)
 */
-(void) setReference:(AIKVPointer*)indexPointer target_p:(AIKVPointer*)target_p difValue:(int)difValue;


/**
 *  MARK:--------------------获取value被引用的node地址;--------------------
 *  @param indexPointer : value_p地址
 *  @param limit : 最多结果个数
 *  @result Return NSArray(元素为AIPort)
 *
 *  @desc : 1.当indexPointer为absValue时,则只有absNode和frontNode会被搜索到;
 *  @desc : 2.当indexPointer为普通value时,则有可能搜索到除absNode之外的所有其它node(如:frontNode或mvNode等)
 */
-(NSArray*) getReference:(AIKVPointer*)indexPointer limit:(NSInteger)limit;


/**
 *  MARK:--------------------获取value被引用的absNode地址;--------------------
 *  @param absValue_p : value_p地址
 *  @param limit : 最多结果个数
 *  @result Return NSArray(元素为AIPort)
 *  @desc : 1.当indexPointer为absValue时,则只有absNode会被搜索到;
 */
-(NSArray*) getReference_JustAbsResult:(AIKVPointer*)absValue_p limit:(NSInteger)limit;


@end
