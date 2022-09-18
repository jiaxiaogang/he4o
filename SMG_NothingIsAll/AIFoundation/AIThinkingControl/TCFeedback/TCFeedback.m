//
//  TCFeedback.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCFeedback.h"

@implementation TCFeedback

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @title 外层输入对In短时记忆的影响处理 (参考22052-2);
 *  @param model : 新帧的model;
 *  @version
 *      2021.01.24: 多时序识别支持,使之更全面的支持每个matchFo的status更新 (参考22073-todo6);
 *      2021.10.17: 支持IRT的理性失效,场景更新时,状态设为OutBackReason (参考24059&24061-方案2);
 *      2021.12.25: 针对理性IRT反省的支持 (判断非末位为理性预测中) (参考25021-②);
 *      2022.03.05: BUG_将仅末位才反馈,改成非末位才反馈 (原来逻辑写反了);
 *      2022.05.02: 用matchAlgs+partAlgs替代mIsC (参考25234-8);
 *      2022.09.05: 将theTC.inModels改成roots.pFos (参考27096-方案2);
 *      2022.09.06: TC流程调整_直接调用TCDemand,将感理性反省预置都后置到Demand中 (参考27096-实践1);
 *      2022.09.18: 有反馈时,及时处理反省和任务推进帧 (参考27098-todo2&todo3);
 *  @status
 *      xxxx.xx.xx: 非启动状态,因为时序识别中,未涵盖HNGL类型,所以并未对HNGL进行预测;
 *      2021.10.17: 启动,支持对IRT的理性失效 (参考24059&24061-方案2);
 */
+(void) feedbackTIR:(AIShortMatchModel*)model{
    //1. 取所有lastWait模型,并与新输入的概念做mIsC判断;
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"feedbackTIR", @"\n输入M:%@\n输入P:%@",Alg2FStr(model.matchAlg),Alg2FStr(model.protoAlg));
    NSArray *recognitionAlgs = [TIUtils getMatchAndPartAlgPsByModel:model];
    
    //1. fbTIR对roots进行反馈判断 (参考27096-方案2);
    NSArray *roots = theTC.outModelManager.getAllDemand;
    for (ReasonDemandModel *root in roots) {
        
        //2. 仅支持ReasonDemandModel类型的反馈,因为PerceptDemandModel已经发生完毕,不需要反馈;
        if (ISOK(root, ReasonDemandModel.class)) continue;
        
        //3. 对pFos做理性反馈;
        for (AIMatchFoModel *waitModel in root.pFos) {
            
            //4. 取出等待中的_非wait状态的,不处理;
            NSInteger status = [waitModel getStatusForCutIndex:waitModel.cutIndex];
            if (status != TIModelStatus_LastWait) continue;
            AIFoNodeBase *matchFo = [SMGUtils searchNode:waitModel.matchFo];
            if (Log4TIROPushM) NSLog(@"==> checkTIModel=MatchFo: %@",Fo2FStr(matchFo));
            
            //5. 末位跳过,不需要反馈 (参考25031-2 & 25134-方案2);
            NSInteger maxCutIndex = matchFo.count - 1;
            if (waitModel.cutIndex >= maxCutIndex) continue;
            AIKVPointer *waitAlg_p = ARR_INDEX(matchFo.content_ps, waitModel.cutIndex + 1);
            
            //6. 判断protoAlg与waitAlg之间匹配,成立则OutBackYes;
            [AITest test11:model waitAlg_p:waitAlg_p];//测下2523c-此处是否会导致匹配不到;
//            BOOL mIsC = [TOUtils mIsC_1:model.protoAlg.pointer c:waitAlg_p];
            BOOL mIsC = [recognitionAlgs containsObject:waitAlg_p];
            if (mIsC) {
                //6. 有反馈时,进行P反省: 进行理性IRT反省;
                [TCRethink reasonInRethink:waitModel type:ATPlus];
                
                //7. pFo任务顺利: 推进帧;
                [waitModel feedbackPushFrame:model.protoAlg.pointer];
                [theTV updateFrame];
                NSLog(@"tir_OPushM: waitFo场景更新,原IRT理性失效");
            }
        }
    }
    
    //7. 传给TOR,做下一步处理: R任务_预测mv价值变化;
    //2021.12.01: R任务(新架构应在forecastIRT之后,调用rForecastBack.rDemand,但旧架构在前面,先不动,等测没影响再改后面);
    //2021.12.05: 将tor移到概念识别后了,此处front和back合并 (参考24171-9);
    DebugE();
    [TCDemand rDemand:model];
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 认知--------------------
 *  @title 外层输入对In短时记忆的影响处理 (参考22052-2);
 *  @param cmvNode : 新输入的mv;
 *  @version
 *      2021.01.24: 对多时序识别结果支持,及时全面的改变status为OutBackYes (参考22073-todo5);
 *      2021.02.04: In反省支持虚mv,所以此处也要支持虚mv的OPush判断 (参考22108);
 *      2021.12.25: 废弃虚mv的代码 (因为虚mv早已不在时序识别的结果中,并且整个dsFo都已废弃掉了) (参考Note24);
 *      2021.12.25: 针对感性IRT反省的支持 (判断末位为感性预测中) (参考25022-②);
 *      2022.09.05: 将theTC.inModels改成roots.pFos (参考27096-方案2);
 *      2022.09.18: 有反馈时,及时处理反省和任务失效 (参考27098-todo2);
 *  @bug
 *      2021.01.25: 修复witMatchFo.cmvNode_p空判断逻辑反了,导致无法执行修改状态为OutBackYes,从而反省类比永远为"逆";
 */
