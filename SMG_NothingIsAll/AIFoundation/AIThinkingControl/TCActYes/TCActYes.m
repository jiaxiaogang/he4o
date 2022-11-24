//
//  TCActYes.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/26.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCActYes.h"

@implementation TCActYes

/**
 *  @desc : 预测tor_Forecast: 当ActYes时,一般等待外循环反馈,而此处构建生物钟触发器,用于超时时触发反省类比;
 *      1. 调用AITime触发器 (为了Out反省);
 *      2. 当生物钟触发器触发时,如果未输入有效"理性推进" 或 "感性抵消",则对这些期望与实际的差距进行反省类比;
 *  @callers
 *      1. demand.ActYes处
 *      2. 行为化Hav().HNGL.ActYes处
 *      3. 行为输出ActYes处
 *  @todo
 *      2020.08.31: 对isOut触发的,先不做处理,因为一般都能直接行为输出并匹配上,所以暂不处理;
 *  @version
 *      2020.10.17: 在生物钟触发器触发器,做有根判定,任务失效时,不进行反省 (参考note21-todolist-1);
 *      2020.12.18: HNGL失败时再调用Begin会死循环的问题,改为HNGL.ActYes失败时,则直接调用FC.Failure(hnglAlg);
 *      2021.01.27: R-模式的ActYes仅赋值,不在此处做触发器 (参考22081-todo4);
 *      2021.01.28: R-模式的ActYes在此处触发Out反省,与昨天思考的In反省触发不冲突 (参考22082);
 *      2021.01.28: ReasonDemand触发后,无论成功失败,都移出任务池 (参考22081-todo2&3);
 *      2021.03.11: 支持第四个触发器,R-模式时理性帧推进的触发 (参考n22p15-静默成功);
 *      2021.05.09: 对HNGL的触发,采用AINoRepeatRun防重触发 (参考23071-方案2);
 *      2021.06.09: 修复静默成功任务的deltaTime一直为0的BUG (参考23125);
 *      2021.06.10: 子任务判断不了havRoot,改为判断root是否已经finish,因为在tor_OPushM中finish的任务actYes是不生效的;
 *      2021.12.02: 将旧架构actYes的代码移过来 (参考24164);
 *      2021.12.27: arsTime触发后的反馈处理 (有反馈则继续解决方案,无反馈则父任务自愈);
 *      2022.05.19: 废弃 (参考26051);
 */
//arsTime模式,当评价需等待时,actYes;
//+(void) arsTimeActYes:(TOAlgModel*)algModel{
//    
//    //1. R模式静默成功处理 (等待其自然出现,避免弄巧成拙) (参考22153-A2);
//    [theTC updateOperCount:kFILENAME];
//    Debug();
//    ReasonDemandModel *rDemand = (ReasonDemandModel*)algModel.baseOrGroup.baseOrGroup;
//    TOFoModel *dsFoModel = (TOFoModel*)algModel.baseOrGroup;
//    
//    //2. root设为actYes
//    DemandModel *root = [TOUtils getRootDemandModelWithSubOutModel:algModel];
//    root.status = TOModelStatus_ActYes;
//    
//    //4. 找出下标;
//    __block NSInteger demandIndex = -1;
//    [AIScore score4ARSTime:dsFoModel demand:rDemand finishBlock:^(NSInteger _dsIndex, NSInteger _demandIndex) {
//        demandIndex = _demandIndex;
//    }];
//    
//    if (demandIndex != -1) {
//        //5. 从demand.matchFo的cutIndex到findIndex之间取deltaTime之和;
//        AIFoNodeBase *matchFo = [SMGUtils searchNode:rDemand.mModel.matchFo];
//        double deltaTime = [TOUtils getSumDeltaTime:matchFo startIndex:rDemand.mModel.cutIndex2 endIndex:demandIndex];
//        
//        //3. 触发器;
//        NSLog(@"---//触发器R-_静默成功任务Create:%@ 解决方案:%@ time:%f",FoP2FStr(dsFoModel.content_p),Pit2FStr(algModel.content_p),deltaTime);
//        NSInteger modelLayer = [TOUtils getBaseOutModels_AllDeep:algModel].count;
//        NSInteger demandLayer = [TOUtils getBaseDemands_AllDeep:algModel].count;
//        NSLog(@"FC-ACTYES (所在层:%ld / 任务层:%ld) %@",modelLayer,demandLayer,Pit2FStr(algModel.content_p));
//        //NSLog(@"%@",TOModel2Root2Str(actYesModel));
//        [AITime setTimeTrigger:deltaTime trigger:^{
//            
//            //3. 无root时,说明已被别的R-新matchFo抵消掉,抵消掉后是不做反省的 (参考22081-todo1);
//            NSArray *baseDemands = [TOUtils getBaseDemands_AllDeep:algModel];
//            BOOL finished = ARRISOK([SMGUtils filterArr:baseDemands checkValid:^BOOL(DemandModel *item) {
//                return item.status == TOModelStatus_Finish;
//            }]);
//            if (!finished) {
//                //3. Outback有返回,则R-方案当前帧阻止失败 (参考22153-A21);
//                AnalogyType type = (algModel.status == TOModelStatus_OuterBack) ? ATSub : ATPlus;
//                NSLog(@"---//触发器R-_理性alg任务Trigger:%@ 解决方案:%@ (%@)",FoP2FStr(dsFoModel.content_p),Pit2FStr(algModel.content_p),ATType2Str(type));
//                
//                //5. 有反馈时,algModel自然出现成功,则设为finish并继续决策;
//                DebugE();
//                if (type == ATPlus) {
//                    algModel.status = TOModelStatus_Finish;
//                    [TCScore score];
//                }else{
//                    //6. 无反馈时,则R预测的坏事自然未发生 (OutBack未返回,静默成功) (参考22153-A22);
//                    rDemand.status = TOModelStatus_Finish;
//                    [TCScore score];//并继续决策;
//                }
//            }
//        }];
//    }
//}


