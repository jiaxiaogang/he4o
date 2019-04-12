//
//  DemandModel.h
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
@class TOMvModel;
@interface DemandModel : NSObject

@property (assign, nonatomic) NSInteger urgentTo;
@property (assign, nonatomic) NSInteger delta;
@property (strong, nonatomic) NSString *algsType;
@property (strong, nonatomic) NSMutableArray *outMvModels;  //缓存的几种outMvModel;(order从大到小排序)
@property (strong, nonatomic) NSMutableArray *exceptOutMvModels;  //已排除的outMvModels;


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
 *  MARK:--------------------获取当前最强的outMvModel--------------------
 */
-(TOMvModel*) getCurrentTOMvModel;


/**
 *  MARK:--------------------新增outMvModel--------------------
 */
-(void) addToExpCache:(TOMvModel*)outMvModel;

@end
