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
 *  @version
 *      20200416 - 因概念全局去重了,导致此处绝对匹配算法,不再有用了;
 *  @callers
 *      1. TIR_Alg识别算法中,绝对匹配部分;
 *      2. 内类比获取;
 */
//+(id) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p;
//+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps;
//+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps except_ps:(NSArray*)except_ps isMem:(BOOL)isMem;


//MARK:===============================================================
//MARK:                     < 绝对匹配 (概念/时序) 通用方法 >
//MARK:===============================================================

/**
 *  MARK:--------------------alg/fo 绝对匹配通用方法--------------------
 *  @todo
 *      1. 随后支持只匹配抽象alg/fo (可由checkItemValid来实现) (可用于概念识别,因为概念识别为具象时,会导致无法建立抽具象关联);
 *          说明: 不过随后抽具象节点类会统一,所以如果这个影响不到v2.0则可不做;
 *  @param ds : 当有ds防重要求时,传入ds (如fo的不同inner类型无需去重) (为empty时,不做防重要求);
 */
+(id) getAbsoluteMatching_General:(NSArray*)content_ps sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps getRefPortsBlock:(NSArray*(^)(AIKVPointer *item_p))getRefPortsBlock ds:(NSString*)ds;

@end
