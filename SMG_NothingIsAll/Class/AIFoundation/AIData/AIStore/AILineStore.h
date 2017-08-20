//
//  AILineStore.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/23.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIStoreBase.h"

@interface AILineStore : AIStoreBase


/**
 *  MARK:--------------------根据pointers搜索--------------------
 *
 *  @param pointers : 指针匹配
 *  @param count    : 搜索个数
 */
+(NSMutableArray*) searchPointers:(NSArray*)pointers count:(NSInteger)count;


/**
 *  MARK:--------------------根据pointer.Class搜索--------------------
 *  如:如搜索aObj与bObj的"Law规律"常识;
 *  @param pointers : 指针匹配
 *  @param count    : 搜索个数
 */
+(NSMutableArray*) searchPointersByClass:(NSArray*)pointers count:(NSInteger)count;


/**
 *  MARK:--------------------根据LineType搜索--------------------
 *  如:如搜索aObj的归纳父类
 *  @param pointers : 指针匹配
 *  @param type     : LineType匹配
 *  @param count    : 搜索个数
 */
+(NSMutableArray*) searchPointersByClass:(NSArray*)pointers type:(AILineType)type count:(NSInteger)count;


/**
 *  MARK:--------------------根据Pointer搜索--------------------
 *
 *  @param pointer : 指针匹配
 *  @param count    : 搜索个数
 */
+(NSMutableArray*) searchPointer:(AIPointer*)pointer count:(NSInteger)count;


/**
 *  MARK:--------------------根据Pointer和energy搜索--------------------
 *
 *  @param pointer : 指针匹配
 *  @param energy  : 能量位
 */
+(NSMutableArray*) searchPointer:(AIPointer*)pointer energy:(CGFloat)energy;//根据"能量"以"pointer"为中心搜索;


/**
 *  MARK:--------------------插入数据--------------------
 *
 *  @param data : 数据
 */
+(void) insert:(AIObject *)data;

@end
