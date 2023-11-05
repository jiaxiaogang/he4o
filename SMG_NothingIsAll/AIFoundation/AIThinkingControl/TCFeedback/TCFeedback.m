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
 *      2022.09.18: 反馈匹配时,及时处理反省和任务推进帧 (参考27098-todo2&todo3);
 *      2023.02.09: 反馈不匹配时(只要没调用到匹配,即调用不匹配),也要记录protoAlg到pFo里的实际发生帧 (参考28063-todo1);
 *  @status
 *      xxxx.xx.xx: 非启动状态,因为时序识别中,未涵盖HNGL类型,所以并未对HNGL进行预测;
 *      2021.10.17: 启动,支持对IRT的理性失效 (参考24059&24061-方案2);
 */
+(void) feedbackTIR:(AIShortMatchModel*)model{
    //1. 取所有lastWait模型,并与新输入的概念做mIsC判断;
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"feedbackTIR", @"\n输入ProtoA:%@ (识别matchAlgs数:%ld)",Alg2FStr(model.protoAlg),model.matchAlgs.count);
    NSArray *recognitionAlgs = [TIUtils getMatchAndPartAlgPsByModel:model];
    
    //1. fbTIR对roots进行反馈判断 (参考27096-方案2);
    NSArray *roots = [theTC.outModelManager.getAllDemand copy];
    for (ReasonDemandModel *root in roots) {
        
        //2. 仅支持ReasonDemandModel类型的反馈,因为PerceptDemandModel已经发生完毕,不需要反馈;
        if (!ISOK(root, ReasonDemandModel.class)) continue;
        
        //3. 对pFos做理性反馈;
        for (AIMatchFoModel *waitModel in root.validPFos) {
            
            //4. 取出等待中的_非wait状态的,不处理;
            NSInteger status = [waitModel getStatusForCutIndex:waitModel.cutIndex];
            if (status != TIModelStatus_LastWait) {
                //调用1: 只要没调用到pushFrame,就调用此方法记录protoA;
                [waitModel feedbackOtherFrame:model.protoAlg.pointer];
                continue;
            }
            AIFoNodeBase *matchFo = [SMGUtils searchNode:waitModel.matchFo];
            if (Log4TIROPushM) NSLog(@"==> checkTIModel=MatchFo: %@",Fo2FStr(matchFo));
            
            //5. 末位跳过,不需要反馈 (参考25031-2 & 25134-方案2);
            NSInteger maxCutIndex = matchFo.count - 1;
            if (waitModel.cutIndex >= maxCutIndex){
                //调用2: 只要没调用到pushFrame,就调用此方法记录protoA;
                [waitModel feedbackOtherFrame:model.protoAlg.pointer];
                continue;
            }
            AIKVPointer *waitAlg_p = ARR_INDEX(matchFo.content_ps, waitModel.cutIndex + 1);
            
            //6. 判断protoAlg与waitAlg之间匹配,成立则OutBackYes;
            [AITest test11:model waitAlg_p:waitAlg_p];//测下2523c-此处是否会导致匹配不到;
//            BOOL mIsC = [TOUtils mIsC_1:model.protoAlg.pointer c:waitAlg_p];
            BOOL mIsC = [recognitionAlgs containsObject:waitAlg_p];
            if (mIsC) {
                //6. 有反馈时,进行P反省: 进行理性IRT反省;
                [TCRethink reasonInRethink:waitModel cutIndex:waitModel.cutIndex type:ATPlus];
                
                //7. pFo任务顺利: 推进帧;
                [waitModel feedbackPushFrame:model.protoAlg.pointer];
                dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
                    [theTV updateFrame];
                });
                NSLog(@"tir_OPushM: waitFo场景更新,原IRT理性失效");
            } else {
                //调用3: 只要没调用到pushFrame,就调用此方法记录protoA;
                [waitModel feedbackOtherFrame:model.protoAlg.pointer];
            }
        }
    }
    
    //7. 传给TOR,做下一步处理: R任务_预测mv价值变化;
    //2021.12.01: R任务(新架构应在forecastIRT之后,调用rForecastBack.rDemand,但旧架构在前面,先不动,等测没影响再改后面);
    //2021.12.05: 将tor移到概念识别后了,此处front和back合并 (参考24171-9);
    DebugE();
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
 *      2023.04.19: 改到TCTransfer迁移后调用canset识别类比 (参考29069-todo12);
 *      2023.09.01: 打开canset失败时调用canset识别类比,并eff-1 (参考30124-todo1&todo2);
 *  @bug
 *      2021.01.25: 修复witMatchFo.cmvNode_p空判断逻辑反了,导致无法执行修改状态为OutBackYes,从而反省类比永远为"逆";
 */
