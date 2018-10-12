//
//  AINetUtils.h
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>


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

@end