/**
 *  MARK:--------------------rActYes--------------------
 *  @desc R模式,fo执行完成时,actYes->feedbackTOP->调用感性ORT反省;
 *  @version
 *      2021.12.26: 触发器时间由baseDemand取改成solutionFo取,因为当前就是在执行solutionFo (参考25031-11);
 *                  > 而baseDemand"时间不急"自有其评价决定,此处只管触发器的直接时间;
 *      2021.12.26: 触发器和反省都针对solutionFo,而不是baseDemand.matchFo (参考25031-11);
 *      2021.12.26: 接入新的感性ORT反省 (参考25032-5);
 *      2022.05.28: 被frameActYes()替代 (参考26137-TODO2);
 */
//+(void) rActYes:(TOFoModel*)foModel{
//    //1. R-模式ActYes处理,仅赋值,等待R-触发器;
//    [theTC updateOperCount:kFILENAME];
//    Debug();
//    ReasonDemandModel *demand = (ReasonDemandModel*)foModel.baseOrGroup;
//    demand.status = TOModelStatus_ActYes;
//
//    //1. root设为actYes
//    DemandModel *root = [TOUtils getRootDemandModelWithSubOutModel:foModel];
//    root.status = TOModelStatus_ActYes;
//
//    //2. solutionFo已执行完成,直接取mvDeltaTime做触发器时间;
//    AIFoNodeBase *solutionFo = [SMGUtils searchNode:foModel.content_p];
//    double deltaTime = solutionFo.mvDeltaTime;
//
//    //3. 触发器;
//    NSLog(@"---//触发器R-_感性mv任务:%@ 解决方案:%@ time:%f",demand.algsType,Pit2FStr(foModel.content_p),deltaTime);
//    [AITime setTimeTrigger:deltaTime trigger:^{
//
//        //3. 无root时,说明已被别的R-新matchFo抵消掉,抵消掉后是不做反省的 (参考22081-todo1);
//        BOOL havRoot = [theTC.outModelManager.getAllDemand containsObject:root];
//        if (havRoot) {
//
//            //10. 如果状态已改成OutBack,说明有反馈;
//            AnalogyType type = ATDefault;
//            CGFloat score = [AIScore score4MV:solutionFo.cmvNode_p ratio:1.0f];
//            if (score > 0) {
//                //b. 实mv+反馈同向:P(好),未反馈:S(坏);
//                type = (foModel.status == TOModelStatus_OuterBack) ? ATPlus : ATSub;
//            }else if(score < 0){
//                //b. 实mv-反馈同向:S(坏),未反馈:P(好);
//                type = (foModel.status == TOModelStatus_OuterBack) ? ATSub : ATPlus;
//            }
//
//            //11. 则进行感性IRT反省;
//            if (type != ATDefault) {
//                [TCRethink perceptOutRethink:foModel type:type];
//                NSLog(@"---//OP反省触发器执行(R任务):%p F%ld 状态:%@",foModel,foModel.content_p.pointerId,TOStatus2Str(foModel.status));
//
//                //12. 如果无反馈,则设为失败,并继续决策;
//                DebugE();
//                if (foModel.status == TOModelStatus_ActYes) {
//                    foModel.status = TOModelStatus_ActNo;
//                    [TCScore score];
//                }
//            }
//        }
//    }];
//}