+(void) feedbackTIP:(AICMVNode*)cmvNode{
    //1. 数据检查
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"feedbackTIP", @"\n输入MV:%@",Mv2FStr(cmvNode));
    
    //2. 判断最近一次input是否与等待中pFo感性结果相匹配 (匹配,比如吃,确定自己是否真吃了);
    //2. fbTIP对roots进行反馈判断 (参考27096-方案2);
    NSArray *roots = theTC.outModelManager.getAllDemand;
    for (ReasonDemandModel *root in roots) {
        
        //2. 仅支持ReasonDemandModel类型的反馈,因为PerceptDemandModel已经发生完毕,不需要反馈;
        if (ISOK(root, ReasonDemandModel.class)) continue;
        
        //3. 对pFos做理性反馈;
        for (AIMatchFoModel *waitModel in root.pFos) {
            
            //3. 数据准备;
            AIFoNodeBase *waitMatchFo = [SMGUtils searchNode:waitModel.matchFo];
            NSInteger maxCutIndex = waitMatchFo.count - 1;
            
            //4. 非等待中的跳过;
            NSInteger status = [waitModel getStatusForCutIndex:waitModel.cutIndex];
            if (Log4OPushM) NSLog(@"==> checkTIModel=MatchFo: %@ (%@)",Fo2FStr(waitMatchFo),TIStatus2Str(status));
            if (status != TIModelStatus_LastWait) continue;
            
            //5. 非末位跳过 (参考25031-2);
            if (waitModel.cutIndex < maxCutIndex) continue;
            
            //6. 等待中的inModel_判断hope(wait)和real(new)之间是否相符 (仅标记同区同向反馈);
            if ([AIScore sameIdenSameScore:waitMatchFo.cmvNode_p mv2:cmvNode.pointer]) {
                [waitModel setStatus:TIModelStatus_OutBackSameDelta forCutIndex:waitModel.cutIndex];
                AIFoNodeBase *waitMatchFo = [SMGUtils searchNode:waitModel.matchFo];
                
                //10. 有反馈;
                CGFloat score = [AIScore score4MV:waitMatchFo.cmvNode_p ratio:1.0f];
                
                //b. 正mv反馈为P(好) 或 负mv反馈为S(坏);
                if (score != 0) {
                    AnalogyType type = score > 0 ? ATPlus : ATSub;
                    
                    //11. 则进行感性IRT反省;
                    [TCRethink perceptInRethink:waitModel type:type];
                    NSLog(@"---//IP反省触发器执行:%p F%ld 状态:%@",waitMatchFo,waitMatchFo.pointer.pointerId,TIStatus2Str(status));
                }
                
                //13. pFo任务失效 (参考27093-条件1 & 27095-1);
                waitModel.isExpired = true;
                [theTV updateFrame];
                NSLog(@"tip_OPushM: 实MV 正向反馈");
            }
        }
    }
    DebugE();
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @title 外层输入对Out短时记忆的ReasonDemandModel影响处理 (参考22061-8);
 *  @version
 *      2021.02.04: 将R同区同向(会导致永远为false因为虚mv得分为0)判断,改为同区反向判断 (参考22115BUG & 22108虚mv反馈判断方法);
 *      2021.12.23: feedback时,将root设回runing状态 (参考24212-8);
 *      2021.12.24: 应对整个工作记忆树进行支持,而不是仅rootDemands (参考25032-6);
 *      2021.12.26: 针对rSolution的感性反馈 (参考25031-11 & 25032-6);
 *      2022.05.22: R任务有效性反馈状态更新 (参考26095-3);
 *      2022.05.29: 反馈与demand.mv对比匹配,而不是solutionFo (参考26141-BUG1);
 *      2022.06.03: 将roots浅复制,避免强训过程中因loopCache变化而闪退;
 *      2022.09.06: TC流程调整_直接调用TCDemand (参考27096-实践1);
 */
