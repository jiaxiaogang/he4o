//
//  AIThinkOutPercept.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutPercept.h"
#import "ThinkingUtils.h"
#import "AIPort.h"
#import "AINet.h"
#import "AIKVPointer.h"
#import "AICMVNode.h"
#import "AIAbsCMVNode.h"
#import "AIFrontOrderNode.h"
#import "AINetAbsFoNode.h"
#import "TOFoModel.h"
#import "AIAbsAlgNode.h"
#import "AIAlgNode.h"
#import "AIShortMatchModel.h"
#import "TOUtils.h"
#import "AINetUtils.h"
#import "TOAlgModel.h"
#import "TOValueModel.h"
#import "AIScore.h"
#import "ReasonDemandModel.h"
#import "PerceptDemandModel.h"
#import "DemandManager.h"
#import "AIMatchFoModel.h"

@implementation AIThinkOutPercept

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================


//MARK:===============================================================
//MARK:              < 四种工作模式 (参考19152) >
//MARK: @desc 事实上,主要就P+和R-会触发思维工作;
//MARK:===============================================================

/**
 *  MARK:-------------------- P- --------------------
 *  @desc
 *      1. 简介: mv方向索引找正价值解决方案;
 *      2. 实例: 饿了,现有面粉,做面吃可以解决;
 *      3. 步骤: 用A.refPorts ∩ F.conPorts (参考P+模式模型图);
 *  @todo :
 *      1. 集成原有的能量判断与消耗 T;
 *      2. 评价机制1: 比如土豆我超不爱吃,在mvScheme中评价,入不应期,并继续下轮循环;
 *      3. 评价机制2: 比如炒土豆好麻烦,在行为化中反思评价,入不应期,并继续下轮循环;
 *  @version
 *      2020.09.23: 只要得到解决方案,就返回true中断,因为即使行为化失败,也会交由流程控制继续决策,而非由此处处理;
 */
-(BOOL) perceptSub:(DemandModel*)demandModel{
    //1. 数据准备;
    if (!Switch4PS || !demandModel) return false;
    if (![theTC energyValid]) return false;
    MVDirection direction = [ThinkingUtils getDemandDirection:demandModel.algsType delta:demandModel.delta];
    OFTitleLog(@"TOP.P-", @"\n任务:%@,发生%ld,方向%ld",demandModel.algsType,(long)demandModel.delta,(long)direction);
    
    //2. 调用通用diff模式方法;
    __block BOOL success = false;//默认为失败
    [TOUtils topPerceptModeV2:demandModel direction:direction tryResult:^BOOL(AIFoNodeBase *sameFo) {
        
        //a. 构建TOFoModel
        TOFoModel *toFoModel = [TOFoModel newWithFo_p:sameFo.pointer base:demandModel];
        
        //b. 取自身,实现吃,则可不饿;
        NSLog(@"------->>>>>> P-新增一例解决方案: %@->%@",Fo2FStr(sameFo),Mvp2Str(sameFo.cmvNode_p));
        [self.delegate aiTOP_2TOR_PerceptSub:toFoModel];
        
        //c. 用success记录下,是否本次成功找到候选方案;
        success = true;
        
        //d. 一次只尝试一条,行为化中途失败时,自然会由流程控制方法递归TOP.P+重来;
        return true;
    } canAss:^BOOL{
        return [theTC energyValid];
    } updateEnergy:^(CGFloat delta) {
        [theTC updateEnergy:delta];
    }];
    
    //3. 返回P+模式结果;
    return success;
}
/**
 *  MARK:-------------------- P- --------------------
 *  @desc mv方向索引找负价值的兄弟节点解决方案 (比如:打球打累了,不打了,避免更累);
 *  @废弃: 因为P-是不存在的(或者说目前不需要的),可以以P+&R-替代之;
 */
