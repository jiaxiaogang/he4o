//
//  AIThinkOut.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkOut.h"
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
#import "Output.h"
#import "TOFoModel.h"
#import "AIAbsAlgNode.h"
#import "AIAlgNode.h"

@implementation AIThinkOut

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

-(void) dataOut {
    //1. 重排序 & 取当前序列最前的demandModel
    DemandModel *demandModel = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_GetCurrentDemand)]) {
        demandModel = [self.delegate aiThinkOut_GetCurrentDemand];
    }
    if (!demandModel) return;
    
    //2. energy判断;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_EnergyValid)]) {
        if (![self.delegate aiThinkOut_EnergyValid]) {
            ///1. 如果energy<=0,(未找到可行性,直接反射输出)
            [self dataOut_ActionScheme:nil];
            return;
        }
    }
    
    //3. 从expCache中,排序并取到首个值得思考的可行outMvModel, 没有则用mvScheme联想一个新的;
    __block TOMvModel *outMvModel = [demandModel getCurrentTOMvModel];
    if (!outMvModel) {
        outMvModel = [self dataOut_MvScheme:demandModel];
    }
    if (!outMvModel) {
        ///1. 无解决经验,反射输出;
        [self dataOut_ActionScheme:nil];
        return;
    }
    
    //4. 有可具象思考的outMvModel则执行;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_UpdateEnergy:)]) {
        [self.delegate aiThinkOut_UpdateEnergy:-1];//思考与决策消耗能量;
    }
    
    //5. 联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息 (foScheme);
    TOFoModel *outFoModel = [self dataOut_FoScheme:outMvModel];
    if (!outFoModel) return;
    
    //6. 有执行方案,则对执行方案进行反思检查; (父可行性判定)
    CGFloat score = [ThinkingUtils dataOut_CheckScore_ExpOut:outFoModel.content_p];
    outMvModel.order += score;//联想对当前outMvModel的order影响;
    if (score < 3) {
        NSLog(@" >> 本次输出不过关,toLoop...");
        [demandModel.exceptOutMvModels addObject:outMvModel];//排除无效的outMvModel;
        [self dataOut];//并递归到最初;
        return;
    }
    
    //7. 尝试输出"可行性之首"并找到实际操作 (子可行性判定) (algScheme)
    ///1. 取出outLog;
    [self dataOut_AlgScheme:outFoModel];
    
    
    
    
    //8. actionScheme (行为方案输出)
    [self dataOut_ActionScheme:nil];
    
    
    
    
    
    
    
    
    
    
    
    //6. foScheme (联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息;(可行性判定))
    //1. 从抽象方向找到fo节点;
    //2. 评价fo节点;
    //3. 筛选出out_ps和 "条件"
    //4. 注: 目前条件为"视觉看到的坚果" (已抽象的,如无距离)
    //5. 难点: 在于如何去满足这个条件;
    //6. 在外界去找到"条件";
    
    
    
    
    
    //明日计划;
    //1. 从抽象方向开始找foNode (而不是当前的具象方向);
    //2. 对找到的absFoNode装成outFoModel & 对条件进行判定;
    
    
    
    
    
    //明日计划;//20190131
    //1. 找到抽象foNode;
    //2. 把absFoNode中isOut部分跳过,其他为所需条件部分;
    //3. 到祖母中,对所需条件和已有条件进行类比,并分析出不同 (如距离)
    //4. 回归到fo找出能够让 "距离变化" 的时序,并找到行为方式 (如飞行)
    //5. 执行输出;
    //6. 视觉输入,(对outModel中的数据进行判定效果,继续执行决策)
    //先写一些伪代码;把以上步骤定义好结构架子;
    
    
    
    //TODONextYear: 从抽象往具象,往alg两个方向找实现方式与条件;
    
    //对实现方式foScheme已完成;
    
    //TODOTOMORROW: 写条件部分;(祖母)
    
    
    
    
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------MvScheme--------------------
 *  用于找到新的mv经验; (根据index索引找到outMvModel)
 */