+(void) feedbackTOP:(AICMVNode*)cmvNode{
    //1. 数据检查
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    if (delta == 0) return;
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"feedbackTOP", @"\n输入MV:%@",Mv2FStr(cmvNode));
    
    //2. ============== 对所有等待中的任务尝试处理 (R-任务); ==============
    NSMutableArray *roots = [[NSMutableArray alloc] initWithArray:theTC.outModelManager.getAllDemand];
    for (ReasonDemandModel *root in roots) {
        NSArray *waitModels = [TOUtils getSubOutModels_AllDeep:root validStatus:@[@(TOModelStatus_ActYes)]];
        for (TOFoModel *waitModel in waitModels) {
            
            //3. wait不为fo解决方案时不处理;
            if (!ISOK(waitModel, TOFoModel.class)) continue;
            
            //4. 非R也非P任务时,不处理;
            if (!ISOK(waitModel.baseOrGroup, ReasonDemandModel.class) && !ISOK(waitModel.baseOrGroup, PerceptDemandModel.class)) continue;
            
            //5. 非actYes状态不处理;
            if (waitModel.status != TOModelStatus_ActYes) continue;
            
            //6. 未到末尾,不处理;
            AIFoNodeBase *waitFo = [SMGUtils searchNode:waitModel.content_p];
            if (waitModel.actionIndex < waitFo.count) continue;
            
            //7. waitFo是为了解决任务,所以要取出原任务的mv标识来比较;
            //7. 判断hope(wait)和real(new)之间是否相符 (当反馈了"同区反向"时,即表明任务失败,为S);
            DemandModel *demand = (DemandModel*)waitModel.baseOrGroup;
            BOOL sameIden = [cmvNode.pointer.algsType isEqualToString:demand.algsType];
            if (sameIden) {
                
                //7. 同向匹配 (比如撞疼,确定疼了);
                CGFloat score = [AIScore score4MV:cmvNode.pointer ratio:1.0f];
                if (score < 0) {
                    waitModel.status = TOModelStatus_OuterBack;
                    NSLog(@"top_OPushM: 方案失败反馈OutBack");
                    
                    //7. root设回runing
                    demand.status = TOModelStatus_Runing;
                    root.status = TOModelStatus_Runing;
                }else{
                    //8. solutionFo反馈好时,baseDemand为完成状态;
                    waitModel.baseOrGroup.status = TOModelStatus_Finish;
                }
                [theTV updateFrame];
            }
        }
    }
    
    //2. ============== 对Demand反馈判断 ==============
    //a. 收集所有工作记忆树的R任务;
    NSMutableArray *allRDemands = [[NSMutableArray alloc] init];
    for (ReasonDemandModel *root in theTC.outModelManager.getAllDemand) {
        NSArray *singleRDemands = [SMGUtils filterArr:[TOUtils getSubOutModels_AllDeep:root validStatus:nil] checkValid:^BOOL(TOModelBase *item) {
            return ISOK(item, ReasonDemandModel.class);
        }];
        [allRDemands addObjectsFromArray:singleRDemands];
    }
    
    //b. 反馈匹配 => 同区判断 且 都为负价值 (比如撞疼,确定疼了);
    for (ReasonDemandModel *rDemand in allRDemands) {
        if ([rDemand.algsType isEqualToString:cmvNode.pointer.algsType]) {
            CGFloat newMvScore = [AIScore score4MV:cmvNode.pointer ratio:1.0f];
            if (newMvScore < 0) {
                //c. 明确无效;
                rDemand.effectStatus = ES_NoEff;
                rDemand.status = TOModelStatus_ActNo;
            }
        }
    }
    
    //3. p任务;
    DebugE();
    [TCDemand pDemand:cmvNode];
}

@end
