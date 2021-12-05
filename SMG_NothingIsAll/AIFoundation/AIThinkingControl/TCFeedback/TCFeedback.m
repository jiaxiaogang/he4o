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
 *  @version
 *      2021.01.24: 多时序识别支持,使之更全面的支持每个matchFo的status更新 (参考22073-todo6);
 *      2021.10.17: 支持IRT的理性失效,场景更新时,状态设为OutBackReason (参考24059&24061-方案2);
 *  @status
 *      xxxx.xx.xx: 非启动状态,因为时序识别中,未涵盖HNGL类型,所以并未对HNGL进行预测;
 *      2021.10.17: 启动,支持对IRT的理性失效 (参考24059&24061-方案2);
 */
+(void) feedbackTIR:(AIShortMatchModel*)model{
    //1. 从短时记忆树上,取所有actYes模型,并与新输入的概念做mIsC判断;
    //7. 传给TIR,做下一步处理;
    NSArray *inModels = theTC.inModelManager.models;
    OFTitleLog(@"tir_OPushM", @"\n输入M:%@\n输入P:%@",Alg2FStr(model.matchAlg),Alg2FStr(model.protoAlg));
    
    //2. IRT理性失效 (旧有IRT触发器等待中的fo,在场景情况更新时,标记OutBackReason);
    for (AIShortMatchModel *inModel in inModels) {
        for (AIMatchFoModel *waitModel in inModel.matchPFos) {
            
            //a. 取出等待中的_非wait状态的,不处理;
            if (waitModel.status != TIModelStatus_LastWait) continue;
            if (Log4TIROPushM) NSLog(@"==> checkTIModel=MatchFo: %@",Fo2FStr(waitModel.matchFo));
            
            //b. 直接判断protoFo与waitFo之间mIsC,成立则OutBackYes;
            BOOL mIsC = [TOUtils mIsC_1:model.protoFo.pointer c:waitModel.matchFo.pointer];
            if (mIsC) {
                waitModel.status = TIModelStatus_OutBackReason;
                NSLog(@"tir_OPushM: waitFo场景更新,原IRT理性失效");
            }
        }
    }
    
    //2. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了) (原HNGL部分,关闭状态);
    for (AIShortMatchModel *inModel in inModels) {
        for (AIMatchFoModel *waitModel in inModel.matchRFos) {
            ////3. 取出等待中的_非wait状态的,不处理;
            //if (waitModel.status != TIModelStatus_LastWait) continue;
            //AIFoNodeBase *waitMatchFo = waitModel.matchFo;
            //if (Log4TIROPushM) NSLog(@"==> checkTIModel=MatchFo: %@",Fo2FStr(waitMatchFo));
            //AIKVPointer *waitLastAlg_p = ARR_INDEX_REVERSE(waitMatchFo.content_ps, 0);
            //if (!waitLastAlg_p) continue;
            
            //4. 对H和GL分别做处理;
            //if([TOUtils isH:waitMatchFo.pointer]){
            ////2. 直接判断H是否mIsC,是则OutBackYes;
            //BOOL mIsC = [TOUtils mIsC_1:newInModel.protoAlg.pointer c:waitLastAlg_p];
            //if (mIsC) {
            //    waitModel.status = TIModelStatus_OutBackReason;
            //    NSLog(@"tir_OPushM: H有效");
            //}
            //}
        }
    }
    
    //6. 传给TOR,做下一步处理: R任务_预测mv价值变化;
    [TCForecast rForecastFront:model];
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @title 外层输入对Out短时记忆的影响处理:
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
 *      2020.08.23: 对realAlg进行收集,收集到waitTOAlgModel.realContent_p下; T
 *      2020.08.26: 在GL时,需要判断其"期望"与"真实"概念间是否是同一物体 (参考20204-示例);
 *  @result 返回pushMiddle是否成功,如果推进成功,则不再执行TOP四模式;
 *  @version
 *      2020.08.05: waitModel.pm_Score的赋值改为取demand.score取负 (因为demand一般为负,而解决任务为正);
 *                  而此处,从waitModel的base中找fo较麻烦,所以省事儿,就直接取-demand.score得了;
 *      2020.08.24: 从tor_OPushM中独立出来,独立调用,处理realAlg和HNGL的变化相符判断;
 *      2020.12.21: 重新将commitFromOuterInputReason与OuterPushMiddleLoop()合并 (参考21185);
 *      2020.12.22: 在以往isNormal之外,再支持对isH,isGL的节点进行PM理性评价;
 *      2020.12.22: 将所有waitModel有效的返回都赋值OuterBack,而仅将首个focusModel进行PM理性评价;
 *      2020.12.28: waitModels仅对ActYes响应,将Runing去掉,因为Running应该到任务推进中自行进行PM匹配mModel,而非此处 (参考21208);
 *      2021.01.02: 无论GL变化type是否与waitType符合,都对新的变化进行保留到realContent (参考2120B-BUG1);
 *      2021.01.02: GL中mIsC对matchAlgs的全面支持,因为有时洽逢C不是matchAlgs首个,而致mIsC失败;
 *      2021.03.17: 将latestAlg和waitAlg之间的mIsC判断由1层改为2层 (因为在22173BUG时,发现此处输入了隔层mIsC);
 *      2021.05.09: 对OPushM反馈的GL触发ORT反省 (参考23071-方案2);
 *      2021.05.12: 整理tor_OPushM的代码易读性;
 *      2021.05.12: GL返回时,直接调用focus.base(即C).begin() (参考23075-方案);
 *      2021.05.14: 将reModel.content由matchA改成protoA后,此处GL时mIsC判断仅判断pIsM即可 (参考23076);
 *      2021.05.18: 将GL返回时,更新baseGLFo和basebaseValue的status,以使ORT中可以判断其finish状态 (参考23065-474示图);
 *      2021.05.20: 在waitModels收集中,将任何层的actNo之下都切断收集,避免距21飞错又飞回来,重复相符判断 (参考23073-假想2);
 *      2021.05.20: 当GL相符判断有结果后,targetModel(replaceAlg)也设为finish或actNo,以便_GL()中做不应期判断 (参考23079);
 *  @bug
 *      2020.09.22: 加上cutStopStatus,避免同一waitModel被多次触发,导致BUG (参考21042);
 *      2020.12.26: GL时,waitType的判断改为bFo,因为只有bFo才携带了waitTypeDS (参考21204);
 *      2020.12.26: GL时,在21204BUG修复后训练时,发现mIsC有时是cIsM,所以都判断下;
 *      2020.12.26: 在OPushM继续PM前,replaceAlg时,重新赋值JustPValues=P-C (参考21206);
 */
+(void) feedbackTOR:(AIShortMatchModel*)model{
    BOOL pushOldDemand = false;
    //4. 将新一帧数据报告给TOR,以进行短时记忆的更新,比如我输出行为"打",短时记忆由此知道输出"打"成功 (外循环入->推进->中循环出);
    //2. 取出所有等待下轮的outModel (ActYes&Runing);
    NSArray *waitModels = [TOUtils getSubOutModels_AllDeep:theTC.outModelManager.getCurrentDemand validStatus:@[@(TOModelStatus_ActYes)] cutStopStatus:@[@(TOModelStatus_Finish),@(TOModelStatus_ActNo),@(TOModelStatus_ScoreNo)]];
    OFTitleLog(@"tor_OPushM", @"\n输入M:%@\n输入P:%@\n等待中任务数:%lu",Alg2FStr(model.matchAlg),Alg2FStr(model.protoAlg),(long)waitModels.count);
    
    //3. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    //3. 保留/更新实际发生到outModel (通过了有效判断的,将实际概念直接存留到waitModel);
    TOAlgModel *focusModel = nil;
    for (TOAlgModel *waitModel in waitModels) {
        
        //3. waitModel有效检查;
        if (Log4OPushM) NSLog(@"==> checkTOModel: %@",Pit2FStr(waitModel.content_p));
        BOOL waitIsAlgAndBaseIsFo = ISOK(waitModel, TOAlgModel.class) && ISOK(waitModel.baseOrGroup, TOFoModel.class);
        if (!waitIsAlgAndBaseIsFo) continue;
        
        //3. 不同类型不同处理;
        NSLog(@"========3");
        BOOL isH = [TOUtils isH_toModel:waitModel];
        BOOL isNormal = ![TOUtils isHNGL_toModel:waitModel];
        
        //4. ============= H返回的有效判断 =============
        if (isH) {
            NSLog(@"========4");
            TOAlgModel *targetModel = (TOAlgModel*)waitModel.baseOrGroup.baseOrGroup;
            BOOL mIsC = [TOUtils mIsC_1:model.matchAlg.pointer c:targetModel.content_p];
            if (Log4OPushM) NSLog(@"H有效判断_mIsC:(M=headerM C=%@) 结果:%d",Pit2FStr(targetModel.content_p),mIsC);
            if (mIsC) {
                waitModel.status = TOModelStatus_OuterBack;
                waitModel.realContent_p = model.protoAlg.pointer;
                
                //1. 在ATHav时,执行到此处,说明waitModel和baseFo已完成;
                waitModel.baseOrGroup.status = TOModelStatus_Finish;
                
                //2. 应跳到: baseFo.baseAlg与此处inputMModel.protoAlg之间,进行PM评价;
                if (!focusModel) NSLog(@"=== OPushM成功 Hav继续PM: %@",Pit2FStr(targetModel.content_p));
                if (!focusModel) focusModel = targetModel;
            }
        }
        
        //7. ============= "行为输出" 和 "demand.ActYes" 和 "静默成功 的有效判断 =============
        if (isNormal) {
            BOOL mIsC = [TOUtils mIsC_2:model.matchAlg.pointer c:waitModel.content_p];
            if (Log4OPushM) NSLog(@"Normal有效判断_mIsC:(M=headerM C=%@) 结果:%d",Pit2FStr(waitModel.content_p),mIsC);
            if (mIsC) {
                waitModel.status = TOModelStatus_OuterBack;
                waitModel.realContent_p = model.protoAlg.pointer;
                if (!focusModel) NSLog(@"=== OPushM成功 Normal继续PM: %@",Pit2FStr(waitModel.content_p));
                if (!focusModel) focusModel = waitModel;
            }
        }
    }
    
    //8. 将首个focusModel进行PM修正 (理性评价);
    if (focusModel) {
        
        //9. 不同类型不同处理 (当alg在base.replacAlges中时,说明是GL过来的);
        TOModelBase *baseAlg = focusModel.baseOrGroup;
        BOOL isGL = ISOK(baseAlg, TOAlgModel.class) && [((TOAlgModel*)baseAlg).replaceAlgs containsObject:focusModel.content_p];
        
        //11. =========== 非GL时 ===========
        if (!isGL) {
            
            
            //5. 将理性评价"价值分"保留到短时记忆模型;
            focusModel.pm_Fo = focusModel.baseOrGroup.content_p;
            
            //6. 理性评价
            //----------TODOTOMORROW20211205:
            //  a. 此处不再调用PM,而是转向重组和识别反思,并生成子任务;
            //  b. 流程: 先输入,概念识别,反馈,时序重组,时序识别;
            //代码实践1: 将model.protoAlg重组到focusModel所在的时序;
            //代码实践2: 将此处feedback移到概念识别之后就调用;
            
        }
        pushOldDemand = true;
    }else{
        NSLog(@"OPushM: 无一被需要");
    }
    
    //7. R任务 (新架构应在forecastIRT之后,调用rForecastBack.rDemand,但旧架构代码放在前面,先不动,等发现没影响时再改为后面);
    [TCForecast rForecastBack:model pushOldDemand:pushOldDemand];
    
    //8. IRT触发器;
    [TCForecast forecastIRT:model pushOldDemand:pushOldDemand];
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 认知--------------------
 *  @title 外层输入对In短时记忆的影响处理 (参考22052-2);
 *  @version
 *      2021.01.24: 对多时序识别结果支持,及时全面的改变status为OutBackYes (参考22073-todo5);
 *      2021.02.04: In反省支持虚mv,所以此处也要支持虚mv的OPush判断 (参考22108);
 *  @bug
 *      2021.01.25: 修复witMatchFo.cmvNode_p空判断逻辑反了,导致无法执行修改状态为OutBackYes,从而反省类比永远为"逆";
 */
+(void) feedbackTIP:(AICMVNode*)cmvNode{
    //1. 数据检查
    NSArray *inModels = theTC.inModelManager.models;
    OFTitleLog(@"tip_OPushM", @"\n输入MV:%@",Mv2FStr(cmvNode));
    
    //3. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    for (AIShortMatchModel *inModel in inModels) {
        for (AIMatchFoModel *waitModel in inModel.matchPFos) {
            //3. 非等待中的跳过;
            AIFoNodeBase *waitMatchFo = waitModel.matchFo;
            if (Log4OPushM) NSLog(@"==> checkTIModel=MatchFo: %@ (%@)",Fo2FStr(waitMatchFo),TIStatus2Str(waitModel.status));
            if (waitModel.status != TIModelStatus_LastWait || !waitMatchFo.cmvNode_p) continue;
            
            //4. 等待中的inModel_判断hope(wait)和real(new)之间是否相符;
            if ([AINetUtils isVirtualMv:waitMatchFo.cmvNode_p]) {
                //a. 虚mv仅标记同区反向反馈;
                if ([AIScore sameIdenDiffDelta:waitMatchFo.cmvNode_p mv2:cmvNode.pointer]) {
                    waitModel.status = TIModelStatus_OutBackDiffDelta;
                    NSLog(@"tip_OPushM: 虚MV 反向反馈");
                }
            }else{
                //b. 实mv仅标记同区同向反馈;
                if ([AIScore sameIdenSameScore:waitMatchFo.cmvNode_p mv2:cmvNode.pointer]) {
                    waitModel.status = TIModelStatus_OutBackSameDelta;
                    NSLog(@"tip_OPushM: 实MV 正向反馈");
                }
            }
        }
    }
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @title 外层输入对Out短时记忆的ReasonDemandModel影响处理 (参考22061-8);
 *  @version
 *      2021.02.04: 将R同区同向(会导致永远为false因为虚mv得分为0)判断,改为同区反向判断 (参考22115BUG & 22108虚mv反馈判断方法);
 */
+(void) feedbackTOP:(AICMVNode*)cmvNode{
    //0. 数据检查
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    if (delta == 0) {
        return;
    }
    
    //1. 数据检查
    NSArray *demands = theTC.outModelManager.getAllDemand;
    OFTitleLog(@"top_OPushM", @"\n输入MV:%@",Mv2FStr(cmvNode));
    
    //2. 对所有ReasonDemandModel尝试处理 (是R-任务);
    for (ReasonDemandModel *demand in demands) {
        if (!ISOK(demand, ReasonDemandModel.class)) continue;
        
        //3. 判断hope(wait)和real(new)之间是否相符 (当反馈了"同区反向"时,即表明任务失败,为S) (匹配,比如撞疼,确定疼了);
        if ([AIScore sameIdenDiffDelta:demand.mModel.matchFo.cmvNode_p mv2:cmvNode.pointer]) continue;
        
        //4. 将等待中的foModel改为OutBack;
        for (TOFoModel *foModel in demand.actionFoModels) {
            if (foModel.status != TOModelStatus_ActYes) continue;
            if (Log4OPushM) NSLog(@"==> top_OPushM_mv有效改为OutBack,SFo: %@",Pit2FStr(foModel.content_p));
            foModel.status = TOModelStatus_OuterBack;
        }
    }
    
    //3. p任务;
    [TCForecast pForecast:cmvNode];
}

+(void) feedbackSubDemand:(AIShortMatchModel*)model{
    //5. 生成子任务;
    [TCForecast forecastSubDemand:model];
}

@end
