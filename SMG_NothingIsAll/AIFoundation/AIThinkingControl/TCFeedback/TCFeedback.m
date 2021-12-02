//
//  TCFeedback.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCFeedback.h"

@implementation TCFeedback


//TODOTOMORROW20211202: 将四个feedback方法迁移过来; (原来的直接删掉,把所有调用处也查下看有没有了);==========

+(void) feedbackTIR:(AIShortMatchModel*)model{
    //1. 从短时记忆树上,取所有actYes模型,并与新输入的概念做mIsC判断;
    
    //7. 传给TIR,做下一步处理;
    [AIThinkInReason tir_OPushM:model];
    
    //6. 传给TOR,做下一步处理: R任务_预测mv价值变化;
    [TCForecast rForecastFront:model];
}

+(void) feedbackTOR:(AIShortMatchModel*)model{
    //4. 将新一帧数据报告给TOR,以进行短时记忆的更新,比如我输出行为"打",短时记忆由此知道输出"打"成功 (外循环入->推进->中循环出);
    BOOL pushOldDemand = [theTOR tor_OPushM:theTC.outModelManager.getCurrentDemand latestMModel:model];
    
    //7. 任务预测处理;
    [TCForecast rForecastBack:model pushOldDemand:pushOldDemand];
    
    //8. IRT触发器;
    [TCForecast forecastIRT:model pushOldDemand:pushOldDemand];
}

+(void) feedbackTIP:(AICMVNode*)cmvNode{
    [AIThinkInPercept tip_OPushM:cmvNode];
}

+(void) feedbackTOP:(AICMVNode*)cmvNode{
    //1. 反馈
    [AIThinkOutPercept top_OPushM:cmvNode];
    
    //3. p任务;
    [TCForecast pForecast:cmvNode];
}

+(void) feedbackSubDemand:(AIShortMatchModel*)model{
    //5. 生成子任务;
    [TCForecast forecastSubDemand:model];
}

@end
