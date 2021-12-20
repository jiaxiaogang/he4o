//
//  TCOut.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCOut.h"

@implementation TCOut

/**
 *  MARK:--------------------新螺旋架构out--------------------
 *  @version
 *      2021.11.26: 最终未输出时,转给TCInput.jump();
 */
+(void) out:(TOAlgModel*)algModel{
    //1. 无论是P-模式的Alg,还是R-中非S的Alg,都要走以下第1,第2,第3级流程;
    //1. 第0级: 本身即是cHav节点,不用行为化,即成功 (但不用递归,等外循环返回行为结果);
    if ([TOUtils isHNGL_toModel:algModel]) {
        
        //2. actYes转feedback;
        algModel.status = TOModelStatus_ActYes;//只需要等
        [self hActYes:algModel];
    }else if (algModel.content_p.isOut) {
        //2. 第1级: 本身即是isOut时,直接行为化返回;
        OFTitleLog(@"行为输出", @"\n%@",AlgP2FStr(algModel.content_p));
        //2. 输出前改为ActYes (避免重复决策当前demand) (isOut=true暂无需反省类比);
        algModel.status = TOModelStatus_ActYes;
        
        //2. 消耗活跃度并输出
        [theTC updateEnergy:-1.0f];
        
        //3. 输出_用旧有代码->输出后转给TCInput.rInput();
        BOOL invoked = [Output output_FromTC:algModel.content_p];
        NSLog(@"===执行%@",invoked ? @"success" : @"failure");
    }else{
        //@desc: 下标不急评价说明: R模式_Hav首先是为了避免forecastAlg,其次才是为了达成curFo解决方案 (参考22153);
        //5. 下标不急(弄巧成拙)评价_数据准备 (参考24171-12);
        //TODO: 考虑改成,取base最近的一个R任务;
        TOFoModel *solutionFo = (TOFoModel*)algModel.baseOrGroup;
        ReasonDemandModel *baseDemand = (ReasonDemandModel*)solutionFo.baseOrGroup;
        
        //6. 只有R类型,才参与下标不急评价;
        if(ISOK(baseDemand, ReasonDemandModel.class)){
            BOOL arsTime = [AIScore ARS_Time:solutionFo demand:baseDemand];
            if (!arsTime) {
                //7. 评价不通过,则直接ActYes,等待其自然出现 (参考22153-A2);
                NSLog(@"==> arsTime弄巧成拙评价,子弹再飞一会儿");
                algModel.status = TOModelStatus_ActYes;
                [self arsTimeActYes:algModel];
                return;
            }
        }
        
        //8. notOut转jump;
        [TCInput jump:algModel];
    }
}


//MARK:===============================================================
//MARK:                        ActYes部分
//MARK:===============================================================
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
 */

