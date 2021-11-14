//
//  DemandManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------思维控制器-循环管理器--------------------
 */
@class DemandModel,AIShortMatchModel;
@interface DemandManager : NSObject

/**
 *  MARK:--------------------生成P任务--------------------
 *  1. 添加新的cmv到cache,并且自动撤消掉相对较弱的同类同向mv;
 *  2. 在assData等(内心活动,不抵消cmvCache中旧任务)
 *  3. 在dataIn时,抵消旧任务,并生成新任务;
 */
-(void) updateCMVCache_PMV:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta;

/**
 *  MARK:--------------------生成R任务--------------------
 *  @desc RMV输入更新任务管理器 (理性思维预测mv加入)
 */
-(void) updateCMVCache_RMV:(AIShortMatchModel*)inModel;

/**
 *  MARK:--------------------生成子任务--------------------
 *  @param rtInModel : 反思结果;
 *  @param baseFo : 反思基于此fo进行的,将反思产生的子任务挂在这下面;
 */
+(void) updateSubDemand:(AIShortMatchModel*)rtInModel baseFo:(TOFoModel*)baseFo createSubDemandBlock:(void(^)(ReasonDemandModel*))createSubDemandBlock finishBlock:(void(^)(NSArray*))finishBlock;

/**
 *  MARK:--------------------dataIn_Mv时及时加到manager--------------------
 */
//-(void) dataIn_CmvAlgsArr:(NSArray*)algsArr;


/**
 *  MARK:--------------------获取任务--------------------
 */
-(DemandModel*) getCurrentDemand;       //获取当前,最紧急任务;
-(DemandModel*) getCanDecisionDemand;   //获取当前,可以继续决策的任务 (未完成 & 非等待反馈ActYes);


/**
 *  MARK:--------------------返回所有demand任务--------------------
 */
-(NSArray*) getAllDemand;


/**
 *  MARK:--------------------移除某任务--------------------
 */
-(void) removeDemand:(DemandModel*)demand;

/**
 *  MARK:--------------------获取R任务的抽具象路径上的所有R任务--------------------
 */
-(NSArray*) getRDemandsBySameClass:(ReasonDemandModel *)rDemand;

@end
