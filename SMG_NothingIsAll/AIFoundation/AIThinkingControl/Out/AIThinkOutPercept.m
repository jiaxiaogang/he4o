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
#import "TOMvModel.h"
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

@implementation AIThinkOutPercept

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

-(void) dataOut {
    //1. 重排序 & 取当前序列最前的demandModel
    DemandModel *demandModel = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOutPercept_GetCurrentDemand)]) {
        demandModel = [self.delegate aiThinkOutPercept_GetCurrentDemand];
    }
    if (!demandModel) return;
    
    //2. energy判断;
    if (![self havEnergy]) {
        return;
    }
    
    //3. 取mvModel_从expCache中,排序并取到首个值得思考的可行outMvModel, 没有则用mvScheme联想一个新的;
    __block TOMvModel *outMvModel = [demandModel getCurSubModel];
    
    //3. 为空,取新的
    if (!outMvModel && demandModel.subModels.count < cTOSubModelLimit) {
        outMvModel = [self dataOut_MvScheme:demandModel];
    }
    
    //3. 再为空,评价mvModel_无解决经验,则反射输出;
    if (!outMvModel) {
        [self.delegate aiThinkOutPercept_MVSchemeFailure];
    }else{
        //4. 有可具象思考的outMvModel则执行;
        [self useEnergy:-1];
        
        //5. 取foModel_联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息 (foScheme);
        TOModelBase *outFoModel = outMvModel.getCurSubModel;
        
        //5. 为空,取新的
        if (!outFoModel && outMvModel.subModels.count < cTOSubModelLimit) {
            outFoModel = [self dataOut_FoScheme:outMvModel];
        }
        
        //5. 再为空,反馈上一级被不应期;
        if (!outFoModel) {
            [demandModel.except_ps addObject:outMvModel.content_p];//排除无效的outMvModel;
            [self dataOut];
        }else{
            if (ISOK(outFoModel, TOFoModel.class)) {
                TOFoModel *foModel = (TOFoModel*)outFoModel;
                
                //6. 为空,进行行为化_尝试输出"可行性之首"并找到实际操作 (子可行性判定) (algScheme)
                [self.delegate aiThinkOutPercept_Commit2TOR:foModel];
                
                //7. 再为空,反馈上一级被不应期;
                if (!ARRISOK(foModel.actions)) {
                    [outMvModel.except_ps addObject:foModel.content_p];
                    [self dataOut];
                }
            }
        }
    }
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------MvScheme--------------------
 *  功能:
 *      1. 用于找到新的mv经验; (根据index索引找到outMvModel)
 *  注:
 *      1. 目前仅从硬盘找mvNode,因为能解决问题的都几乎被抽象,而太过于具象的又很难行为化;
 */
-(TOMvModel*) dataOut_MvScheme:(DemandModel*)demandModel{
    //1. 判断mv方向
    __block TOMvModel *outMvModel = nil;
    MVDirection direction = [ThinkingUtils havDemand:demandModel.algsType delta:demandModel.delta];
    
    //2. 收集不应期
    NSMutableArray *except_ps = [[NSMutableArray alloc] init];
    for (TOMvModel *expCacheItem in demandModel.subModels) {
        [except_ps addObject:expCacheItem.content_p];
    }
    
    //3. 找normalFo解决方案;
    [theNet getNormalFoByDirectionReference:demandModel.algsType direction:direction except_ps:except_ps tryResult:^BOOL(AIKVPointer *fo_p) {
        if (fo_p) {
            outMvModel = [[TOMvModel alloc] initWithContent_p:fo_p];
            [demandModel.subModels addObject:outMvModel];
        }
        return true;
    }];
    
    //4. 加强关联;
    if (outMvModel && outMvModel.content_p) {
        AICMVNodeBase *cmvNode = [SMGUtils searchNode:outMvModel.content_p];
        [theNet setMvNodeToDirectionReference:cmvNode difStrong:1];
    }
    return outMvModel;
}


/**
 *  MARK:--------------------联想具象foNode--------------------
 *  @param outMvModel : 当前mvModel (具象之旅的出发点);
 *  @result : 返回时序节点地址
 *  1. 从上至下的联想foNode;
 *  注:目前支持每层3个(关联强度前3个),最多3层(具象方向3层);
 *
 *  TODO:加上联想到mv时,传回给demandManager;
 *  注:每一次输出,只是决策与预测上的一环;并不意味着结束;
 *  //1. 记录思考mv结果到叠加demandModel.order;
 *  //3. 如果mindHappy_No,可以再尝试下一个getNetNodePointersFromDirectionReference_Single;找到更好的解决方法;
 *  //4. 最终更好的解决方法被输出,并且解决问题后,被加强;
 *  //5. 是数据决定了下一轮循环思维想什么,但数据仅能通过mv来决定,无论是思考的方向,还是思考的能量,还是思考的目标,都是以mv为准的;而mv的一切关联,又是以数据为规律进行关联的;
 *
 */
