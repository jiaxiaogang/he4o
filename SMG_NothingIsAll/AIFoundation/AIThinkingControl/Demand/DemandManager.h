//
//  DemandManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DemandManagerDelegate <NSObject>

-(void) demandManager_updateEnergy:(CGFloat)urgentTo;

@end

/**
 *  MARK:--------------------思维控制器-循环管理器--------------------
 */
@class DemandModel,AIShortMatchModel;
@interface DemandManager : NSObject

@property (weak, nonatomic) id<DemandManagerDelegate> delegate;

/**
 *  MARK:--------------------joinToCMVCache--------------------
 *  1. 添加新的cmv到cache,并且自动撤消掉相对较弱的同类同向mv;
 *  2. 在assData等(内心活动,不抵消cmvCache中旧任务)
 *  3. 在dataIn时,抵消旧任务,并生成新任务;
 */
-(void) updateCMVCache_PMV:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta;

/**
 *  MARK:--------------------理性思维预测mv加入--------------------
 */
-(void) updateCMVCache_RMV:(AIShortMatchModel*)inModel;


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

@end