+(void) feedbackTIP:(AIFoNodeBase*)protoFo cmvNode:(AICMVNode*)cmvNode {
    //1. 数据检查
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"feedbackTIP", @"\n输入MV:%@",Mv2FStr(cmvNode));
    
    //2. 判断最近一次input是否与等待中pFo感性结果相匹配 (匹配,比如吃,确定自己是否真吃了);
    //2. fbTIP对roots进行反馈判断 (参考27096-方案2);
    NSArray *roots = [theTC.outModelManager.getAllDemand copy];
    for (ReasonDemandModel *root in roots) {
        
        //2. 仅支持ReasonDemandModel类型的反馈,因为PerceptDemandModel已经发生完毕,不需要反馈;
        if (!ISOK(root, ReasonDemandModel.class)) continue;
        
        //3. 对pFos做理性反馈;
        for (AIMatchFoModel *waitModel in root.validPFos) {
            
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
                    NSLog(@"---//IP反省触发器执行:%p F%ld 状态:%@",waitMatchFo,waitMatchFo.pointer.pointerId,TIStatus2Str(TIModelStatus_OutBackSameDelta));
                    
                    //12. 有mv反馈时,做Canset识别 (参考28185-todo5);
                    //[TCEffect rInEffect:waitMatchFo matchRFos:waitModel.baseFrameModel.matchRFos es:es];
                    //EffectStatus es = score > 0 ? ES_HavEff : ES_NoEff;
                    //[TIUtils recognitionCansetFo:protoFo.pointer sceneFo:waitMatchFo.pointer es:es];
                }
                
                //13. pFo任务失效 (参考27093-条件1 & 27095-1);
                waitModel.isExpired = true;
                dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
                    [theTV updateFrame];
                });
                NSLog(@"tip_OPushM: 实MV 正向反馈");
            }
        }
    }
    DebugE();
}