-(TOFoModel*) dataOut_FoScheme:(TOMvModel*)outMvModel{
    //1. 数据准备
    if (!ISOK(outMvModel, TOMvModel.class)) {
        return nil;
    }
    AICMVNodeBase *checkMvNode = [SMGUtils searchNode:outMvModel.content_p];
    if (!checkMvNode) {
        return nil;
    }
    
    if (checkMvNode.foNode_p) {
        NSArray *checkFo_ps = @[checkMvNode.foNode_p];
        
        //2. 最多往具象循环三层
        for (NSInteger i = 0; i < cDataOutAssFoDeep; i++) {
            AIFoNodeBase *validFoNode = [ThinkingUtils scheme_GetAValidNode:checkFo_ps except_ps:outMvModel.except_ps checkBlock:nil];
            
            //3. 有效则返回,无效则循环到下一层
            if (ISOK(validFoNode, AIFoNodeBase.class)) {
                TOFoModel *result = [[TOFoModel alloc] initWithContent_p:validFoNode.pointer];
                result.score = [ThinkingUtils dataOut_CheckScore_ExpOut:result.content_p];
                [outMvModel.subModels addObject:result];
                [theNV setNodeData:result.content_p lightStr:@"o1"];
                return result;
            }else{
                checkFo_ps = [ThinkingUtils foScheme_GetNextLayerPs:checkFo_ps];
            }
        }
    }
    
    return nil;
}

/**
 *  MARK:--------------------topV2--------------------
 *  @desc 四种(2x2)TOP模式 (优先取同区工作模式,不行再以不同区工作模式);
 *  @version
 *      20200430 : v2,四种工作模式版;
 */
-(void) topV2{
    //1. 数据准备
    DemandModel *demand = [self.delegate aiThinkOutPercept_GetCurrentDemand];
    NSArray *mModels = [self.delegate aiTOP_GetShortMatchModel];
    if (!demand || !ARRISOK(mModels)) return;
    
    //2. 同区两个模式 (以最近的预测为准);
    for (NSInteger i = 0; i < mModels.count; i++) {
        AIShortMatchModel *mModel = ARR_INDEX_REVERSE(mModels, i);
        AIFoNodeBase *matchFo = mModel.matchFo;
        
        //a.预测有效性判断和同区判断 (以预测的正负为准);
        if (matchFo && matchFo.cmvNode_p && [demand.algsType isEqualToString:matchFo.pointer.algsType]) {
            CGFloat score = [ThinkingUtils getScoreForce:mModel.matchFo.cmvNode_p ratio:mModel.matchFoValue];
            //b. R+
            if (score > 0) {
                BOOL success = [self reasonPlus:matchFo cutIndex:mModel.cutIndex];
                if (success) return;
            }else if(score < 0){
                //c. R-
                BOOL success = [self reasonSub:matchFo cutIndex:mModel.cutIndex];
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

//MARK:===============================================================
//MARK:              < 四种工作模式 (参考19152) >
//MARK:===============================================================

/**
 *  MARK:-------------------- R+ --------------------
 *  @desc
 *      主线: 对需要输出的的元素,进行配合输出即可 (比如吓一下鸟,它自己就飞走了);
 *      支线: 对不符合预测的元素修正 (比如剩下一只没飞走,我再更大声吓一下) (注:这涉及到外层循环,反向类比的修正);
 */
-(BOOL) reasonPlus:(AIFoNodeBase*)matchFo cutIndex:(NSInteger)cutIndex{
    //将matchFo+作为CFo行为化;
    NSInteger start = cutIndex + 1;
    NSArray *need2Act_ps = ARR_SUB(matchFo.content_ps, start, matchFo.content_ps.count - start);
    return [self.delegate aiTOP_Commit2TOR_V2:need2Act_ps cFo:matchFo subNode:nil plusNode:nil];
}
/**
 *  MARK:-------------------- R- --------------------
 *  @desc
 *      主线: 取matchFo的兄弟节点,进行行为化 (比如车将撞到我,我避开可避免);
 *      CutIndex: 本算法中,未使用cutIndex而是使用了subNode和plusNode来解决问题 (参考19152:R-)
 *  @TODO 1. 对抽象也尝试取brotherFo,比如车撞与落石撞,其实都是需要躲开"撞过来的物体";
 */
-(BOOL) reasonSub:(AIFoNodeBase*)matchFo cutIndex:(NSInteger)cutIndex{
    //1. 数据检查
    if (!matchFo) return false;
    
    //2. 用负取正;
    __block BOOL success = false;
    [TOUtils getPlusBrotherBySubProtoFo_NoRepeatNotNull:matchFo tryResult:^BOOL(AIFoNodeBase *checkFo, AIFoNodeBase *subNode, AIFoNodeBase *plusNode) {
        //c. 指定subNode和plusNode到行为化 (一条成功,则中止循环);
        success = [self.delegate aiTOP_Commit2TOR_V2:checkFo.content_ps cFo:checkFo subNode:subNode plusNode:plusNode];
        return success;
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
        
        //a. 取自身,实现吃,则可不饿;
        success = [self.delegate aiTOP_Commit2TOR_V2:sameFo.content_ps cFo:sameFo subNode:nil plusNode:nil];
        
        //b. 一条成功,则中止取消通用diff算法的交集循环;
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
            success = [self.delegate aiTOP_Commit2TOR_V2:checkFo.content_ps cFo:checkFo subNode:subNode plusNode:plusNode];
            
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
