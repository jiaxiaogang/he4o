//
//  AINetUtils.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIAlgNode;
@interface AINetUtils : NSObject

/**
 *  MARK:--------------------检查是否可以输出algsType&dataSource--------------------
 *  1. 有过输出记录,即可输出;
 */
+(BOOL) checkCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource;


/**
 *  MARK:--------------------标记canout--------------------
 *  @param algsType     : 分区标识
 *  @param dataSource   : 算法标识
 */
+(void) setCanOutput:(NSString*)algsType dataSource:(NSString*)dataSource ;


//MARK:===============================================================
//MARK:                     < algTypeNodeUtils >
//MARK:===============================================================

/**
 *  MARK:--------------------构建algNode--------------------
 *  1. 自动将algsArr中的元素分别生成absAlgNode
 *  2. absAlgNode根据索引的去重而去重;
 *  3. 具象algNode根据网络中联想而去重; (for(abs1.cons) & for(abs2.cons))
 *  4. abs和con都要有关联强度序列; (目前不需要,以后有需求的时候再加上)
 *
 *  @param algsArr   : 算法值的装箱数组;
 *  @result 具象algNode
 */
+(AIAlgNode*) createAlgNode:(NSArray*)algsArr;


/**
 *  MARK:--------------------插线到ports--------------------
 */
+(void) insertPointer:(AIPointer*)pointer toPorts:(NSMutableArray*)ports;


@end
