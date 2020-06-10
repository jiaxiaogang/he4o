//
//  AIThinkOutPercept.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOutPercept.h"
#import "DemandModel.h"
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
 *  @todo
 *      1. 集成活跃度的判断和消耗;
 *      2. 集成outModel;
 *      3. TODOTOMORROW: 下面传给四模式的代码,用bool方式直接返回finish的判断不妥,改之;
 */
-(void) topV2{
    //1. 数据准备
    DemandModel *demand = [self.delegate aiThinkOutPercept_GetCurrentDemand];
    NSArray *mModels = [self.delegate aiTOP_GetShortMatchModel];
    if (!demand || !ARRISOK(mModels)) return;
    
    //2. 外循环入->推进->中循环出;
    AIShortMatchModel *latestMModel = ARR_INDEX_REVERSE(mModels, 0);
    if (latestMModel) {
        BOOL pushOldDemand = [self.delegate aiTOP_OuterPushMiddleLoop:demand latestMatchAlg:latestMModel.matchAlg];
        
        //此处推进成功后,下面的四模式不必运行,
        if (pushOldDemand) {
            return;
        }
    }
    
    //2. 同区两个模式 (以最近的预测为准);
    for (NSInteger i = 0; i < mModels.count; i++) {
        AIShortMatchModel *mModel = ARR_INDEX_REVERSE(mModels, i);
        AIFoNodeBase *matchFo = mModel.matchFo;
        
        //a.预测有效性判断和同区判断 (以预测的正负为准);
        if (matchFo && matchFo.cmvNode_p && [demand.algsType isEqualToString:matchFo.cmvNode_p.algsType]) {
            CGFloat score = [ThinkingUtils getScoreForce:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
            //b. R+
            if (score > 0) {
                BOOL success = [self reasonPlus:matchFo cutIndex:mModel.cutIndex demandModel:demand];
                if (success) return;
            }else if(score < 0){
                //c. R-
                BOOL success = [self reasonSub:matchFo cutIndex:mModel.cutIndex demandModel:demand];
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
            //b. P+
            BOOL pSuccess = [self perceptPlus:matchAlg demandModel:demand];
            if (pSuccess) return;
            
            //c. P-
            BOOL sSuccess = [self perceptSub:matchAlg demandModel:demand];
            if (sSuccess) return;
        }
    }
}

-(void) commitFromTOR_MoveForDemand:(DemandModel*)demand{
    //1. 数据准备
    NSArray *mModels = [self.delegate aiTOP_GetShortMatchModel];
    if (!demand || !ARRISOK(mModels)) return;
    
    //2. 逐个对mModels短时记忆进行尝试使用;
    for (NSInteger i = 0; i < mModels.count; i++) {
        AIShortMatchModel *mModel = ARR_INDEX_REVERSE(mModels, i);
        AIAlgNodeBase *matchAlg = mModel.matchAlg;
        
        //3. 识别有效性判断 (转至P+);
        if (matchAlg) {
            BOOL success = [self perceptPlus:matchAlg demandModel:demand];
            NSLog(@"=========================TOP.Demand转移");
            if (success) return;
        }
    }
}

//MARK:===============================================================
//MARK:              < 四种工作模式 (参考19152) >
//MARK:===============================================================

/**
 *  MARK:-------------------- R+ --------------------
 *  @desc
 *      主线: 对需要输出的的元素,进行配合输出即可 (比如吓一下鸟,它自己就飞走了);
 *      支线: 对不符合预测的元素修正 (比如剩下一只没飞走,我再更大声吓一下) (注:这涉及到外层循环,反向类比的修正);
 */
-(BOOL) reasonPlus:(AIFoNodeBase*)matchFo cutIndex:(NSInteger)cutIndex demandModel:(DemandModel*)demandModel{
    //1. 生成outFo模型
    TOFoModel *toFoModel = [TOFoModel newWithFo_p:matchFo.pointer base:demandModel];
    toFoModel.actionIndex = cutIndex + 1;
    
    //2. 对首元素进行行为化;
    return [self.delegate aiTOP_2TOR_ReasonPlus:toFoModel];
}
/**
 *  MARK:-------------------- R- --------------------
 *  @desc
 *      主线: 取matchFo的兄弟节点,进行行为化 (比如车将撞到我,我避开可避免);
 *      CutIndex: 本算法中,未使用cutIndex而是使用了subNode和plusNode来解决问题 (参考19152:R-)
 *  @TODO 1. 对抽象也尝试取brotherFo,比如车撞与落石撞,其实都是需要躲开"撞过来的物体";
 *  @version
 *      2020.05.12 - 支持cutIndex的判断,必须是未发生的部分才可以被修正 (如车将撞上,躲开是对的,但将已过去的出门改成不出门,是错的);
 */
-(BOOL) reasonSub:(AIFoNodeBase*)matchFo cutIndex:(NSInteger)cutIndex demandModel:(DemandModel*)demandModel{
    //1. 数据检查
    if (!matchFo) return false;
    
    //2. 用负取正;
    __block BOOL success = false;
    [TOUtils getPlusBrotherBySubProtoFo_NoRepeatNotNull:matchFo tryResult:^BOOL(AIFoNodeBase *checkFo, AIFoNodeBase *subNode, AIFoNodeBase *plusNode) {
        //a. 构建TOFoModel
        TOFoModel *toFoModel = [TOFoModel newWithFo_p:checkFo.pointer base:demandModel];
        toFoModel.actionIndex = cutIndex;
        
        //b. 转给TOR
        success = [self.delegate aiTOP_2TOR_ReasonSub:matchFo plusFo:plusNode subFo:subNode outModel:toFoModel];
        return success;//成功行为化,则中止递归;
    }];
    
    //3. 一条行为化成功,则整体成功;
    return success;
}
/**
 *  MARK:-------------------- P+ --------------------
 *  @desc
 *      1. 简介: mv方向索引找正价值解决方案;
 *      2. 实例: 饿了,现有面粉,做面吃可以解决;
 *      3. 步骤: 用A.refPorts ∩ F.conPorts (参考P+模式模型图);
 *  todo :
 *      1. 集成原有的能量判断与消耗 T;
 *      2. 评价机制1: 比如土豆我超不爱吃,在mvScheme中评价,入不应期,并继续下轮循环;
 *      3. 评价机制2: 比如炒土豆好麻烦,在行为化中反思评价,入不应期,并继续下轮循环;
 */
-(BOOL) perceptPlus:(AIAlgNodeBase*)matchAlg demandModel:(DemandModel*)demandModel{
    //1. 数据准备;
    if (!matchAlg || !demandModel) return false;
    MVDirection direction = [ThinkingUtils havDemand:demandModel.algsType delta:demandModel.delta];
    
    //2. 调用通用diff模式方法;
    NSLog(@"=========================TOP.P+");
    __block BOOL success = false;//默认为失败
    [TOUtils topPerceptMode:matchAlg demandModel:demandModel direction:direction tryResult:^BOOL(AIFoNodeBase *sameFo) {
        
        //a. 构建TOFoModel
        TOFoModel *toFoModel = [TOFoModel newWithFo_p:sameFo.pointer base:demandModel];
        toFoModel.actionIndex = 0;
        
        //b. 取自身,实现吃,则可不饿;
        NSLog(@"------------新增一例解决方案: %p",toFoModel);
        [self.delegate aiTOP_2TOR_PerceptPlus:toFoModel];
        
        //c. 用success记录下,是否本次成功找到候选方案;
        if (toFoModel.status == TOModelStatus_ActYes || toFoModel.status == TOModelStatus_Runing || toFoModel.status == TOModelStatus_Finish) {
            success = true;
        }
        
        //d. 一次只尝试一条,行为化中途失败时,自然会由流程控制方法递归TOP.P+重来;
        NSLog(@"=======================TOP.P+ tryResult return");
        return true;
    } canAss:^BOOL{
        return [self havEnergy];
    } updateEnergy:^(CGFloat delta) {
        [self useEnergy:delta];
    }];
    
    //3. 返回P+模式结果;
    return success;
}
/**
 *  MARK:-------------------- P- --------------------
 *  @desc mv方向索引找负价值的兄弟节点解决方案 (比如:打球打累了,不打了,避免更累);
 */
-(BOOL) perceptSub:(AIAlgNodeBase*)matchAlg demandModel:(DemandModel*)demandModel{
    //1. 数据准备;
    if (!matchAlg || !demandModel) return false;
    MVDirection direction = [ThinkingUtils havDemand:demandModel.algsType delta:demandModel.delta];
    direction = labs(direction - 1);//取反方向;
    
    //2. 调用通用diff模式方法;
    __block BOOL success = false;//默认为失败
    [TOUtils topPerceptMode:matchAlg demandModel:demandModel direction:direction tryResult:^BOOL(AIFoNodeBase *sameFo) {
        
        //a. 取兄弟节点,停止打球,则不再累;
        [TOUtils getPlusBrotherBySubProtoFo_NoRepeatNotNull:sameFo tryResult:^BOOL(AIFoNodeBase *checkFo, AIFoNodeBase *subNode, AIFoNodeBase *plusNode) {
            
            //b. 指定subNode和plusNode到行为化;
            success = [self.delegate aiTOP_2TOR_PerceptSub:sameFo plusFo:plusNode subFo:subNode checkFo:checkFo];
            
            //c. 一条成功,则中止取兄弟节点循环;
            return success;
        }];
        
        //d. 一条成功,则中止取消通用diff算法的交集循环;
        return success;
    } canAss:^BOOL{
        return [self havEnergy];
    } updateEnergy:^(CGFloat delta) {
        [self useEnergy:delta];
    }];
    
    //3. 返回P-模式结果;
    return success;
}


//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================
//使用能量
-(void) useEnergy:(CGFloat)delta{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOutPercept_UpdateEnergy:)]) {
        [self.delegate aiThinkOutPercept_UpdateEnergy:delta];//思考与决策消耗能量;
    }
}

//拥有能量
-(BOOL) havEnergy{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOutPercept_EnergyValid)]) {
        return [self.delegate aiThinkOutPercept_EnergyValid];
    }
    return false;
}

@end
