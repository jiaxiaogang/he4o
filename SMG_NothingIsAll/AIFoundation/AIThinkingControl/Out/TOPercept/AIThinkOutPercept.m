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
//MARK:              < 四种工作模式 (参考19152) >
//MARK: @desc 事实上,主要就P+和R-会触发思维工作;
//MARK:===============================================================


/**
 *  MARK:-------------------- P+ --------------------
 *  @desc mv方向索引找负价值的兄弟节点解决方案 (比如:打球打累了,不打了,避免更累);
 *  @废弃: 因为P+是不存在的(或者说目前不需要的),可以以P-&R-替代之;
 */
-(BOOL) perceptPlus:(AIAlgNodeBase*)matchAlg demandModel:(DemandModel*)demandModel{
    //1. 数据准备;
    //if (!matchAlg || !demandModel) return false;
    //MVDirection direction = [ThinkingUtils getDemandDirection:demandModel.algsType delta:demandModel.delta];
    //direction = labs(direction - 1);//取反方向;
    
    //2. 调用通用diff模式方法;
    __block BOOL success = false;//默认为失败
    //topPerceptModeV2方法,已迁移到TCSolution.pSolution()中;
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

@end