//arsTime模式,当评价需等待时,actYes;
+(void) arsTimeActYes:(TOAlgModel*)algModel{
    
    //3. R模式静默成功处理 (等待其自然出现,避免弄巧成拙) (参考22153-A2);
    ReasonDemandModel *rDemand = (ReasonDemandModel*)algModel.baseOrGroup.baseOrGroup;
    TOFoModel *dsFoModel = (TOFoModel*)algModel.baseOrGroup;
    
    //4. 找出下标;
    __block NSInteger demandIndex = -1;
    [AIScore score4ARSTime:dsFoModel demand:rDemand finishBlock:^(NSInteger _dsIndex, NSInteger _demandIndex) {
        demandIndex = _demandIndex;
    }];
    
    if (demandIndex != -1) {
        //5. 从demand.matchFo的cutIndex到findIndex之间取deltaTime之和;
        double deltaTime = [TOUtils getSumDeltaTime:rDemand.mModel.matchFo startIndex:rDemand.mModel.cutIndex2 endIndex:demandIndex];
        
        //3. 触发器;
        NSLog(@"---//触发器R-_静默成功任务Create:%@ 解决方案:%@ time:%f",FoP2FStr(dsFoModel.content_p),Pit2FStr(algModel.content_p),deltaTime);
        NSInteger modelLayer = [TOUtils getBaseOutModels_AllDeep:algModel].count;
        NSInteger demandLayer = [TOUtils getBaseDemands_AllDeep:algModel].count;
        NSLog(@"FC-ACTYES (所在层:%ld / 任务层:%ld) %@",modelLayer,demandLayer,Pit2FStr(algModel.content_p));
        //NSLog(@"%@",TOModel2Root2Str(actYesModel));
        [AITime setTimeTrigger:deltaTime trigger:^{
            
            //3. 无root时,说明已被别的R-新matchFo抵消掉,抵消掉后是不做反省的 (参考22081-todo1);
            NSArray *baseDemands = [TOUtils getBaseDemands_AllDeep:algModel];
            BOOL finished = ARRISOK([SMGUtils filterArr:baseDemands checkValid:^BOOL(DemandModel *item) {
                return item.status == TOModelStatus_Finish;
            }]);
            if (!finished) {
                //3. Outback有返回,则R-方案当前帧阻止失败 (参考22153-A21);
                AnalogyType type = (algModel.status == TOModelStatus_OuterBack) ? ATSub : ATPlus;
                NSLog(@"---//触发器R-_理性alg任务Trigger:%@ 解决方案:%@ (%@)",FoP2FStr(dsFoModel.content_p),Pit2FStr(algModel.content_p),ATType2Str(type));
                
                //5. 成功时,则整个R-任务阻止成功 (OutBack未返回,静默成功) (参考22153-A22);
                if (type == ATPlus) {
                    algModel.status = TOModelStatus_Finish;
                    
                    //TODOTOMORROW20211202任务完成,递归到baseDemand完成;=====START
                    //1. 由短时记忆树来决定它递归的base是什么,也决定它下一步应该继续下一子任务,还是父任务全完成了;
                    //[self singleLoopBackWithFinishModel:rDemand];
                    ////R-模式在完成后,直接移出任务池 (已躲撞成功);
                    //BOOL isSubDemand = finishModel.baseOrGroup;
                    //if (isSubDemand) {
                    //    [self singleLoopBackWithBegin:finishModel.baseOrGroup];
                    //}else if (ISOK(finishModel, ReasonDemandModel.class)) {
                    //    [theTC.outModelManager removeDemand:(ReasonDemandModel*)finishModel];
                    //}
                    //====================================================END
                }
            }
        }];
    }
}

//R模式,fo执行完成时,actYes;
+(void) rActYes:(TOFoModel*)foModel{
    //1. R-模式ActYes处理,仅赋值,等待R-触发器;
    ReasonDemandModel *demand = (ReasonDemandModel*)foModel.baseOrGroup;
    demand.status = TOModelStatus_ActYes;
    
    //2. 取matchFo已发生,到末位mvDeltaTime,所有时间之和做触发;
    AIFoNodeBase *matchFo = demand.mModel.matchFo;
    double deltaTime = [TOUtils getSumDeltaTime2Mv:matchFo cutIndex:demand.mModel.cutIndex2];
    
    //3. 触发器;
    NSLog(@"---//触发器R-_感性mv任务:%@ 解决方案:%@ time:%f",Fo2FStr(matchFo),Pit2FStr(foModel.content_p),deltaTime);
    [AITime setTimeTrigger:deltaTime trigger:^{
        
        //3. 无root时,说明已被别的R-新matchFo抵消掉,抵消掉后是不做反省的 (参考22081-todo1);
        BOOL havRoot = [theTC.outModelManager.getAllDemand containsObject:demand];
        if (havRoot) {
            //3. 反省类比 (当OutBack发生,则破壁失败S,否则成功P) (参考top_OPushM());
            AnalogyType type = (foModel.status == TOModelStatus_OuterBack) ? ATSub : ATPlus;
            NSLog(@"---//触发器R-_感性mv任务:%@ 解决方案:%@ (%@)",Fo2FStr(matchFo),Pit2FStr(foModel.content_p),ATType2Str(type));
            
            //4. 暂不开通反省类比,等做兼容PM后,再打开反省类比;
            [AIAnalogy analogy_OutRethink:(TOFoModel*)foModel cutIndex:NSIntegerMax type:type];
            
            //4. 失败时,转流程控制-失败 (会开始下一解决方案) (参考22061-8);
            //2021.01.28: 失败后不用再尝试下一方案了,因为R任务已过期 (已经被撞了,你再躲也没用) (参考22081-todo3);
            if (type == ATSub) {
                foModel.status = TOModelStatus_ScoreNo;
                
                //TODOTOMORROW20211202: 失败时,递归到base,并尝试下一解决方案;
                //[self singleLoopBackWithFailureModel:demand];
            }else{
                //5. SFo破壁成功,完成任务 (参考22061-9);
                foModel.status = TOModelStatus_Finish;
                
                //TODOTOMORROW20211202: 成功时,递归到base,继续下一任务,或全部完成;
                //[self singleLoopBackWithFinishModel:demand];
            }
        }
    }];
}