//MARK:===============================================================
//MARK:                     < TO部分 >
//MARK:===============================================================

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @title 外层输入对Out短时记忆的影响处理:
 *  @实例1: 原本我要上战场,预测危险不去,结果突然看到一辆坦克,为什么我会想到驾驶坦克上战场?
 *          a. 发现坦克前: 短时记忆的父子枝结构为: 物体去战场 -> 我做为物体去战场;
 *          b. 发现坦克后: 短时记忆的父子枝结构为: 坦克去战场 -> 我开着坦克去战场 (feedback后重组反思_坦克替代物体);
 *          说明: 通过feedback,已经重刷新了记忆树的一大部分;
 *          问题: 此处如何把坦克替换到人的?因为物体在更抽象父中,而上战场在更子中 (物体和战场可能不在同一时序中);
 *  @callers : 所有的ActYes都会使用此处来收集外循环反馈;
 *      1. HNGL
 *      2. Demand
 *      3. 静默成功说明 (例:穿越森林,出门前备好枪,老虎冲出来时,开枪吓跑它):
 *          a. 备好枪后,等待老虎 (进入来的及,actYes状态);
 *          b. 当静默成功返回outBack时,会在isNormal代码处判断到mIsC成立 (如老虎冲出来了);
 *          c. 并在此方法最后提交到PM流程中 (判断这只老虎的特征是否符合被吓跑的可能);
 *          d. 流程控制自行继续推进dsFo,使之阻止R预测发生 (如在老虎咬人前,我们开枪吓跑它);
 //因为dsFo的继续推进,未必需要PM,而此处PM的推进,能否流程控制自己递归到dsFo推进?需要明天查下此代码;
 *  @desc
 *      1. 最新一帧,与上轮循环做匹配 (对单帧匹配到任务Finish的,要推动决策跳转下帧);
 *      2. 未输出行为,等待中的,也要进行下轮匹配,比如等开饭,等来开饭了; (等待的status是ActNo还是Runing?)
 *      3. 流程说明: OPushM成功时,调用PM继续推进流程;
 *      4. 流程说明: OPushM失败时,待生物钟触发器触发反省类比,再推进流程;
 *  @desc 外循环回来,把各自实际输入的概念,存入到TOAlgModel.realAlg中;
 *      1. 三种ActYes方式: (HNGL,isOut输出,demand完成);
 *      2. 其中,"isOut输出"和"demand完成"和"HNGL.H"时的ActYes直接根据mIsC判断外循环输入是否符合即可;
 *      3. 而HNGL.GL需要根据输入的稀疏码变化是否符合GL来判断 (base.base可找到期望稀疏码,参考:20204);
 *  @todo
 *      1. 此处在for循环中,所以有可能推进多条,比如我有了一只狗,可以拉雪撬,或者送给爷爷陪爷爷 (涉及多任务间的价值自由竞争),暂仅支持一条,后再支持;
 *      2020.08.23: 在inputMv时,支持当前actYes的fo进行抵消 (或设置为Finish) (T 由demandManager完成);
 *      2020.08.23: 在waitModel为ActYes且为HNGL时,仅判定其是否符合HNGL变化; T
 *      2020.08.23: 对realAlg进行收集,收集到waitTOAlgModel.feedbackAlg下; T
 *      2020.08.26: 在GL时,需要判断其"期望"与"真实"概念间是否是同一物体 (参考20204-示例);
 *  @version
 *      xxxx.xx.xx: 返回pushMiddle是否成功,如果推进成功,则不再执行TOP四模式;
 *      2020.08.05: waitModel.pm_Score的赋值改为取demand.score取负 (因为demand一般为负,而解决任务为正);
 *                  而此处,从waitModel的base中找fo较麻烦,所以省事儿,就直接取-demand.score得了;
 *      2020.08.24: 从tor_OPushM中独立出来,独立调用,处理realAlg和HNGL的变化相符判断;
 *      2020.12.21: 重新将commitFromOuterInputReason与OuterPushMiddleLoop()合并 (参考21185);
 *      2020.12.22: 在以往isNormal之外,再支持对isH,isGL的节点进行PM理性评价;
 *      2020.12.22: 将所有waitModel有效的返回都赋值OuterBack,而仅将首个focusModel进行PM理性评价;
 *      2020.12.28: waitModels仅对ActYes响应,将Runing去掉,因为Running应该到任务推进中自行进行PM匹配mModel,而非此处 (参考21208);
 *      2021.01.02: 无论GL变化type是否与waitType符合,都对新的变化进行保留到feedbackAlg (参考2120B-BUG1);
 *      2021.01.02: GL中mIsC对matchAlgs的全面支持,因为有时洽逢C不是matchAlgs首个,而致mIsC失败;
 *      2021.03.17: 将latestAlg和waitAlg之间的mIsC判断由1层改为2层 (因为在22173BUG时,发现此处输入了隔层mIsC);
 *      2021.05.09: 对OPushM反馈的GL触发ORT反省 (参考23071-方案2);
 *      2021.05.12: 整理tor_OPushM的代码易读性;
 *      2021.05.12: GL返回时,直接调用focus.base(即C).begin() (参考23075-方案);
 *      2021.05.14: 将reModel.content由matchA改成protoA后,此处GL时mIsC判断仅判断pIsM即可 (参考23076);
 *      2021.05.18: 将GL返回时,更新baseGLFo和basebaseValue的status,以使ORT中可以判断其finish状态 (参考23065-474示图);
 *      2021.05.20: 在waitModels收集中,将任何层的actNo之下都切断收集,避免距21飞错又飞回来,重复相符判断 (参考23073-假想2);
 *      2021.05.20: 当GL相符判断有结果后,targetModel(replaceAlg)也设为finish或actNo,以便_GL()中做不应期判断 (参考23079);
 *      2021.12.05: 将feedbackTOR前置到概念识别后,所以推进成功,才执行TOP四模式的逻辑作废 (参考24171-9);
 *      2021.12.23: feedback时,将root设回runing状态 (参考24212-8);
 *      2021.12.26: 废弃HN后,类型判断处理 & 兼容hActYes输出 (参考25032-6);
 *      2021.12.26: waitModels由currentDemand改为支持所有rootDemands (新螺旋架构迭代了短时记忆树,全树更新);
 *      2021.12.27: 当H反馈成功时,把hDemand设为finish;
 *      2022.01.08: HDemand时,非actYes状态也处理反馈 (参考25054);
 *      2022.03.13: 将mIsC改成proto或matchAlgs中任一条mIsC成立即可 (参考25146-转疑3-方案);
 *      2022.05.02: 用matchAlgs+partAlgs替代mIsC (参考25234-8);
 *      2022.05.22: H任务有效性反馈状态更新 (参考26095-6);
 *      2022.06.01: 有反馈时,不改root的runing状态 (参考26185-TODO1);
 *      2022.06.01: H反馈中段和末帧改的状态不同处理;
 *      2022.06.01: 有反馈时,继续调用TCScore (参考26185-TODO2);
 *      2022.06.01: HDemand.targetAlg提前反馈时,HDemand设为finish状态 (参考26185-TODO6);
 *      2022.11.27: H任务完成时,H当前正执行的S提前完成,并进行外类比 (参考27206c-H任务);
 *      2022.11.27: H解决方案再类比时,为其生成indexDic (参考27206d-方案2);
 *      2023.10.27: 用共同抽象判断cansetAlg反馈: 取出targetAlg的abs层,并与识别的matchAlgs判断交集 (参考3014c-todo1);
 *  @bug
 *      2020.09.22: 加上cutStopStatus,避免同一waitModel被多次触发,导致BUG (参考21042);
 *      2020.12.26: GL时,waitType的判断改为bFo,因为只有bFo才携带了waitTypeDS (参考21204);
 *      2020.12.26: GL时,在21204BUG修复后训练时,发现mIsC有时是cIsM,所以都判断下;
 *      2020.12.26: 在OPushM继续PM前,replaceAlg时,重新赋值JustPValues=P-C (参考21206);
 */
