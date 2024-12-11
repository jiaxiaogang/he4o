//
//  TCForecast.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCForecast.h"

@implementation TCForecast

/**
 *  MARK:--------------------反省触发器--------------------
 *  @desc
 *      1. 对任务下一帧预测的等待反馈 (触发器等待反省);
 *  @version
 *      2021.01.27: 非末位也支持mv触发器 (参考22074-BUG2);
 *      2021.02.01: 支持反向反馈外类比 (参考22107);
 *      2021.02.04: 虚mv不会触发In反省,否则几乎永远为逆 (因为本来虚mv就不会有输入的);
 *      2021.02.04: 虚mv也要支持In反省,否则无法形成对R-模式助益 (参考22108);
 *      2021.10.12: SP的定义由顺逆改为好坏,所以此处相应触发SP的反省改正 (参考24054-实践);
 *      2021.10.17: IRT触发器理性失效时,不进行反省 (参考24061-方案2);
 *      2021.11.30: 将IRT触发器交由任务树来完成,即每条输入更新到任务树,任务树里每个分支都自带IRT预测;
 *                  > 弃做,何必绕圈子,原有做法: 时序预测直接做触发器就行;
 *      2021.12.25: 支持理性IRT反省;
 *      2022.03.05: 将forecastIRT分裂成感性和理性两个部分,分别处理不同的识别prFos结果,触发不同的反省 (参考25134-方案2-B预测);
 *      2023.03.15: 支持matchRFos也进行预测并统计SP (参考28182-todo2);
 *  @todo
 *      2021.03.22: 迭代提高预测的准确性(1.以更具象为准(猴子怕虎,悟空不怕) 2.以更全面为准(猴子有麻醉枪不怕虎)) (参考22182);
 *  @status
 *      1. 后半部分"有mv判断"生效中;
 *      2. 前半部分"HNGL末位判断"未启用 (因为matchFos中未涵盖HNGL类型);
 */
+(void) forecast_Multi:(NSArray*)matchPRFos{
    //1. 数据检查 (参考25031-1);
    [theTC updateOperCount:kFILENAME];
    Debug();
    if (Log4Forecast) ISTitleLog(@"matchFos预测");
    matchPRFos = ARRTOOK(matchPRFos);
        
    //2. 每个pFo的预测处理;
    for (AIMatchFoModel *prFo in matchPRFos) {
        //3. 已发生: 补上当前进度前面的SP计数P+1 (参考27213-4);
        AIFoNodeBase *matchFo = [SMGUtils searchNode:prFo.matchFo];
        
        //TODO: 这里仅仅是给当前I做了SP,但没同步推举到F,随后看是不是把这里改下,也调用TCRethink里的那个推举方法 或 AINetUtils里的那个IF推举方法;
        [matchFo updateSPStrong:0 end:prFo.cutIndex type:ATPlus caller:@"pFo的0到Cut已发生"];
        
        //4. 预测帧: 下帧预测触发器; (参考25031-2) ->feedbackTIR;
        [self forecast_Single:prFo];
    }
    DebugE();
}

/**
 *  MARK:--------------------单条prFo处理--------------------
 *  @desc 可自动根据cutIndex判断触发理性或感性: 反省触发器;
 *  @callers : 1. 用于新root调用; 2. 用于反省顺利时推进到下一帧的触发器;
 *  @version
 *      2022.09.18: 有反馈时移至feedback及时处理 (参考27098-todo2&3&4);
 *      2023.03.15: 支持rFos的预测 (参考28182-todo2);
 *      2023.03.15: rFos预测推进失败不设为Canset(因为它失败并不意味着解决了pFo) (参考28182-todo3);
 *      2023.03.21: 修复: pFo先失效,导致后面生成Canset时,未执行到此pFo的问题 (参考29011-问题);
 */
