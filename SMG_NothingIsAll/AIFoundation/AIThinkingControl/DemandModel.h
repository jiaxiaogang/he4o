//
//  DemandModel.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/2.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"

/**
 *  MARK:--------------------思维控制器中任务序列的_数据模型--------------------
 */
@class TOMvModel;
@interface DemandModel : TOModelBase

@property (assign, nonatomic) NSInteger urgentTo;
@property (assign, nonatomic) NSInteger delta;
@property (strong, nonatomic) NSString *algsType;

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

@end
