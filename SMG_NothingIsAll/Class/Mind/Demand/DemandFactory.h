//
//  DemandFactoryBase.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/2.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------需求工厂--------------------
 *  1,充电需求
 *  2,欲望需求
 *  3,例如:看到钱时,要捡起来;并且道德打败欲望,找失主;
 */
@interface DemandFactory : NSObject

/**
 *  MARK:--------------------产生需求任务--------------------
 *  return 任务
 *  参数:任务类型
 *  参数:任务...
 *  1,PhysiologicalDemands生理需求(充电)
 *  2,SafetyDemands安全需求(驱动好奇心)
 *  3,LoveAndBelongingDemands社交需求
 *  4,
 */
+(id) createDemand;

@end
