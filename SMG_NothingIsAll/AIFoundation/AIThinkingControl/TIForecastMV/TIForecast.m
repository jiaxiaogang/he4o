//
//  TIForecast.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TIForecast.h"

@implementation TIForecast

+(void) feedbackTIR:(AIShortMatchModel*)model{
    //1. 从短时记忆树上,取所有actYes模型,并与新输入的概念做mIsC判断;
    
    //7. 传给TIR,做下一步处理;
    [AIThinkInReason tir_OPushM:model];
}

+(BOOL) feedbackTOR:(AIShortMatchModel*)model{
    //4. 将新一帧数据报告给TOR,以进行短时记忆的更新,比如我输出行为"打",短时记忆由此知道输出"打"成功 (外循环入->推进->中循环出);
    BOOL pushOldDemand = [theTOR tor_OPushM:theTC.outModelManager.getCurrentDemand latestMModel:model];
    return pushOldDemand;
}

/**
 *  MARK:--------------------理性noMv输入处理--------------------
 *  @desc 输入noMv时调用,执行OPushM + 更新R任务池 + 执行R决策;
 *  联想网络杏仁核得来的则false;
 *  @version
 *      2020.10.19: 将add至ShortMatchManager代码前迁;
 */
+(void) foreastMv:(AIShortMatchModel*)model{
    //6. 传给TOR,做下一步处理;
    [TODemand rDemand:model];
    
    //7. TOR反馈;
    BOOL pushOldDemand = [self feedbackTOR:model];
    
    //6. 此处推进不成功,则运行TOP四模式;
    if (!pushOldDemand) {
        [theTO dataOut];
    }
}

+(void) foreastIRT:(AIShortMatchModel*)model{
    //TODOTOMORROW20211130: 考虑将IRT触发器,交由任务树来完成,即每一条输入都很更新到任务树,任务树里的每一个分支都自带IRT预测;
    [AIThinkInReason tir_Forecast:model];
}

@end
