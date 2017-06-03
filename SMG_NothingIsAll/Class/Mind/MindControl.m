//
//  MindControll.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MindControl.h"
#import "MindHeader.h"
#import "ThinkHeader.h"

@implementation MindControl


/**
 *  MARK:--------------------mine饥饿--------------------
 *  产生充电需求
 */
-(void) commitFromMineForHunger{
    HungerStatus status = [Mine getHungerStatus];
    id demand;
    if (status == HungerStatus_LitterHunger) {
        demand = [DemandFactory createDemand];
    }else if (status == HungerStatus_Hunger) {
        demand = [DemandFactory createDemand];
    }else if (status == HungerStatus_VeryHunger) {
        demand = [DemandFactory createDemand];
    }else if (status == HungerStatus_VeryVeryHunger) {
        demand = [DemandFactory createDemand];
    }
    //执行任务分析决策
    if (demand) {
        [Decision commitFromMindWithDemand:demand];
    }
}

@end
