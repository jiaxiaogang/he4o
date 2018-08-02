//
//  ThinkingCmvCacheModel.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/2.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------思维控制器中任务序列的_数据模型--------------------
 *
 *
 */
@interface ThinkingCmvCacheModel : NSObject

@property (assign, nonatomic) NSInteger urgentTo;
@property (assign, nonatomic) NSInteger delta;
@property (strong, nonatomic) NSString *algsType;

/**
 *  MARK:--------------------order排序因子--------------------
 *  1. order是实时变化的,(如,因为懒而order-,导致某任务决定放弃)
 *
 *  注: 后续添加对时间衰减的支持
 */
@property (assign, nonatomic) NSInteger order;

@end