/**
 *  MARK:--------------------hActYes--------------------
 *  @desc H模式,等待hAlg输入反馈 -> 调用理性ORT反省 ->feedbackTOR;
 *  @version
 *      2021.12.26: 接入理性ORT反省 (参考25032-5);
 *      2022.05.28: 被frameActYes()替代 (参考26137-TODO3);
 */
//+(void) hActYes:(TOAlgModel*)algModel{
//    //1. 数据准备
//    [theTC updateOperCount:kFILENAME];
//    Debug();
//    TOFoModel *foModel = (TOFoModel*)algModel.baseOrGroup;
//    AIFoNodeBase *foNode = [SMGUtils searchNode:foModel.content_p];
//
//    //1. root设为actYes
//    DemandModel *root = [TOUtils getRootDemandModelWithSubOutModel:algModel];
//    root.status = TOModelStatus_ActYes;
//
//    //2. 如果TOAlgModel为HNGL时 (所需时间为"target-1到target"时间);
//    double deltaTime = [NUMTOOK(ARR_INDEX(foNode.deltaTimes, foModel.targetSPIndex)) doubleValue];
//    [AINoRepeatRun sign:STRFORMAT(@"%p",algModel)];
//
//    //3. 触发器 (触发条件:未等到实际输入);
//    NSLog(@"---//触发器A_生成: %@ from:%@ time:%f",AlgP2FStr(algModel.content_p),Fo2FStr(foNode),deltaTime);
//    [AITime setTimeTrigger:deltaTime trigger:^{
//
//        //4. 反省类比(成功/未成功)的主要原因;
//        AnalogyType type = (algModel.status == TOModelStatus_ActYes) ? ATSub : ATPlus;
//        [AINoRepeatRun run:STRFORMAT(@"%p",algModel) block:^{
//            [TCRethink reasonOutRethink:foModel type:type];
//            NSLog(@"---//OR反省触发器执行:%p A%ld 状态:%@",algModel,algModel.content_p.pointerId,TOStatus2Str(algModel.status));
//        }];
//
//        //5. 失败时_继续决策 (成功时,由feedback的IN流程继续);
//        BOOL havRoot = [theTC.outModelManager.getAllDemand containsObject:root];
//        DebugE();
//        if (algModel.status == TOModelStatus_ActYes && havRoot) {
//            NSLog(@"====ActYes is ATSub -> 递归alg");
//            //5. 2020.11.28: alg本级递归 (只有_Hav全部失败时,才会自行调用failure声明失败) (参考2114C);
//            algModel.status = TOModelStatus_ActNo;
//
//            //6. 2021.12.02: 失败时,继续决策;
//            [TCScore score];
//        }
//    }];
//}

/**
 *  MARK:--------------------P模式,fo执行完成时,actYes->feedbackTOP--------------------
 *  @version
 *      2022.05.28: 被frameActYes()替代 (参考26137-TODO4);
 */
//+(void) pActYes:(TOFoModel*)foModel{
//    //1. root设为actYes
//    [theTC updateOperCount:kFILENAME];
//    Debug();
//    DemandModel *root = [TOUtils getRootDemandModelWithSubOutModel:foModel];
//    root.status = TOModelStatus_ActYes;
//    
//    //2. P-模式ActYes处理 (TOFoModel时,数据准备);
//    AIFoNodeBase *solutionFo = [SMGUtils searchNode:foModel.content_p];
//    PerceptDemandModel *demand = (PerceptDemandModel*)foModel.baseOrGroup;
//    
//    //3. 触发器 (触发条件:任务未在demandManager中抵消);
//    NSLog(@"---//触发器pActYes_生成: %p -> %@ time:%f",demand,Fo2FStr(solutionFo),solutionFo.mvDeltaTime);
//    [AITime setTimeTrigger:solutionFo.mvDeltaTime trigger:^{
//        
//        //4. 无root时,说明已被别的R-新matchFo抵消掉,抵消掉后是不做反省的 (参考22081-todo1);
//        BOOL havRoot = [theTC.outModelManager.getAllDemand containsObject:root];
//        if (havRoot) {
//            
//            //5. 如果状态已改成OutBack,说明有反馈;
//            AnalogyType type = (foModel.status == TOModelStatus_OuterBack) ? ATPlus : ATSub;
//            
//            //6. 则进行感性ORT反省;
//            [TCRethink perceptOutRethink:foModel type:type];
//            NSLog(@"---//OP反省触发器执行(P任务):%p F%ld 状态:%@",foModel,foModel.content_p.pointerId,TOStatus2Str(foModel.status));
//            
//            //7. 如果无反馈,则继续决策;
//            DebugE();
//            if (foModel.status == TOModelStatus_ActYes) {
//                foModel.status = TOModelStatus_ActNo;
//                [TCScore score];
//            }
//        }
//    }];
//}

