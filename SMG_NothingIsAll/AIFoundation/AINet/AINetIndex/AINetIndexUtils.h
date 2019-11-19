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
 *  说明: 获取value_ps相匹配的概念;
 *      1. 获取绝对匹配到value_ps的algNode (概念引用联想的方式去重)
 *      2. 先从内存网络,再从硬盘网络找;
 */
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValueP:(AIPointer*)value_p;
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps;
+(AIAlgNodeBase*) getAbsoluteMatchingAlgNodeWithValuePs:(NSArray*)value_ps exceptAlg_p:(AIPointer*)exceptAlg_p isMem:(BOOL)isMem;



//MARK:===============================================================
//MARK:                     < 概念局部匹配 >
//MARK:===============================================================

/**
 *  MARK:--------------------概念局部匹配--------------------
 *  @param except_ps : 排除_ps; (如:同一批次输入的概念组,不可用来识别自己)
 */
+(AIAlgNodeBase*) partMatching_Alg:(AIAlgNodeBase*)algNode isMem:(BOOL)isMem except_ps:(NSArray*)except_ps;

/**
 *  MARK:--------------------通用局部匹配方法--------------------
 *  注: 根据引用找出相似度最高且达到阀值的结果返回; (相似度匹配)
 *  从content_ps的所有value.refPorts找前cPartMatchingCheckRefPortsLimit个, 如:contentCount9*limit5=45个;
 *  @param exceptBlock : notnull 排除回调,不可激活则返回true;
 *  @param refPortsBlock : notnull 取item_p.refPorts的方法;
 *  @result 把最匹配的返回;
 */
+(id) partMatching_General:(NSArray*)proto_ps
             refPortsBlock:(NSArray*(^)(AIKVPointer *item_p))refPortsBlock
               exceptBlock:(BOOL(^)(AIKVPointer *target_p))exceptBlock;

@end
