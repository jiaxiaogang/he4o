//
//  NVModuleUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/7/10.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NVModuleUtil : NSObject

//将data装成group并返回; (groups已有,则返回包含data的group)
+(NSArray*) getOrCreateGroupWithData:(id)data groups:(NSMutableArray*)groups;
+(BOOL) isRelateWithData1:(id)data1 data2:(id)data2 compareModels:(NSArray*)compareModels;

/**
 *  MARK:--------------------比较nodeData1和2的抽具象关系--------------------
 *  @result : 抽象为大,具象为小,无关系为相等
 *  @desc : 排序规则: (从具象到抽象 / 从小到大)
 */
+(NSComparisonResult)compareNodeData1:(id)n1 nodeData2:(id)n2 indexDic:(NSDictionary*)indexDic;


/**
 *  MARK:--------------------获取dataArr的排版分组--------------------
 *  注: 其中最具象为0,抽象往上,越抽象值越大,越具象值越小;
 *  @result : 二维数组,元素为组,组中具象在前,抽象在后;
 */
+(NSMutableArray*) getSortGroups:(NSArray*)nodeArr compareModels:(NSArray*)compareModels indexDic:(NSDictionary*)indexDic;


/**
 *  MARK:--------------------检查group中有没有和checkData有关系的--------------------
 */
+(BOOL) containsRelateWithData:(id)checkData fromGroup:(NSArray*)group compareModels:(NSArray*)compareModels;


/**
 *  MARK:--------------------compareModels转为indexDic--------------------
 *  @result nutnull
 */
+(NSDictionary*)convertIndexDicWithCompareModels:(NSArray*)compareModels;


/**
 *  MARK:--------------------获取data的key形态--------------------
 */
+(NSData*) keyOfData:(id)data;
+(id) dataOfKey:(NSData*)key;

@end