/**
 *  MARK:--------------------帧静默等待--------------------
 *  @desc 每帧都触发等待反馈 (参考26136-方案);
 *  @version
 *      2022.05.29: 不判断solutionFo.mv价值分因为它一般为空;
 *      2022.06.01: actYes仅标记自己及所在的demand,不标记root (参考26185-TODO1);
 */
+(void) frameActYes:(TOFoModel*)solutionModel{
    [theTC updateOperCount:kFILENAME];
    Debug();
    //0. 数据准备 (从上到下,取demand,solutionFo,frameAlg);
    DemandModel *demand = (DemandModel*)solutionModel.baseOrGroup;
    AIFoNodeBase *solutionFo = [SMGUtils searchNode:solutionModel.content_p];
    AIKVPointer *frameAlg_p = ARR_INDEX(solutionFo.content_ps, solutionModel.actionIndex);
    TOAlgModel *frameModel = [SMGUtils filterSingleFromArr:solutionModel.subModels checkValid:^BOOL(TOAlgModel *item) {
        return [item.content_p isEqual:frameAlg_p];
    }];
    
    //1. 设为actYes
    solutionModel.status = TOModelStatus_ActYes;
    demand.status = TOModelStatus_ActYes;
    if (frameModel) frameModel.status = TOModelStatus_ActYes;
    
    //2. solutionFo已执行完成,直接取mvDeltaTime做触发器时间;
    double deltaTime = 0;
    BOOL actYes4Mv = solutionModel.actionIndex >= solutionFo.count;
    if (actYes4Mv) {
        deltaTime = solutionFo.mvDeltaTime;
    }else{
        deltaTime = [NUMTOOK(ARR_INDEX(solutionFo.deltaTimes, solutionModel.actionIndex)) doubleValue];
    }
    
    //3. 触发器;
    NSLog(@"---//行为化帧%@性触发器:%@ time:%f\n解决方案:%@ (%ld/%ld)",actYes4Mv?@" 感":@"理",demand.algsType,deltaTime,Fo2FStr(solutionFo),solutionModel.actionIndex,solutionModel.targetSPIndex);
    [AITime setTimeTrigger:deltaTime trigger:^{
        
        //4. 末尾为mv感性目标;
        if (solutionModel.actionIndex >= solutionFo.count) {
            //a. 如果状态已改成OutBack,说明有反馈(坏),否则未反馈(好) (参考feedbackTOP);
            AnalogyType type = (solutionModel.status == TOModelStatus_OuterBack) ? ATSub : ATPlus;
            
            //d. 则进行感性PORT反省;
            [TCRethink perceptOutRethink:solutionModel type:type];
            NSLog(@"---//行为化帧触发感性反省:%p F%ld 状态:%@",solutionModel,solutionFo.pointer.pointerId,TOStatus2Str(solutionModel.status));
            
            //e. 如果无反馈,则设为失败,并继续决策;
            if (solutionModel.status == TOModelStatus_ActYes) {
                solutionModel.status = TOModelStatus_ActNo;
                demand.status = TOModelStatus_Runing;
                [TCScore score];
            }
            
            //f. R顺利解决时->生成realProtoFo并与solutionFo类比得出抽象canset (参考27204-3);
            if (ISOK(demand, ReasonDemandModel.class) && solutionModel.status != TOModelStatus_OuterBack) {
                
                //g. 收集真实发生feedbackAlg,并生成新protoFo时序 (参考27204-3);
                NSArray *order = [solutionModel convertFeedbackAlgAndRealDeltaTimes2Orders4CreateProtoFo];
                AIFoNodeBase *protoFo = [theNet createConFo:order];
                
                //h. 外类比,并将结果挂到conCansets下 (参考27204-4);
                AIFoNodeBase *absCansetFo = [AIAnalogy analogyOutside:protoFo assFo:solutionFo type:ATDefault];
                
                //i. absCansetFo挂到任务下做为新的canset (参考27204-5);
                ReasonDemandModel *rDemand = (ReasonDemandModel*)demand;
                for (AIMatchFoModel *pFo in rDemand.pFos) {
                    AIFoNodeBase *matchFo = [SMGUtils searchNode:pFo.matchFo];
                    NSArray *conCansets = [matchFo getConCansets:matchFo.count];
                    if ([conCansets containsObject:solutionModel.content_p]) {
                        
                        //TODOTOMORROW20221123: 分析下,此处存入absCansetFo时,用不用把indexDic也存入其中,,,因为后面在决策时要用?
                        //查一下,此处proto当时feedbackAlg是怎么记录下来的,经查在feedbackTOR中是feedbackAlg抽象指向solutionAlg (或者feedbackAlg=solutionAlg);
                        //所以protoFo和solutionFo类比,得出的结果还是solutionFo,只是有可能缺后面几帧,因为提前已完全了...尤其是H任务更是绝对会少后面帧因为target之后没了;
                        
                        //类比: 所以此处protoFo和solutionFo类比后的absCanset,其实还是solutionFo,只是在H时截取了其中targetIndex前的部分;
                        //convertFeedbackAlgAndRealDeltaTimes2Orders4CreateProtoFo
                        //  1. 此方法看要不要改成target之后就不返回;
                        //  2. 或者无feedbackAlg的不返回,毕竟这部分才是真正结束且未有反馈的部分;
                        
                        
                        
                        
                        
                        [matchFo updateConCanset:absCansetFo.pointer targetIndex:matchFo.count];
                    }
                }
            }
        }
        //5. 中间为帧理性目标;
        else{
            
            //a. 反省类比(成功/未成功)的主要原因,进行RORT反省;
            AnalogyType type = (frameModel.status == TOModelStatus_ActYes) ? ATSub : ATPlus;
            [TCRethink reasonOutRethink:solutionModel type:type];
            NSLog(@"---//行为化帧触发理性反省:%p A%ld 状态:%@",frameModel,frameAlg_p.pointerId,TOStatus2Str(frameModel.status));
            
            //5. 失败时_继续决策 (成功时,由feedback的IN流程继续);
            if (frameModel.status == TOModelStatus_ActYes) {
                //5. 2020.11.28: alg本级递归 (只有_Hav全部失败时,才会自行调用failure声明失败) (参考2114C);
                frameModel.status = TOModelStatus_ActNo;
                solutionModel.status = TOModelStatus_ActNo;
                demand.status = TOModelStatus_Runing;
                
                //6. 2021.12.02: 失败时,继续决策;
                [TCScore score];
            }
            
            //7. H顺利解决时->生成realProtoFo并与solutionFo类比得出抽象canset (参考27204-6);
            if (ISOK(demand, HDemandModel.class) && solutionModel.targetSPIndex == solutionModel.actionIndex && type == ATPlus) {
                
                //g. 收集真实发生feedbackAlg,并生成新protoFo时序 (参考27204-6);
                NSArray *order = [solutionModel convertFeedbackAlgAndRealDeltaTimes2Orders4CreateProtoFo];
                AIFoNodeBase *protoFo = [theNet createConFo:order];
                
                //h. 外类比,并将结果挂到conCansets下 (参考27204-4);
                AIFoNodeBase *absCansetFo = [AIAnalogy analogyOutside:protoFo assFo:solutionFo type:ATDefault];
                
                //i. 取出targetFo,然后将absCansetFo挂在下面,index=当前目标帧下标(targetFoModel.actionIndex) (参考27204-8);
                TOFoModel *targetFoModel = (TOFoModel*)demand.baseOrGroup;
                AIFoNodeBase *targetFo = [SMGUtils searchNode:targetFoModel.content_p];
                [targetFo updateConCanset:absCansetFo.pointer targetIndex:targetFoModel.actionIndex];
            }
        }
        DebugE();
    }];
}

@end
