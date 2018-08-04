//
//  TCLoopManager.h
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/8/4.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------思维控制器-循环管理器--------------------
 */
@interface TCLoopManager : NSObject


/**
 *  MARK:--------------------joinToCMVCache--------------------
 *  1. 添加新的cmv到cache,并且自动撤消掉相对较弱的同类同向mv;
 *  2. 在assData等(内心活动,不抵消cmvCache中旧任务)
 *  3. 在dataIn时,抵消旧任务,并生成新任务;
 */
-(void) addToCMVCache:(NSString*)algsType urgentTo:(NSInteger)urgentTo delta:(NSInteger)delta order:(NSInteger)order;


/**
 *  MARK:--------------------dataLoop联想(每次循环的检查执行点)--------------------
 *  注:assExp联想经验(饿了找瓜)(递归)
 *  注:loopAssExp中本身已经是内心活动联想到的mv
 *  1. 有条件(energy>0)
 *  2. 有尝(energy-1)
 *  3. 不指定model (从cmvCache取)
 *
 */
-(void) dataLoop_AssociativeExperience;


/**
 *  MARK:--------------------更新energy--------------------
 */
-(void) updateEnergy:(NSInteger)delta;


/**
 *  MARK:--------------------dataIn_Mv时及时加到manager--------------------
 */
-(void) dataIn_CmvAlgsArr:(NSArray*)algsArr;


@end
