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

/**
 *  MARK:--------------------学习--------------------
 *  分为:
 *   1. 外类比
 *   2. 内类比
 *  解释:
 *   1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *   2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 *  步骤:
 *   > 联想->类比->规律->抽象->关联->网络
 *  @version
 *      2020.03.04: a.去掉外类比; b.外类比拆分为:正向类比和反向类比;
 *      2021.01.24: 支持多时序识别,更全面的触发外类比 (参考22073-todo4);
 */
+(void) feedbackLearning:(AIFoNodeBase*)protoFo{
    
    //2. 获取最近的识别模型;
    NSArray *inModels = ARRTOOK(theTC.inModelManager.models);
    for (AIShortMatchModel *item in inModels) {
        for (AIMatchFoModel *pFo in item.matchPFos) {
            
            //3. 正向反馈类比 (外类比);
            [AIAnalogy analogy_Feedback_Same:pFo.matchFo shortFo:protoFo];
        }
    }
}

+(BOOL) feedbackTOR:(AIShortMatchModel*)model{
    //4. 将新一帧数据报告给TOR,以进行短时记忆的更新,比如我输出行为"打",短时记忆由此知道输出"打"成功 (外循环入->推进->中循环出);
    BOOL pushOldDemand = [theTOR tor_OPushM:theTC.outModelManager.getCurrentDemand latestMModel:model];
    return pushOldDemand;
}

+(void) feedbackTIP:(AICMVNode*)cmvNode{
    [AIThinkInPercept tip_OPushM:cmvNode];
}

+(void) feedbackTOP:(AICMVNode*)cmvNode{
    [AIThinkOutPercept top_OPushM:cmvNode];
}

/**
 *  MARK:--------------------理性noMv输入处理--------------------
 *  @desc 输入noMv时调用,执行OPushM + 更新R任务池 + 执行R决策;
 *  联想网络杏仁核得来的则false;
 *  @version
 *      2020.10.19: 将add至ShortMatchManager代码前迁;
 */
+(void) rForecast:(AIShortMatchModel*)model{
    //6. 传给TOR,做下一步处理;
    [TODemand rDemand:model];
    
    //7. TOR反馈;
    BOOL pushOldDemand = [self feedbackTOR:model];
    
    //6. 此处推进不成功,则运行TOP四模式;
    if (!pushOldDemand) {
        [theTO dataOut];
    }
}

/**
 *  MARK:--------------------感性mv输入处理--------------------
 *  @desc 输入mv时调用,执行OPushM + 更新P任务池 + 执行P决策;
 *  @param cmvNode  : 要处理的mvNode
 *  @desc 功能说明:
 *      1. 更新energy值
 *      2. 更新需求池
 *      3. 进行dataOut决策行为化;
 */
+(void) pForecast:(AICMVNode*)cmvNode{
    //4. tip_OPushM
    [self feedbackTIP:cmvNode];
    
    //5. 思考mv,需求处理
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    if (delta == 0) {
        return;
    }
    
    //2. top_OPushM
    [self feedbackTOP:cmvNode];
    
    //2. 将联想到的cmv更新energy & 更新demandManager & decisionLoop
    NSString *algsType = cmvNode.urgentTo_p.algsType;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:cmvNode.urgentTo_p]) integerValue];
    [theTC.outModelManager updateCMVCache_PMV:algsType urgentTo:urgentTo delta:delta];
    [theTO dataOut];
}


/**
 *  MARK:--------------------预测--------------------
 *  @desc
 *      1. 对预测的处理,进行生物钟触发器;
 *      2. 支持:
 *          a.HNGL(因为时序识别处关闭,所以假启用状态);
 *          b.MV(启用);
 *  @version
 *      2021.01.27: 非末位也支持mv触发器 (参考22074-BUG2);
 *      2021.02.01: 支持反向反馈外类比 (参考22107);
 *      2021.02.04: 虚mv不会触发In反省,否则几乎永远为逆 (因为本来虚mv就不会有输入的);
 *      2021.02.04: 虚mv也要支持In反省,否则无法形成对R-模式助益 (参考22108);
 *      2021.10.12: SP的定义由顺逆改为好坏,所以此处相应触发SP的反省改正 (参考24054-实践);
 *      2021.10.17: IRT触发器理性失效时,不进行反省 (参考24061-方案2);
 *  @todo
 *      2021.03.22: 迭代提高预测的准确性(1.以更具象为准(猴子怕虎,悟空不怕) 2.以更全面为准(猴子有麻醉枪不怕虎)) (参考22182);
 *  @status
 *      1. 后半部分"有mv判断"生效中;
 *      2. 前半部分"HNGL末位判断"未启用 (因为matchFos中未涵盖HNGL类型);
 */
