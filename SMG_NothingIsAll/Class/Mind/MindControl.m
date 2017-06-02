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
    id need;
    if (status == HungerStatus_LitterHunger) {
        need = [NeedFactory createNeed];
    }else if (status == HungerStatus_Hunger) {
        need = [NeedFactory createNeed];
    }else if (status == HungerStatus_VeryHunger) {
        need = [NeedFactory createNeed];
    }else if (status == HungerStatus_VeryVeryHunger) {
        need = [NeedFactory createNeed];
    }
    //执行任务分析决策
    if (need) {
        [Decision commitFromMindWithNeed:need];
    }
}

@end
