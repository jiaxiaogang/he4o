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
#import "TOAlgScheme.h"
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
    
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------topV2--------------------
 *  @desc 四种(2x2)TOP模式 (优先取同区工作模式,不行再以不同区工作模式);
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
        if (matchFo && matchFo.cmvNode_p && [demand.algsType isEqualToString:matchFo.pointer.algsType]) {
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
    //self.P+
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
    __block BOOL success = false;//默认为失败
    [TOUtils topPerceptMode:matchAlg demandModel:demandModel direction:direction tryResult:^BOOL(AIFoNodeBase *sameFo) {
        
        //a. 构建TOFoModel
        TOFoModel *toFoModel = [TOFoModel newWithFo_p:sameFo.pointer base:demandModel];
        toFoModel.actionIndex = 0;
        
        //b. 取自身,实现吃,则可不饿;
        success = [self.delegate aiTOP_2TOR_PerceptPlus:toFoModel];
        
        //c. 一条成功,则中止取消通用diff算法的交集循环;
        return success;
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


/**
 *  MARK:--------------------algScheme--------------------
 *  1. 将fo.orders转换为memOrder;
 *  2. 对条件概念取最具象 (目前仅支持1层);
 *
 *  注: 最具象不表示真实,所以此方法可考虑去掉;
 *  注: 190425,废弃"memOrder"和"最具象概念"后备份于此;
 */
//-(void) dataOut_AlgScheme_Front:(TOFoModel*)outFoModel{
//    //1. 数据准备
//    if (!ISOK(outFoModel, TOFoModel.class)) {
//        return;
//    }
//    AIFoNodeBase *foNode = [SMGUtils searchObjectForPointer:outFoModel.content_p fileName:kFNNode time:cRTNode];
//    if (!foNode) {
//        return;
//    }
//
//    //废弃"memOrder"和"最具象概念"
//    [outFoModel.memOrder removeAllObjects];
//
//    2. 取条件概念的最具象,得出memOrder;
//    //NSLog(@" >> 所需条件: (%@)",[NVUtils convertOrderPs2Str:notOutAlg_ps]);
//    for (AIKVPointer *pointer in foNode.content_ps) {
//        ///1. 本身为输出节点的话,直接收集到memOrder
//        if (pointer.isOut) {
//            AIAlgNodeBase *outAlgNode = [SMGUtils searchObjectForPointer:pointer fileName:kFNNode time:cRTNode];
//            if (outAlgNode) {
//                [outFoModel.memOrder addObject:outAlgNode];
//            }
//        }else{
//            ///2. 非输出时,找出条件概念,并收集到memOrder (最多往具象循环2层) (最具象不表示真实,所以此处可以考虑去掉)
//            NSArray *check_ps = @[pointer];
//            for (NSInteger i = 0; i < cDataOutAssAlgDeep; i++) {
//                AIAlgNode *validAlgNode = [ThinkingUtils scheme_GetAValidNode:check_ps except_ps:outFoModel.except_ps checkBlock:^BOOL(id checkNode) {
//                    return ISOK(checkNode, AIAlgNode.class);
//                }];
//
//                //3. 有效则返回,无效则循环到下一层
//                if (ISOK(validAlgNode, AIAlgNode.class)) {
//                    [outFoModel.memOrder addObject:validAlgNode];
//                }else{
//                    check_ps = [ThinkingUtils algScheme_GetNextLayerPs:check_ps];
//                }
//            }
//        }
//    }
//
//    //3. 对memOrder有效性初步检查 (memOrder和fo.orders长度要一致)
//    if (outFoModel.memOrder.count == foNode.content_ps.count) {
//        [self dataOut_AlgScheme:outFoModel];
//    }else{
//        [self dataOut];
//    }
//}