+(void) forecastIRT:(AIShortMatchModel*)inModel{
    //TODOTOMORROW20211130: 考虑将IRT触发器,交由任务树来完成,即每一条输入都很更新到任务树,任务树里的每一个分支都自带IRT预测;
    
    //1. 数据检查;
    if (!inModel) return;
    AIFoNodeBase *protoFo = inModel.protoFo;
    IFTitleLog(@"预测",@"\nprotoFo:%@",Fo2FStr(protoFo));
    
    //3. 预测处理_反向反馈类比_生物钟触发器;
    for (AIMatchFoModel *item in inModel.matchPFos) {
        AIFoNodeBase *matchFo = item.matchFo;
        BOOL isHNGL = [TOUtils isHNGL:matchFo.pointer];
        if (isHNGL) {
            ////末位判断;
            //if (item.cutIndex2 == matchFo.count - 2) {
            //    item.status = TIModelStatus_LastWait;
            //    double deltaTime = [NUMTOOK(ARR_INDEX_REVERSE(matchFo.deltaTimes, 0)) doubleValue];
            //    [AITime setTimeTrigger:deltaTime trigger:^{
            //        //4. 反向反馈类比(成功/未成功)的主要原因;
            //        AnalogyType type = (item.status == TIModelStatus_LastWait) ? ATSub : ATPlus;
            //        NSLog(@"---//触发器HNGL_触发: %@ (%@)",Fo2FStr(matchFo),ATType2Str(type));
            //        [AIAnalogy analogy_InRethink:item shortFo:protoFo type:type];
            //
            //        //5. 失败状态标记;
            //        if (item.status == TIModelStatus_LastWait) item.status = TIModelStatus_OutBackNone;
            //    }];
            //}
        }else{
            //有mv判断;
            if (matchFo.cmvNode_p) {
                item.status = TIModelStatus_LastWait;
                double deltaTime = [TOUtils getSumDeltaTime2Mv:matchFo cutIndex:item.cutIndex2];
                NSLog(@"---//IRT触发器新增:%p %@ (%@ | useTime:%.2f)",matchFo,Fo2FStr(matchFo),TIStatus2Str(item.status),deltaTime);
                [AITime setTimeTrigger:deltaTime trigger:^{
                    //3. 如果状态已改成OutBackReason,触发器失效,不进行反省;
                    if (item.status == TIModelStatus_OutBackReason) {
                        return;
                    }
                    
                    //4. 反向反馈类比(成功/未成功)的主要原因 (参考tip_OPushM());
                    AnalogyType type = ATDefault;
                    if ([AINetUtils isVirtualMv:matchFo.cmvNode_p]) {
                        //a. 虚mv反馈反向:S,未反馈:P;
                        type = (item.status == TIModelStatus_OutBackDiffDelta) ? ATSub : ATPlus;
                    }else{
                        CGFloat score = [AIScore score4MV:matchFo.cmvNode_p ratio:1.0f];
                        if (score > 0) {
                            //b. 实mv+反馈同向:P(好),未反馈:S(坏);
                            type = (item.status == TIModelStatus_OutBackSameDelta) ? ATPlus : ATSub;
                        }else if(score < 0){
                            //b. 实mv-反馈同向:S(坏),未反馈:P(好);
                            type = (item.status == TIModelStatus_OutBackSameDelta) ? ATSub : ATPlus;
                        }
                    }
                    NSLog(@"---//IRT触发器执行:%p %@ (%@ | %@)",matchFo,Fo2FStr(matchFo),TIStatus2Str(item.status),ATType2Str(type));
                    
                    //4. 输入期反省类比 (有OutBack,SP类型时执行);
                    [AIAnalogy analogy_InRethink:item shortFo:protoFo type:type];
                    
                    //5. 反向反馈外类比 (无OutBack,为Wait时执行);
                    if (item.status == TIModelStatus_LastWait) {
                        [AIAnalogy analogy_Feedback_Diff:protoFo mModel:item];
                    }
                    
                    //5. 失败状态标记;
                    if (item.status == TIModelStatus_LastWait) item.status = TIModelStatus_OutBackNone;
                }];
            }
        }
    }
}

+(void) forecastSubDemand:(AIShortMatchModel*)model{
    [TODemand subDemand:model];
}

@end
