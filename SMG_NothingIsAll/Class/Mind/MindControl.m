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
        if (self.delegate && [self.delegate respondsToSelector:@selector(mindControl_AddDemand:withType:)]) {
            [self.delegate mindControl_AddDemand:demand withType:MindType_Hunger];
        }
    }
    
    
    //思考2:当A在偷吃你的苹果时;你理解的重点是;他是不是吃的你的苹果;吃了多少;等相关信息;
    //注意力,
    //但Input输入A吃苹果时,Understand先理解并分析出苹果的归属及整个事件;然后交由Mind决定是不是打死他;(Mind需要的信息:A是谁,在作什么,吃了谁的什么);
    //假如是其它事情呢;我需要找到一种万能的方式去解决Mind的控制流程;而不是把数据全部传过来作处理;Mind从职责上;只负责送出自己的精神层面的值;分析结果应该是Think层的事;
    
    
    
}

@end
