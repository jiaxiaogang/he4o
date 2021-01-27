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

-(void) dataOut {
    [self topV2];
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------topV2--------------------
 *  @desc
 *      1. 四种(2x2)TOP模式 (优先取同区工作模式,不行再以不同区工作模式);
 *      2. 调用者只管调用触发,模型生成,参数保留;
 *  @version
 *      20200430 : v2,四种工作模式版;
 *      20200824 : 将外循环输入推进中循环,改到上一步aiThinkIn_Commit2TC()中;
 *  @todo
 *      1. 集成活跃度的判断和消耗;
 *      2. 集成outModel;
 *      3. TODOTOMORROW: 下面传给四模式的代码,用bool方式直接返回finish的判断不妥,改之;
 *      2021.01.22: 对ActYes或者OutBack的Demand进行不应期处理 (未完成);
 */
-(void) topV2{
    //1. 数据准备
    DemandModel *demand = [self.delegate aiThinkOutPercept_GetCanDecisionDemand];
    NSArray *mModels = [self.delegate aiTOP_GetShortMatchModel];
    if (!demand || !ARRISOK(mModels)) return;
    
    //2. 同区两个模式之R-;
    if (ISOK(demand, ReasonDemandModel.class)) {
        [self reasonSub:(ReasonDemandModel*)demand];
        return;
    }
    
    //3. 同区两个模式之R+ (以最近的预测为准);
    for (NSInteger i = 0; i < mModels.count; i++) {
        AIShortMatchModel *mModel = ARR_INDEX_REVERSE(mModels, i);
        AIFoNodeBase *matchFo = mModel.matchFo;
        
        //a.预测有效性判断和同区判断 (以预测的正负为准);
        if (matchFo && matchFo.cmvNode_p && [demand.algsType isEqualToString:matchFo.cmvNode_p.algsType]) {
            CGFloat score = [AIScore score4MV:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
            //b. R+
            if (score > 0) {
                BOOL success = [self reasonPlus:mModel demandModel:demand];
                NSLog(@"topV2_R+ : %@",success ? @"成功":@"失败");
                if (success) return;
            }
        }
    }
    
    //3. 不同区两个模式 (以最近的识别优先);
    for (NSInteger i = 0; i < mModels.count; i++) {
        AIShortMatchModel *mModel = ARR_INDEX_REVERSE(mModels, i);
        AIAlgNodeBase *matchAlg = mModel.matchAlg;
        
        //a. 识别有效性判断 (优先直接mv+,不行再mv-迂回);
        if (matchAlg) {
            //b. P-
            BOOL pSuccess = [self perceptSub:demand];
            NSLog(@"topV2_P+ => %@ => %@",Alg2FStr(matchAlg),pSuccess ? @"成功":@"失败");
            if (pSuccess) return;
            
            //c. P+
            BOOL sSuccess = [self perceptPlus:matchAlg demandModel:demand];
            NSLog(@"topV2_P- => %@ => %@",Alg2FStr(matchAlg),sSuccess ? @"成功":@"失败");
            if (sSuccess) return;
        }
    }
}

/**
 *  MARK:--------------------TOR中Demand方案失败,尝试转移--------------------
 *  @desc 当demand一轮失败时,进行P+递归;
 *  @version
 *      2021.01.21: 支持R-模式;
 */
-(void) commitFromTOR_MoveForDemand:(DemandModel*)demand{
    //1. 识别有效性判断 (转至P-/R-);
    if (ISOK(demand, PerceptDemandModel.class)) {
        [self perceptSub:demand];
    }else if (ISOK(demand, ReasonDemandModel.class)) {
        [self reasonSub:(ReasonDemandModel*)demand];
    }
}

//MARK:===============================================================
//MARK:              < 四种工作模式 (参考19152) >
//MARK: @desc 事实上,主要就P+和R-会触发思维工作;
//MARK:===============================================================

/**
 *  MARK:-------------------- R+ --------------------
 *  @desc
 *      主线: 对需要输出的的元素,进行配合输出即可 (比如吓一下鸟,它自己就飞走了);
 *      支线: 对不符合预测的元素修正 (比如剩下一只没飞走,我再更大声吓一下) (注:这涉及到外层循环,反向类比的修正);
 *  @version
 *      2020.06.30: 由下帧,改为当前帧 (因为需先进行理性评价PM);
 *  @status 2021.01.21: 废弃,因为R+不构成需求;
 */
-(BOOL) reasonPlus:(AIShortMatchModel*)mModel demandModel:(DemandModel*)demandModel{
    ////1. 数据检查
    //if (!mModel || mModel.matchFo || demandModel) {
        return false;
    //}
    //
    ////2. 生成outFo模型
    //TOFoModel *toFoModel = [TOFoModel newWithFo_p:mModel.matchFo.pointer base:demandModel];
    //
    ////3. 对下帧进行行为化 (先对当前帧,进行理性评价PM,再跳转下帧);
    //toFoModel.actionIndex = mModel.cutIndex;
    //[self.delegate aiTOP_2TOR_ReasonPlus:toFoModel mModel:mModel];
    //return toFoModel.status != TOModelStatus_ActNo && toFoModel.status != TOModelStatus_ScoreNo;//成功行为化,则中止递归;
}
/**
 *  MARK:-------------------- R- --------------------
 *  @desc
 *      主线: 取matchFo的兄弟节点,进行行为化 (比如车将撞到我,我避开可避免);
 *      CutIndex: 本算法中,未使用cutIndex而是使用了subNode和plusNode来解决问题 (参考19152:R-)
 *  @TODO 1. 对抽象也尝试取brotherFo,比如车撞与落石撞,其实都是需要躲开"撞过来的物体";
 *  @version
 *      2020.05.12 - 支持cutIndex的判断,必须是未发生的部分才可以被修正 (如车将撞上,躲开是对的,但将已过去的出门改成不出门,是错的);
 *      2021.01.23 - R-模式支持决策前空S评价 (参考22061-1);
 */
-(void) reasonSub:(ReasonDemandModel*)demand{
    //1. 数据检查
    if (!demand) return;
    AIFoNodeBase *matchFo = demand.mModel.matchFo;
    
    //2. ActYes等待 或 OutBack反省等待 中时,不进行决策;
    NSArray *waitFos = [SMGUtils filterArr:demand.actionFoModels checkValid:^BOOL(TOFoModel *item) {
        return item.status == TOModelStatus_ActYes || item.status == TOModelStatus_OuterBack;
    }];
    if (ARRISOK(waitFos)) return;
    
    //3. 取出所有S (取Sub避免MatchFo继续下去的办法);
    NSArray *sFo_ps = Ports2Pits([AINetUtils absPorts_All:matchFo type:ATSub]);
    
    //4. 去掉不应期
    NSArray *except_ps = [TOUtils convertPointersFromTOModels:demand.actionFoModels];
    NSArray *validFos = [SMGUtils removeSub_ps:except_ps parent_ps:sFo_ps];
    NSLog(@"\n\n=============================== TOP.R- ===============================\n任务:%@ 已发生:%ld 不应期数:%lu 可尝试方案:%lu",Fo2FStr(matchFo),(long)demand.mModel.cutIndex,(unsigned long)except_ps.count,(unsigned long)validFos.count);
    
    //5. 找新方案 (破壁者);
    for (AIKVPointer *item_p in validFos) {
        //6. 未发生理性评价 (空S评价);
        if (![AIScore FRS:[SMGUtils searchNode:item_p]]) continue;
        
        //7. 评价通过则取出 (提交决策流程控制,行为化);
        TOFoModel *foModel = [TOFoModel newWithFo_p:item_p base:demand];
        NSLog(@"------->>>>>> R-新增一例解决方案: %@",Pit2FStr(item_p));
        [self.delegate aiTOP_2TOR_ReasonSub:foModel demand:demand];
        break;
    }
    NSLog(@"------->>>>>> R-无计可施");
}
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
    if (!demandModel) return false;
    if (![theTC energyValid]) return false;
    MVDirection direction = [ThinkingUtils havDemand:demandModel.algsType delta:demandModel.delta];
    NSLog(@"\n\n=============================== TOP.P- ===============================\n任务:%@,发生%ld,方向%ld",demandModel.algsType,(long)demandModel.delta,(long)direction);
    
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
    //MVDirection direction = [ThinkingUtils havDemand:demandModel.algsType delta:demandModel.delta];
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
 */
+(void) top_OPushM:(AICMVNodeBase*)newMv{
    //1. 数据检查
    NSArray *demands = theTC.outModelManager.getAllDemand;
    if (!newMv) return;
    NSLog(@"\n\n=============================== top_OPushM ===============================\n输入MV:%@",Mv2FStr(newMv));
    
    //2. 对所有ReasonDemandModel尝试处理 (是R-任务);
    for (ReasonDemandModel *demand in demands) {
        if (!ISOK(demand, ReasonDemandModel.class)) continue;
        
        //3. 判断hope(wait)和real(new)之间是否相符 (与newMv同区且同向) (匹配,比如撞疼,确定疼了);
        BOOL isSame = [AIScore sameScoreOfMV1:demand.mModel.matchFo.cmvNode_p mv2:newMv.pointer];
        if (!isSame) continue;
        
        //4. 将等待中的foModel改为OutBack;
        for (TOFoModel *foModel in demand.actionFoModels) {
            if (foModel.status != TOModelStatus_ActYes) continue;
            if (Log4OPushM) NSLog(@"==> top_OPushM_mv有效改为OutBack,SFo: %@",Pit2FStr(foModel.content_p));
            foModel.status = TOModelStatus_OuterBack;
        }
    }
}

@end
