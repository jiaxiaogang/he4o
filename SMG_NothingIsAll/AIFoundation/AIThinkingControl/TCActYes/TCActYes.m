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
//                    [TCPlan planFromIfTCNeed];
//                }else{
//                    //6. 无反馈时,则R预测的坏事自然未发生 (OutBack未返回,静默成功) (参考22153-A22);
//                    rDemand.status = TOModelStatus_Finish;
//                    [TCPlan planFromIfTCNeed];//并继续决策;
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
//                    [TCPlan planFromIfTCNeed];
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
//    double deltaTime = [NUMTOOK(ARR_INDEX(foNode.deltaTimes, foModel.targetIndex)) doubleValue];
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
//            [TCPlan planFromIfTCNeed];
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
//                [TCPlan planFromIfTCNeed];
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
 *      2023.01.01: 修复solutionFo的mvDeltaTime总是0的问题 (参考28013);
 *      2023.03.04: 修复反省未保留以往帧actionIndex,导致反省时错误的BUG (参考28144-todo);
 *      2024.04.11: 支持Canset池帧反馈失败时的传染机制 (参考31176);
 */
+(void) frameActYes:(TOFoModel*)solutionModel{
    [theTC updateOperCount:kFILENAME];
    Debug();
    //0. 数据准备 (从上到下,取demand,solutionFo,frameAlg);
    DemandModel *demand = (DemandModel*)solutionModel.baseOrGroup;
    AIFoNodeBase *solutionFo = [SMGUtils searchNode:solutionModel.transferSiModel.canset];
    TOAlgModel *frameModel = [solutionModel getCurFrame];
    
    //1. 设为actYes
    solutionModel.status = TOModelStatus_ActYes;
    demand.status = TOModelStatus_ActYes;
    if (frameModel) frameModel.status = TOModelStatus_ActYes;
    
    //2. solutionFo已执行完成,直接取mvDeltaTime做触发器时间;
    double deltaTime = 0;
    BOOL actYes4Mv = solutionModel.cansetActIndex >= solutionFo.count;
    if (actYes4Mv) {
        AIKVPointer *basePFoOrTargetFo_p = [TOUtils convertBaseFoFromBasePFoOrTargetFoModel:solutionModel.basePFoOrTargetFoModel];
        AIFoNodeBase *basePFoOrTargetFo = [SMGUtils searchNode:basePFoOrTargetFo_p];
        deltaTime = basePFoOrTargetFo.mvDeltaTime;
    }else{
        deltaTime = [NUMTOOK(ARR_INDEX(solutionFo.deltaTimes, solutionModel.cansetActIndex)) doubleValue];
    }
    
    //3. 触发器;
    NSLog(@"---//构建行为化帧触发器:%p for:%@ time:%.2f",actYes4Mv?solutionModel:frameModel,ClassName2Str(demand.algsType),deltaTime);
    NSInteger frameActIndex = solutionModel.cansetActIndex;//保留actIndex值,因为等触发时,它可能就变了,这里保留下来才准确;
    [AITime setTimeTrigger:deltaTime trigger:^{
        //4. 只有besting的才触发反省等,别的早已被打断了 (参考31073-TODO2e);
        //2024.08.08: 此处即使无解,或者别的原因转向bested状态,也可以统计S和执行传染 (因为下一帧应自然发生,不必找任何借口) (参考32142-TODO3);
        //if (solutionModel.cansetStatus != CS_Besting) return;
        
        //2024.12.05: 每次反馈同F只计一次: 避免F值快速重复累计到很大,sp更新(同场景下的)防重推 (参考33137-方案v5);
        NSMutableArray *except4SP2F = [[NSMutableArray alloc] init];
        
        //4. 末尾为mv感性目标;
        NSArray *actionFoModels = [demand.actionFoModels copy];
        if (actYes4Mv) {
            //a. 末帧时间已等完;
            solutionModel.actYesed = true;
            
            //a. 如果状态已改成OutBack,说明有反馈(坏),否则未反馈(好) (参考feedbackTOP);
            int rootsRewakeNum = 0;
            
            //e. 如果有反馈,则设为失败,并停止决策;
            if (solutionModel.status == TOModelStatus_OuterBack) {
                solutionModel.status = TOModelStatus_ActNo;
                demand.status = TOModelStatus_ActNo;
                [TCPlan planFromIfTCNeed];
            } else {
                //f. 如果无反馈,则设为对baseRDemand有效,整个工作记忆同质解都唤醒一下 (参考31179-TODO2);
                if (ISOK(solutionModel.baseOrGroup, ReasonDemandModel.class)) {
                    rootsRewakeNum = [TOUtils rewakeToAllRootsTree_Mv:solutionModel except4SP2F:except4SP2F];
                }
            }
            
            //g. log
            if (rootsRewakeNum > 0) NSLog(@"末帧唤醒: demand:%@ 传至工作记忆唤醒总数:%d",demand.algsType,rootsRewakeNum);
        }
        //5. 中间为帧理性目标;
        else{
            //a. 中间帧时间已等完;
            frameModel.actYesed = true;
            
            //a. 反省类比(成功/未成功)的主要原因,进行RORT反省;
            int newInfectedNum = 0, rootsInfectedNum = 0;
            
            //5. 失败时_继续决策 (成功时,由feedback的IN流程继续);
            if (frameModel.status == TOModelStatus_ActYes) {
                //5. 2020.11.28: alg本级递归 (只有_Hav全部失败时,才会自行调用failure声明失败) (参考2114C);
                frameModel.status = TOModelStatus_ActNo;
                solutionModel.status = TOModelStatus_ActNo;
                demand.status = TOModelStatus_Runing;
                NSLog(@"在ReasonOutRethink反省后 solution:F%ld 因超时无效而set actYes to actNo-------->",solutionModel.content_p.pointerId);
            }
            
            //2024.08.05: 改为只要非OuterBack状态,这里都能传染 (feedbackTOR反馈成功时则为OuterBack状态) (参考32142-TODO1);
            if (frameModel.status != TOModelStatus_OuterBack) {
                //6. 这里看frameAlgModel反馈失败,把demand.actionFoModels传染一下 (参考31176-方案 & 31176-TODO2B);
                //说明: 所有下一帧(actIndex帧) => 能否传染判断方法有两种,如下:
                for (TOFoModel *item in actionFoModels) {
                    if (item.isInfected) continue;
                    TOAlgModel *itemFrameAlg = [item getCurFrame];
                    if (!itemFrameAlg) continue;
                    
                    //方法1. 本来就是一个alg (参考31176-TODO2B-方法1);
                    if ([itemFrameAlg.content_p isEqual:frameModel.content_p]) {
                        rootsInfectedNum += [TOUtils infectToAllRootsTree_Alg:item infectedAlg:itemFrameAlg.content_p except4SP2F:except4SP2F];
                        newInfectedNum++;
                        continue;
                    }
                    
                    //方法2. 有indexDic映射 (参考31176-TODO2B-方法2);
                    //数据检查: 二者不在一颗I场景树下,则无法判断映射,也无法传染 (参考31176-TODO2B-方法2-注);
                    if (![solutionModel.sceneTo isEqual:item.sceneTo]) continue;
                    NSDictionary *actingDic = solutionModel.transferXvModel.sceneToCansetToIndexDic;
                    NSDictionary *itemDic = item.transferXvModel.sceneToCansetToIndexDic;
                    //a. 根据对应的sceneTo的映射,取到对应item的映射;
                    NSNumber *sceneToIndex = ARR_INDEX([actingDic allKeysForObject:@(frameActIndex)], 0);
                    NSNumber *itemIndex = [itemDic objectForKey:sceneToIndex];
                    //b. 当有映射,且洽好在等待反馈,则传染;
                    if (itemIndex && item.cansetActIndex == itemIndex.integerValue) {
                        rootsInfectedNum += [TOUtils infectToAllRootsTree_Alg:item infectedAlg:itemFrameAlg.content_p except4SP2F:except4SP2F];
                        newInfectedNum++;
                    }
                }
                
                //6. 2021.12.02: 失败时,继续决策;
                [TCPlan planFromIfTCNeed];
            }
            
            //7. log
            NSInteger totalInfectedNum = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOFoModel *item) {
                return item.isInfected;
            }].count;
            if (newInfectedNum > 0) NSLog(@"%@中间帧传染 %@ from demand:%p + 新增传染数:%d = 总传染数:%ld (还剩:%ld) (另:传至工作记忆:%d)",solutionModel.isH?@"H":@"R",Pit2FStr(frameModel.content_p),demand,newInfectedNum,totalInfectedNum,actionFoModels.count - totalInfectedNum,rootsInfectedNum);
        }
    }];
    DebugE();
}

@end