-(TOMvModel*) dataOut_MvScheme:(DemandModel*)demandModel{
    //1. 判断mv方向
    __block TOMvModel *outMvModel = nil;
    [ThinkingUtils getDemand:demandModel.algsType delta:demandModel.delta complete:^(BOOL upDemand, BOOL downDemand) {
        MVDirection direction = downDemand ? MVDirection_Negative : MVDirection_Positive;
        
        //2. filter筛选器取曾经历的除已有outMvModels之外的最强解决;
        NSArray *mvRefs = [theNet getNetNodePointersFromDirectionReference:demandModel.algsType direction:direction filter:^NSArray *(NSArray *protoArr) {
            protoArr = ARRTOOK(protoArr);
            for (NSInteger i = 0; i < protoArr.count; i++) {
                AIPort *port = ARR_INDEX(protoArr, protoArr.count - i - 1);
                BOOL cacheContains = false;
                for (TOMvModel *expCacheItem in demandModel.outMvModels) {
                    if (port.target_p && [port.target_p isEqual:expCacheItem.mvNode_p]) {
                        cacheContains = true;
                        break;
                    }
                }
                if (!cacheContains) {
                    return @[port];
                }
            }
            return nil;
        }];
        
        //3. 加入待判断区;
        AIPort *referenceMvPort = ARR_INDEX(mvRefs, 0);
        if (referenceMvPort) {
            outMvModel = [TOMvModel newWithExp_p:referenceMvPort.target_p];
            [demandModel addToExpCache:outMvModel];
        }
    }];
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
    AICMVNodeBase *checkMvNode = [SMGUtils searchObjectForPointer:outMvModel.mvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
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
                TOFoModel *result = [[TOFoModel alloc] init];
                result.content_p = validFoNode.pointer;
                return result;
            }else{
                checkFo_ps = [ThinkingUtils foScheme_GetNextLayerPs:checkFo_ps];
            }
        }
    }
    
    return nil;
}


/**
 *  MARK:--------------------algScheme--------------------
 *  1. 对条件祖母进行判定;
 *  2. 对条件祖母取最具象 (目前仅支持1层);
 */
