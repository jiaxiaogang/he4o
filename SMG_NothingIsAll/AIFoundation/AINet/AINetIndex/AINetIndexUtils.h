//
//  AINetIndexUtils.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/10/31.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------索引工具类--------------------
 */
@interface AINetIndexUtils : NSObject


//MARK:===============================================================
//MARK:                     < 概念绝对匹配 >
//MARK:===============================================================

/**
 *  MARK:--------------------根据v_ps索引绝对匹配的algNode--------------------
 *  说明: 获取value_ps相匹配的概念; (header匹配)
 *      1. 获取绝对匹配到value_ps的algNode (概念引用联想的方式去重)
 *      2. 先从内存网络,再从硬盘网络找;
 *  @pparam isMem : 是否从内存网络找;
 */
+(id) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p;
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps;
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps except_ps:(NSArray*)except_ps isMem:(BOOL)isMem;


//MARK:===============================================================
//MARK:                     < 时序绝对匹配 >
//MARK:===============================================================
+(AIFoNodeBase*) getAbsoluteMatchingFoNodeWithContent_ps:(NSArray*)content_ps except_ps:(NSArray*)except_ps isMem:(BOOL)isMem;

@end
