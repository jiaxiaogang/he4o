//
//  MVCacheModel.h
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
@class ExpCacheModel;
@interface MVCacheModel : NSObject

@property (assign, nonatomic) NSInteger urgentTo;
@property (assign, nonatomic) NSInteger delta;
@property (strong, nonatomic) NSString *algsType;
@property (strong, nonatomic) NSMutableArray *expCache;


/**
 *  MARK:--------------------更新时间衰减--------------------
 *  1. 懒衰减,什么时候取order,什么时候进行衰减;
 *  2. 衰减规则:
 *      > 1分钟内加10;
 *      > 10分钟内持平;
 *      > 10分钟后-10;
 *      > 小于0则销毁;
 */
@property (assign, nonatomic) double updateTime;


/**
 *  MARK:--------------------order排序因子--------------------
 *  1. order是实时变化的,(如,因为懒而order-,导致某任务决定放弃)
 *  2. 懒运算,
 *  注: 后续添加对时间衰减的支持
 */
@property (assign, nonatomic) NSInteger order;


/**
 *  MARK:--------------------添加解决经验到当前思维任务--------------------
 */
-(void) addExpCacheModel:(MindHappyType)type urgentTo:(NSInteger)urgentTo outArr:(NSArray*)outArr exp_p:(AIPointer*)exp_p;



/**
 *  MARK:--------------------获取当前最强的expModel--------------------
 */
-(ExpCacheModel*) getCurrentExpCacheModel;


@end