//H模式,等待hAlg输入反馈;
+(void) hActYes:(TOAlgModel*)algModel{
    //1. 数据准备
    TOFoModel *foModel = (TOFoModel*)algModel.baseOrGroup;
    AIFoNodeBase *foNode = [SMGUtils searchNode:foModel.content_p];
    
    //2. 如果TOAlgModel为HNGL时,
    NSInteger cutIndex = foNode.content_ps.count - 1;
    double deltaTime = [NUMTOOK(ARR_INDEX(foNode.deltaTimes, cutIndex)) doubleValue];
    [AINoRepeatRun sign:STRFORMAT(@"%p",algModel)];
    
    //3. 触发器 (触发条件:未等到实际输入);
    NSLog(@"---//触发器A_生成: %@ from:%@ time:%f",AlgP2FStr(algModel.content_p),Fo2FStr(foNode),deltaTime);
    [AITime setTimeTrigger:deltaTime trigger:^{
        
        //4. 反省类比(成功/未成功)的主要原因;
        AnalogyType type = (algModel.status == TOModelStatus_ActYes) ? ATSub : ATPlus;
        [AINoRepeatRun run:STRFORMAT(@"%p",algModel) block:^{
            NSLog(@"---//触发器A_触发: %@ from %@ (%@)",AlgP2FStr(algModel.content_p),Fo2FStr(foNode),ATType2Str(type));
            [AIAnalogy analogy_OutRethink:foModel cutIndex:cutIndex type:type];
        }];
        
        //5. 失败时,转流程控制-失败 (会开始下一解决方案);
        DemandModel *root = [TOUtils getDemandModelWithSubOutModel:algModel];
        BOOL havRoot = [theTC.outModelManager.getAllDemand containsObject:root];
        if (algModel.status == TOModelStatus_ActYes && havRoot) {
            NSLog(@"====ActYes is ATSub -> 递归alg");
            //5. 2020.11.28: alg本级递归 (只有_Hav全部失败时,才会自行调用failure声明失败) (参考2114C);
            algModel.status = TOModelStatus_ActNo;
            
            //TODOTOMORROW20211202: 失败时,此处递归到base,尝试下一H方案;
            //[self singleLoopBackWithFailureModel:algModel];
        }
    }];
}

//P模式,fo执行完成时,actYes
+(void) pActYes:(TOFoModel*)foModel{
    //1. P-模式ActYes处理 (TOFoModel时,数据准备);
    AIFoNodeBase *actYesFo = [SMGUtils searchNode:foModel.content_p];
    DemandModel *demand = (DemandModel*)foModel.baseOrGroup;
    
    //2. 触发器 (触发条件:任务未在demandManager中抵消);
    NSLog(@"---//触发器F_生成: %p -> %@ time:%f",demand,Fo2FStr(actYesFo),actYesFo.mvDeltaTime);
    [AITime setTimeTrigger:actYesFo.mvDeltaTime trigger:^{
        
        //3. 反省类比(成功/未成功)的主要原因;
        AnalogyType type = (demand.status != TOModelStatus_Finish) ? ATSub : ATPlus;
        NSLog(@"---//触发器F_触发: %p -> %@ (%@)",demand,Fo2FStr(actYesFo),ATType2Str(type));
        [AIAnalogy analogy_OutRethink:foModel cutIndex:NSIntegerMax type:type];
        
        //4. 失败时,转流程控制-失败 (会开始下一解决方案);
        BOOL havRoot = [theTC.outModelManager.getAllDemand containsObject:demand];
        if (demand.status != TOModelStatus_Finish && havRoot) {
            NSLog(@"====ActYes is Fo update status");
            foModel.status = TOModelStatus_ScoreNo;
            
            //TODOTOMORROW20211202: 失败时,递归base尝试下一解决方案;
            //[self singleLoopBackWithFailureModel:actYesModel];
        }
    }];
}

@end
