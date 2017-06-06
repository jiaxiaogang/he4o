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

@interface MindControl ()<MineDelegate>

@end

@implementation MindControl

-(id) init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

-(void) initData{
    self.mine = [[Mine alloc] init];
    self.mood = [[Mood alloc] init];
    self.hobby = [[Hobby alloc] init];
}

-(void) initRun{
    self.mine.delegate = self;
}


/**
 *  MARK:--------------------method--------------------
 */
-(int) getMoodValue:(AIPointer*)pointer{
    //xxx这个值还没存;
    int moodValue = (random() % 2) - 1;
    if (moodValue < 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mindControl_AddDemand:withType:)]) {
            [self.delegate mindControl_AddDemand:@"怼他" withType:MindType_Angry];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(mindControl_AddDemand:withType:)]) {
            [self.delegate mindControl_AddDemand:@"大笑" withType:MindType_Happy];
        }
    }
    return moodValue;
}


/**
 *  MARK:--------------------MineDelegate--------------------
 */
-(void)mine_HungerStateChanged:(HungerStatus)status{
    NSLog(@"Mind_产生充电需求");
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
    
    //思考3:
    //接上疑问;有别人吃你的水果;
    //影响反应结果的因素:
    //1,不同的人吃,影响结果;(亲朋吃则无所谓)__对人的hobby
    //2,我对此水果的喜好,影响结果;(吃我的苹果可以,香蕉不行!)__对物的hobby
    //3,我对此水果的来源,影响结果;(有些来之不易,有些来自平安夜的礼物)__对物关联(附加价值)的hobby
    //4,我自己饥饿程度,影响结果;(我饱着,你随便吃,我饿着,不行!)__物对已的需求程度
    //总结:各种Mind中因素相互博弈的结果;
    
}

@end
