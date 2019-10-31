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

/**
 *  MARK:--------------------根据v_ps索引绝对匹配的algNode--------------------
 *  说明: 获取value_ps相匹配的概念;
 *      1. 获取绝对匹配到value_ps的algNode (概念引用联想的方式去重)
 *      2. 先从内存网络,再从硬盘网络找;
 */
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p;
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps;
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps exceptAlg_p:(AIPointer*)exceptAlg_p isMem:(BOOL)isMem;

@end