-(void) dataOut_AlgScheme:(TOFoModel*)outFoModel{
    //1. 数据准备
    if (!ISOK(outFoModel, TOFoModel.class)) {
        return;
    }
    AIFoNodeBase *foNode = [SMGUtils searchObjectForPointer:outFoModel.content_p fileName:FILENAME_Node time:cRedisNodeTime];
    if (!foNode) {
        return;
    }
    [outFoModel.memOrder removeAllObjects];
    
    //2. 取条件祖母的最具象,得出memOrder;
    //NSLog(@" >> 所需条件: (%@)",[NVUtils convertOrderPs2Str:notOutAlg_ps]);
    for (AIKVPointer *pointer in foNode.orders_kvp) {
        ///1. 本身为输出节点的话,直接收集到memOrder
        if (pointer.isOut) {
            AIAlgNodeBase *outAlgNode = [SMGUtils searchObjectForPointer:pointer fileName:FILENAME_Node time:cRedisNodeTime];
            if (outAlgNode) {
                [outFoModel.memOrder addObject:outAlgNode];
            }
        }else{
            ///2. 非输出时,找出条件祖母,并收集到memOrder (最多往具象循环2层) (最具象不表示真实,所以此处可以考虑去掉)
            NSArray *check_ps = @[pointer];
            for (NSInteger i = 0; i < cDataOutAssAlgDeep; i++) {
                AIAlgNode *validAlgNode = [ThinkingUtils scheme_GetAValidNode:check_ps except_ps:outFoModel.except_ps checkBlock:^BOOL(id checkNode) {
                    return ISOK(checkNode, AIAlgNode.class);
                }];
                
                //3. 有效则返回,无效则循环到下一层
                if (ISOK(validAlgNode, AIAlgNode.class)) {
                    [outFoModel.memOrder addObject:validAlgNode];
                }else{
                    check_ps = [ThinkingUtils algScheme_GetNextLayerPs:check_ps];
                }
            }
        }
    }
    
    //3. 对memOrder有效性初步检查 (memOrder和fo.orders长度要一致)
    if (outFoModel.memOrder.count == foNode.orders_kvp.count) {
        
        //4. 进行行为化; (通过有无,变化,等方式,将结构中所有条件祖母行为化);
        for (AIAlgNodeBase *curAlg in outFoModel.memOrder) {
            if (!curAlg.pointer.isOut) {
                
                ///1. 对条件祖母行为化
                AIPointer *hav_p = [theNet getNetDataPointerWithData:@(cHav) algsType:curAlg.pointer.algsType dataSource:curAlg.pointer.dataSource];
                AIAlgNodeBase *havAlg = [theNet getAbsoluteMatchingAlgNodeWithValueP:hav_p];
                if (havAlg == nil) {
                    NSLog(@"祖母不可实现!!! 此TOFoModel失败!!! DESC:找不到cHav祖母");
                }
                
                ///2. 根据havAlg构建成ThinkOutAlgModel
                
                
                ///3. 根据havAlg联想时序,并找出新的解决方案,与新的行为化的祖母,与新的条件祖母;
                AIPointer *havAlgRef = ARR_INDEX(havAlg.refPorts, 0);
                
                
                AIFoNodeBase *havFo = [SMGUtils searchObjectForPointer:havAlgRef fileName:FILENAME_Node time:cRedisNodeTime];
                if (havFo == nil) {
                    NSLog(@"祖母不可实现!!! 此TOFoModel失败!!! DESC:找不到cHav时序");
                }
                
                ///4. 取出havFo除第一个和最后一个之外的中间rangeOrder
                if (havFo.orders_kvp.count > 2) {
                    NSArray *rangeOrder = ARR_SUB(havFo.orders_kvp, 1, havFo.orders_kvp.count - 2);
                    
                    //5. 递归,对rangeOrder进行类似memOrder的祖母行为化;
                    
                    
                    
                    //TODO明日计划:
                    //1. 将以上代码进行封装为独立方法,可递归执行;
                    //2. 将DemandModel->TOMvModel->TOFoModel->TOAlgModel的模型结构化关系整理清晰;
                    
                    
                    
                }else{
                    NSLog(@"祖母不可实现!!! 此TOFoModel失败!!! DESC:cHav时序无效");
                }
                
                
                
            }
            
        }
        //TODOTOMMROWW:
        //*****代码步骤: (发现->距离->飞行)
        ///1. 比如找到坚果,由有无时序来解决"有无"问题; (cNone,cHav) (有无)
        ///2. 找到的坚果与fo中进行类比;(找出坚果距离的不同,或者坚果带皮儿的不同) (cLess,cGreater) (变化)
        ///3. 将距离与带皮转化成行为,条件的行为化; (如飞行,或去皮); (actionScheme) (行为)
    }else{
        [self dataOut];
    }
}


/**
 *  MARK:--------------------尝试输出信息--------------------
 *  @param outArr : orders里筛选出来的algNode组;
 *
 *  三种输出方式:
 *  1. 反射输出 : reflexOut
 *  2. 激活输出 : absNode信息无conPorts方向的outPointer信息时,将absNode的宏信息尝试输出;
 *  3. 经验输出 : expOut指在absNode或conPort方向有outPointer信息;
 */
-(void) dataOut_ActionScheme:(NSArray*)outArr{
    //1. 尝试输出找到解决问题的实际操作 (取到当前cacheModel中的最佳决策,并进行输出;)
    BOOL tryOutSuccess = false;
    if (ARRISOK(outArr)) {
        for (AIKVPointer *algNode_p in outArr) {
            //>1 检查micro_p是否是"输出";
            //>2 假如order_p足够确切,尝试检查并输出;
            BOOL invoked = [Output output_TC:algNode_p];
            if (invoked) {
                tryOutSuccess = true;
            }
        }
    }
    
    //2. 无法解决时,反射一些情绪变化,并增加额外输出;
    if (!tryOutSuccess) {
        //>1 产生"心急mv";(心急产生只是"urgent.energy x 2")
        //>2 输出反射表情;
        //>3 记录log到foOrders;(记录log应该到output中执行)
        
        //1. 如果未找到复现方式,或解决方式,则产生情绪:急
        //2. 通过急,输出output表情哭
        NSLog(@"反射输出 >>");
        [Output output_Mood:AIMoodType_Anxious];
    }
}

@end