-(BOOL) perceptPlus:(AIAlgNodeBase*)matchAlg demandModel:(DemandModel*)demandModel{
    //1. 数据准备;
    //if (!matchAlg || !demandModel) return false;
    //MVDirection direction = [ThinkingUtils getDemandDirection:demandModel.algsType delta:demandModel.delta];
    //direction = labs(direction - 1);//取反方向;
    
    //2. 调用通用diff模式方法;
    __block BOOL success = false;//默认为失败
    //[TOUtils topPerceptModeV2:demandModel direction:direction tryResult:^BOOL(AIFoNodeBase *sameFo) {
    //
    //    //a. 取兄弟节点,停止打球,则不再累;
    //    [TOUtils getPlusBrotherBySubProtoFo_NoRepeatNotNull:sameFo tryResult:^BOOL(AIFoNodeBase *checkFo, AIFoNodeBase *subNode, AIFoNodeBase *plusNode) {
    //
    //        //b. 指定subNode和plusNode到行为化;
    //        success = [self.delegate aiTOP_2TOR_PerceptPlus:sameFo plusFo:plusNode subFo:subNode checkFo:checkFo];
    //
    //        //c. 一条成功,则中止取兄弟节点循环;
    //        return success;
    //    }];
    //
    //    //d. 一条成功,则中止取消通用diff算法的交集循环;
    //    return success;
    //} canAss:^BOOL{
    //    return [theTC energyValid];
    //} updateEnergy:^(CGFloat delta) {
    //    [theTC updateEnergy:delta];
    //}];
    
    //3. 返回P-模式结果;
    return success;
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 决策--------------------
 *  @title 外层输入对Out短时记忆的ReasonDemandModel影响处理 (参考22061-8);
 *  @version
 *      2021.02.04: 将R同区同向(会导致永远为false因为虚mv得分为0)判断,改为同区反向判断 (参考22115BUG & 22108虚mv反馈判断方法);
 */
+(void) top_OPushM:(AICMVNodeBase*)newMv{
    //1. 数据检查
    NSArray *demands = theTC.outModelManager.getAllDemand;
    if (!newMv) return;
    OFTitleLog(@"top_OPushM", @"\n输入MV:%@",Mv2FStr(newMv));
    
    //2. 对所有ReasonDemandModel尝试处理 (是R-任务);
    for (ReasonDemandModel *demand in demands) {
        if (!ISOK(demand, ReasonDemandModel.class)) continue;
        
        //3. 判断hope(wait)和real(new)之间是否相符 (当反馈了"同区反向"时,即表明任务失败,为S) (匹配,比如撞疼,确定疼了);
        if ([AIScore sameIdenDiffDelta:demand.mModel.matchFo.cmvNode_p mv2:newMv.pointer]) continue;
        
        //4. 将等待中的foModel改为OutBack;
        for (TOFoModel *foModel in demand.actionFoModels) {
            
            //TODOTOMORROW20210902: 召回任务池里的R任务,因为P反馈已至 (参考23224-方案);
            //考虑不止actYes任务,而是所有从pFos生成的R任务全部判断,并进行销毁 / 或改成outerBack状态;
            
            //未在actYes状态的,直接设为finish或failure;
            //  a. 判断rDemand是否与当前P输入,是否符合: 预测的发生;
            //      > 三辆车撞过来,各一个R,共有三个R -> 一辆撞到,另外两辆还得躲;
            //      > 一只毒火虫飞来,有烧疼,撞疼,毒疼三种R -> 一只虫撞到,另外两个任务也不用躲了;
            //      > 综上: 要从理性上分析是否来不及,即从PFos来分析,或从RDemand的来源:inModel来分析;
            //      > 所以: 在R帧输入时,即同步更新RDemand任务,即F346飞出木棒时,应该同步推进rDemand.curIndex + 1;
            //  a. 然后调用ort反省,
            //  b. 再调用流程控制的failure或finish;
            
            /*
             //3. 反省类比 (当OutBack发生,则破壁失败S,否则成功P) (参考top_OPushM());
             AnalogyType type = (actYesModel.status == TOModelStatus_OuterBack) ? ATSub : ATPlus;
             NSLog(@"---//触发器R-_感性mv任务:%@ 解决方案:%@ (%@)",Fo2FStr(matchFo),Pit2FStr(actYesModel.content_p),ATType2Str(type));
             
             //4. 暂不开通反省类比,等做兼容PM后,再打开反省类比;
             [AIAnalogy analogy_OutRethink:(TOFoModel*)actYesModel cutIndex:NSIntegerMax type:type];
             
             //4. 失败时,转流程控制-失败 (会开始下一解决方案) (参考22061-8);
             //2021.01.28: 失败后不用再尝试下一方案了,因为R任务已过期 (已经被撞了,你再躲也没用) (参考22081-todo3);
             if (type == ATSub) {
             actYesModel.status = TOModelStatus_ScoreNo;
             [self singleLoopBackWithFailureModel:demand];
             }else{
             //5. SFo破壁成功,完成任务 (参考22061-9);
             actYesModel.status = TOModelStatus_Finish;
             [self singleLoopBackWithFinishModel:demand];
             }
             */
            
            
            if (foModel.status != TOModelStatus_ActYes) continue;
            if (Log4OPushM) NSLog(@"==> top_OPushM_mv有效改为OutBack,SFo: %@",Pit2FStr(foModel.content_p));
            foModel.status = TOModelStatus_OuterBack;
        }
    }
}

@end
