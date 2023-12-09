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
//MARK:                     < 绝对匹配 (概念/时序) 通用方法 >
//MARK:===============================================================

/**
 *  MARK:--------------------alg/fo 绝对匹配通用方法--------------------
 *  @todo
 *      1. 随后支持只匹配抽象alg/fo (可由checkItemValid来实现) (可用于概念识别,因为概念识别为具象时,会导致无法建立抽具象关联);
 *          说明: 不过随后抽具象节点类会统一,所以如果这个影响不到v2.0则可不做;
 *  @param ds : 当有ds防重要求时,传入ds (如fo的不同inner类型无需去重) (为empty时,不做防重要求);
 */
+(id) getAbsoluteMatching_General:(NSArray*)content_ps sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps getRefPortsBlock:(NSArray*(^)(AIKVPointer *item_p))getRefPortsBlock at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type;

/**
 *  MARK:--------------------绝对匹配 + 限定范围--------------------
 */
+(id) getAbsoluteMatching_ValidPs:(NSArray*)content_ps sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps noRepeatArea_ps:(NSArray*)noRepeatArea_ps getRefPortsBlock:(NSArray*(^)(AIKVPointer *item_p))getRefPortsBlock at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type;

/**
 *  MARK:--------------------从指定范围中获取绝对匹配--------------------
 *  @param validPorts : 指定范围域;
 */
+(id) getAbsoluteMatching_ValidPorts:(NSArray*)validPorts sort_ps:(NSArray*)sort_ps except_ps:(NSArray*)except_ps at:(NSString*)at ds:(NSString*)ds type:(AnalogyType)type;

//MARK:===============================================================
//MARK:                     < 索引序列 >
//MARK:===============================================================
/**
 *  MARK:--------------------索引序列--------------------
 */
+(AINetIndexModel*) searchIndexModel:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut;
+(void) insertIndexModel:(AINetIndexModel*)model isOut:(BOOL)isOut;

/**
 *  MARK:--------------------稀疏码值字典--------------------
 */
+(NSDictionary*) searchDataDic:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut;
+(void) insertDataDic:(NSDictionary*)dataDic at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut;

/**
 *  MARK:--------------------取两个V差值--------------------
 */
+(CGFloat) deltaWithValueA:(double)valueA valueB:(double)valueB at:(NSString*)at ds:(NSString*)ds isOut:(BOOL)isOut vInfo:(AIValueInfo*)vInfo;

@end