+(void) forecast_Single:(AIMatchFoModel*)item{
    //1. 数据准备;
    AIFoNodeBase *matchFo = [SMGUtils searchNode:item.matchFo];
    NSInteger maxCutIndex = matchFo.count - 1;
    NSInteger curCutIndex = item.cutIndex;
    
    //2. ========> 非末位时,理性反省 (参考25031-2);
    if (curCutIndex < maxCutIndex) {
        
        //4. 设为等待反馈状态 & 构建反省触发器;
        [item setStatus:TIModelStatus_LastWait forCutIndex:curCutIndex];
        double deltaTime = [NUMTOOK(ARR_INDEX(matchFo.deltaTimes, curCutIndex + 1)) doubleValue];
        
        if (Log4Forecast) NSLog(@"---//理性IRT触发器新增等待反馈:%p (%@ | useTime:%.2f)",matchFo,Fo2FStr(matchFo),deltaTime);
        [AITime setTimeTrigger:deltaTime trigger:^{
            //5. 如果状态还是Wait,则无反馈 (这里只管LastWait状态,即自然未发生的情况下的反省,已反馈的在feedback中已经调用反省了);
            TIModelStatus status = [item getStatusForCutIndex:curCutIndex];
            if (status == TIModelStatus_LastWait) {
                if (Log4Forecast) NSLog(@"---//IR反省触发器执行:%p F%ld 状态:%@",matchFo,matchFo.pointer.pointerId,TIStatus2Str(status));
                
                //6. 则进行理性IRT反省;
                [item checkAndUpdateReasonInRethink:curCutIndex type:ATSub except4SP2F:nil];
                
                //7. 失败状态标记;
                [item setStatus:TIModelStatus_OutBackNone forCutIndex:curCutIndex];
                
                //8. 只有pFo时,才设定失效,以及将推进失败的完全时序设为protoCanset (参考28182-todo3);
                if (matchFo.cmvNode_p) {
                    
                    //10. 中间帧推进失败时,即提前达到终点,即处理推进为完全时序 (参考27183);
                    //2024.07.29: 这里应该不是提前到达终点,应该是从cut到end的deltaTime到了后,还没负mv反馈,才算到达终点,废弃此处调用,pFo最终是否有mv反馈,由DemandManager来最终调用 (参考32118);
                    //[item pushFrameFinish:@"fltAbsRCanset中间帧"];
                    
                    //9. 失效判断: pFo任务失效 (参考27093-条件2 & 27095-2);
                    item.isExpired = true;
                }
            }
        }];
    }
    //3. ========> 末位感性反省 (参考25031-2) ->feedbackTIP;
    else if(item.cutIndex == maxCutIndex){
        
        //4. 有mv时才感性反省;
        if (!matchFo.cmvNode_p) return;
        
        //9. 设为等待反馈状态 & 构建反省触发器;
        [item setStatus:TIModelStatus_LastWait forCutIndex:curCutIndex];
        double deltaTime = matchFo.mvDeltaTime;
        
        if (Log4Forecast) NSLog(@"---//感性IRT触发器新增等待反馈:%p (%@ | useTime:%.2f)",matchFo,Fo2FStr(matchFo),deltaTime);
        [AITime setTimeTrigger:deltaTime trigger:^{
            //10. 如果状态已改成OutBack,说明有反馈 (这里只管LastWait状态,即自然未发生的情况下的反省,已反馈的在feedback中已经调用反省了);
            TIModelStatus status = [item getStatusForCutIndex:curCutIndex];
            CGFloat score = [AIScore score4MV:matchFo.cmvNode_p ratio:1.0f];
            if (status == TIModelStatus_LastWait) {
                if (score != 0) {
                    
                    //10. 正mv未反馈为S(坏) 或负mv未反馈为P(好);
                    AnalogyType type = score > 0 ? ATSub : ATPlus;
                    
                    //11. 则进行感性IRT反省;
                    [item checkAndUpdatePerceptInRethink:type except4SP2F:nil];
                    if (Log4Forecast) NSLog(@"---//IP反省触发器执行:%p F%ld 状态:%@",matchFo,matchFo.pointer.pointerId,TIStatus2Str(status));
                }
                
                //12. 失败状态标记;
                [item setStatus:TIModelStatus_OutBackNone forCutIndex:curCutIndex];
            }
            
            //14. 最末帧推进完全时,无论成败都算终点,则处理推进为完全时序 (参考27183);
            //2024.07.29: 废弃此处调用,pFo最终是否有mv反馈,由DemandManager来最终调用 (参考32118);
            //[item pushFrameFinish:@"fltAbsRCanset末帧"];
            
            //13. pFo任务失效;
            if ([ThinkingUtils isContinuousWithAT:matchFo.cmvNode_p.algsType]) {
                BOOL pFoIsP = status != TIModelStatus_OutBackSameDelta;//没反馈成负价值,说明是好事儿 (自然未发生负价值);
                if (pFoIsP) item.isExpired = true;//持续价值到期自然未发生负价值,可计为失效 (参考32041-TODO3);
            } else {
                item.isExpired = true;//单发价值到期即失效 (参考27093-条件1 & 27095-1);
            }
        }];
    }
}

@end