+(void) feedbackTOR:(AIShortMatchModel*)model{
    //1. 将新一帧数据报告给TOR,以进行短时记忆的更新,比如我输出行为"打",短时记忆由此知道输出"打"成功 (外循环入->推进->中循环出);
    [theTC updateOperCount:kFILENAME];
    Debug();
    NSMutableArray *waitModels = [[NSMutableArray alloc] init];
    NSArray *recognitionAlgs = [TIUtils getMatchAndPartAlgPsByModel:model];
    for (ReasonDemandModel *root in theTC.outModelManager.getAllDemand) {
        [waitModels addObjectsFromArray:[TOUtils getSubOutModels_AllDeep:root validStatus:nil]];
    }
    IFTitleLog(@"feedbackTOR", @"\n输入ProtoA:%@ (识别matchAlgs数:%ld)\n等待中任务数:%lu",Alg2FStr(model.protoAlg),recognitionAlgs.count,(long)waitModels.count);
    
    //2. 保留/更新实际发生到outModel (通过了有效判断的,将实际概念直接存留到waitModel);
    for (TOAlgModel *waitModel in waitModels) {
        
        //3. waitModel有效检查;
        if (!ISOK(waitModel, TOAlgModel.class) || !ISOK(waitModel.baseOrGroup, TOFoModel.class)) continue;
        //if (Log4OPushM) NSLog(@"==> checkTOModel: %@",Pit2FStr(waitModel.content_p));
        
        //4. ============= H返回的有效判断 =============
        if (ISOK(waitModel.baseOrGroup.baseOrGroup, HDemandModel.class)) {
            
            //5. HDemand即使waitModel不是actYes状态也处理反馈;
            TOFoModel *solutionModel = (TOFoModel*)waitModel.baseOrGroup;    //h解决方案;
            HDemandModel *hDemand = (HDemandModel*)solutionModel.baseOrGroup;//h需求模型
            TOAlgModel *targetAlg = (TOAlgModel*)hDemand.baseOrGroup;   //hDemand的目标alg;
            TOFoModel *targetFo = (TOFoModel*)targetAlg.baseOrGroup;    //hDemand的目标alg所在的fo;
            
            //6. 判断input是否与hAlg相匹配 (匹配,比如找锤子,看到锤子了);
            [AITest test11:model waitAlg_p:targetAlg.content_p];//测下2523c-此处是否会导致匹配不到;
            BOOL mcIsBro = [TOUtils mcIsBro:recognitionAlgs cansetA:targetAlg.content_p]; //用共同抽象判断cansetAlg反馈 (参考3014c-todo1);
            if (Log4OPushM) NSLog(@"HCansetA有效:M(A%ld) C:%@ 结果:%d",model.protoAlg.pId,Pit2FStr(targetAlg.content_p),mcIsBro);
            if (mcIsBro) {
                //6. 记录feedbackAlg (参考27204-1);
                waitModel.feedbackAlg = model.protoAlg.pointer;
                waitModel.status = TOModelStatus_OuterBack;
                BOOL isEndFrame = solutionModel.actionIndex == solutionModel.targetSPIndex;
                
                //a. H反馈中段: 标记OuterBack,solutionFo继续;
                if (!isEndFrame) {
                    solutionModel.status = TOModelStatus_Runing;
                    hDemand.status = TOModelStatus_Runing;
                }else{
                    //b. H反馈末帧:
                    solutionModel.status = TOModelStatus_Finish;
                    hDemand.status = TOModelStatus_Finish;
                    targetAlg.status = TOModelStatus_OuterBack;
                    targetAlg.feedbackAlg = model.protoAlg.pointer;
                    targetFo.status = TOModelStatus_Runing;
                }
                
                //c. 最终反馈了feedbackAlg时,重组 & 反思;
                dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
                    [theTV updateFrame];
                });
                if (isEndFrame) [TCRegroup feedbackRegroup:targetFo feedbackFrameOfMatchAlgs:model.matchAlgs];
                DebugE();
                [TCScore scoreFromIfTCNeed];
            }
        }
        
        //7. ============= "行为输出" 和 "demand.ActYes" 和 "静默成功 的有效判断 =============
        //此处有两种frameAlg,第1种是isOut为true的行为反馈,第2种是hDemand.baseAlg;
        if (ISOK(waitModel.baseOrGroup.baseOrGroup, ReasonDemandModel.class)) {
            
            //8. RDemand只处理ActYes状态的;
            if (waitModel.status != TOModelStatus_ActYes) continue;
            TOAlgModel *frameAlg = waitModel;                          //等待中的目标alg;
            TOFoModel *solutionFo = (TOFoModel*)frameAlg.baseOrGroup;    //目标alg所在的fo;
            HDemandModel *subHDemand = [SMGUtils filterSingleFromArr:frameAlg.subDemands checkValid:^BOOL(id item) {
                return ISOK(item, HDemandModel.class);
            }];
            
            //9. 判断input是否与等待中waitModel相匹配 (匹配,比如吃,确定自己是否真吃了);
            [AITest test11:model waitAlg_p:frameAlg.content_p];//测下2523c-此处是否会导致匹配不到;
            BOOL mcIsBro = [TOUtils mcIsBro:recognitionAlgs cansetA:frameAlg.content_p]; //用共同抽象判断cansetAlg反馈 (参考3014c-todo1);
            
            //TODOTOMORROW20231016: 等30148-todo1弄好,并重训练后,在这里测下30148-todo2;
            
            
            if (Log4OPushM) NSLog(@"RCansetA有效:M(A%ld) C(A%ld) 结果:%d CAtFo:%@",model.protoAlg.pointer.pointerId,frameAlg.content_p.pointerId,mcIsBro,Pit2FStr(solutionFo.content_p));
            if (mcIsBro) {
                //a. 赋值
                frameAlg.status = TOModelStatus_OuterBack;
                frameAlg.feedbackAlg = model.protoAlg.pointer;
                solutionFo.status = TOModelStatus_Runing;
                
                //b. 当waitModel为hDemand.targetAlg时,此处提前反馈了,hDemand改为finish状态 (参考26185-TODO6);
                if (subHDemand) subHDemand.status = TOModelStatus_Finish;
                
                //c. 重组
                dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
                    [theTV updateFrame];
                });
                DebugE();
                [TCRegroup feedbackRegroup:solutionFo feedbackFrameOfMatchAlgs:model.matchAlgs];
                [TCScore scoreFromIfTCNeed];
            }
        }
    }
    
    //2. ============== 对HDemand反馈判断 ==============
    //a. 收集所有工作记忆树的H任务;
    NSMutableArray *allHDemands = [[NSMutableArray alloc] init];
    for (DemandModel *root in theTC.outModelManager.getAllDemand) {
        NSArray *singleHDemands = [SMGUtils filterArr:[TOUtils getSubOutModels_AllDeep:root validStatus:nil] checkValid:^BOOL(TOModelBase *item) {
            return ISOK(item, HDemandModel.class);
        }];
        [allHDemands addObjectsFromArray:singleHDemands];
    }
    
    //b. 反馈匹配 (比如找锤子,看到锤子了);
    for (HDemandModel *hDemand in allHDemands) {
        TOAlgModel *targetAlg = (TOAlgModel*)hDemand.baseOrGroup;   //hDemand的目标alg;
        BOOL mcIsBro = [TOUtils mcIsBro:recognitionAlgs cansetA:targetAlg.content_p]; //用共同抽象判断cansetAlg反馈 (参考3014c-todo1);
        if (mcIsBro) {
            
            //c. 明确有效;
            targetAlg.feedbackAlg = model.protoAlg.pointer;
            hDemand.effectStatus = ES_HavEff;
            hDemand.status = TOModelStatus_Finish;
            
            //8. H任务完成时,H当前正执行的S提前完成,并进行外类比 (参考27206c-H任务);
            //2023.11.03: 即使失败也可以触发"预想与实际"的类比抽象;
            for (TOFoModel *solutionModel in hDemand.actionFoModels) {
                [AITest test17];
                if (solutionModel.status == TOModelStatus_ActYes || solutionModel.status == TOModelStatus_Runing || solutionModel.status == TOModelStatus_ActNo) {
                    //a. 数据准备;
                    AIFoNodeBase *solutionFo = [SMGUtils searchNode:solutionModel.content_p];
                    TOFoModel *targetFoModel = (TOFoModel*)hDemand.baseOrGroup;
                    AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoModel.content_p];
                    
                    //g. 收集真实发生feedbackAlg,并生成新protoFo时序 (参考27204-6);
                    NSArray *order = [solutionModel getOrderUseMatchAndFeedbackAlg:false];
                    if (!ARRISOK(order)) continue;
                    AIFoNodeBase *protoFo = [theNet createConFo:order];
                    
                    //h. 外类比 & 并将结果持久化 (挂到当前目标帧下标targetFoModel.actionIndex下) (参考27204-4&8);
                    //TODO待查BUG20231028: 此处断点不要去掉,如果一直执行不到,查下是否因为本方法上面已经更新了hCanset的状态为OuterBack,导致这里是永远执行不到的;
                    NSLog(@"HCanset预想与实际类比: (状态:%@ fromTargetFo:F%ld) \n\t当前Canset:%@",TOStatus2Str(solutionModel.status),targetFoModel.content_p.pointerId,Pit2FStr(solutionModel.content_p));
                    AIFoNodeBase *absCansetFo = [AIAnalogy analogyOutside:protoFo assFo:solutionFo type:ATDefault];
                    BOOL updateCansetSuccess = [targetFo updateConCanset:absCansetFo.pointer targetIndex:targetFoModel.actionIndex];
                    [AITest test101:absCansetFo proto:protoFo conCanset:solutionFo];
                    
                    if (updateCansetSuccess) {
                        //j. 计算出absCansetFo的indexDic & 并将结果持久化 (参考27207-7至11);
                        NSDictionary *newIndexDic = [solutionModel convertOldIndexDic2NewIndexDic:targetFoModel.content_p];
                        [absCansetFo updateIndexDic:targetFo indexDic:newIndexDic];
                        [AITest test18:newIndexDic newCanset:absCansetFo absFo:targetFo];
                        
                        //k. 算出spDic (参考27213-5);
                        [absCansetFo updateSPDic:[solutionModel convertOldSPDic2NewSPDic]];
                        [AITest test20:absCansetFo newSPDic:absCansetFo.spDic];
                    }
                } else {
                    NSLog(@"HCanset预想与实际类比未执行,F%ld 状态:%ld",solutionModel.content_p.pointerId,solutionModel.status);
                }
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
 *      2022.11.23: 记录feedbackMv (参考27204-2);
 */
+(void) feedbackTOP:(AICMVNode*)cmvNode{
    //1. 数据检查
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    if (delta == 0) return;
    [theTC updateOperCount:kFILENAME];
    Debug();
    IFTitleLog(@"feedbackTOP", @"\n输入MV:%@",Mv2FStr(cmvNode));
    
    //2. ============== 对所有等待中的任务尝试处理 (R-任务); ==============
    NSArray *roots = [theTC.outModelManager.getAllDemand copy];
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
                
                //7. 记录feedbackMv (参考27204-2);
                waitModel.feedbackMv = cmvNode.pointer;
                
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
                dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
                    [theTV updateFrame];
                });
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
