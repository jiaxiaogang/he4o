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
#import "ExpModel.h"
#import "AINet.h"
#import "AIKVPointer.h"
#import "AICMVNode.h"
#import "AIAbsCMVNode.h"
#import "AIFrontOrderNode.h"
#import "AINetAbsFoNode.h"
#import "Output.h"

@implementation AIThinkOut

//MARK:===============================================================
//MARK:                     < publicMethod >
//MARK:===============================================================

-(void) dataOut_AssociativeExperience {
    //1. 重排序 & 取当前序列最前;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_GetCurrentDemand)] && [self.delegate respondsToSelector:@selector(aiThinkOut_EnergyValid)]) {
        DemandModel *demandModel = [self.delegate aiThinkOut_GetCurrentDemand];
        if (demandModel != nil) {
            
            //2. energy判断;
            if ([self.delegate aiThinkOut_EnergyValid]) {
                //3. 从expCache中,排序并取到首个值得思考的expModel;
                __block ExpModel *expModel = [demandModel getCurrentExpModel];
                
                //4. 如果,没有一个想可行的,则再联想一个新的相关"解决经验";并重新循环下去;
                if (!expModel) {
                    [ThinkingUtils getDemand:demandModel.algsType delta:demandModel.delta complete:^(BOOL upDemand, BOOL downDemand) {
                        MVDirection direction = downDemand ? MVDirection_Negative : MVDirection_Positive;
                        
                        //5. filter筛选器取曾经历的除已有expModels之外的最强解决;
                        NSArray *mvRefs = [theNet getNetNodePointersFromDirectionReference:demandModel.algsType direction:direction filter:^NSArray *(NSArray *protoArr) {
                            protoArr = ARRTOOK(protoArr);
                            for (NSInteger i = 0; i < protoArr.count; i++) {
                                AIPort *port = ARR_INDEX(protoArr, protoArr.count - i - 1);
                                BOOL cacheContains = false;
                                for (ExpModel *expCacheItem in demandModel.expCache) {
                                    if (port.target_p && [port.target_p isEqual:expCacheItem.exp_p]) {
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
                        
                        //6. 加入待判断区;
                        AIPort *referenceMvPort = ARR_INDEX(mvRefs, 0);
                        if (referenceMvPort) {
                            expModel = [ExpModel newWithExp_p:referenceMvPort.target_p];
                            [demandModel addToExpCache:expModel];
                        }
                    }];
                }
                
                //7. 有可具象思考的expModel则执行;
                if (expModel) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_UpdateEnergy:)]) {
                        [self.delegate aiThinkOut_UpdateEnergy:-1];//思考与决策消耗能量;
                    }
                    [self dataOut_AssociativeConcreteData:expModel complete:^(BOOL canOut, NSArray *out_ps,BOOL expModelInvalid) {
                        if (canOut) {
                            [self dataOut_TryOut:expModel outArr:out_ps];
                        }else{
                            if (expModelInvalid) {
                                [demandModel.exceptExpModels addObject:expModel];  //排除无效的expModel;(一次无效,不表示永远无效,所以彻底无效时,再排除)
                            }
                            [self dataOut_AssociativeExperience];               //并递归到最初;
                        }
                    }];
                }else{
                    //8. 无解决经验,反射输出;//V2TODO:此处不应放弃联想,应该先看下当前有哪些信息,是可以联想分析出解决方案的; (跳出递归)
                    [self dataOut_Reflex:AIMoodType_Anxious];
                }
            }else{
                //9. 如果energy<=0,(未找到可行性,直接反射输出 || 尝试输出"可行性之首"并找到实际操作)
                [self dataOut_Reflex:AIMoodType_Anxious];
            }
        }
    }
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------联想具象 (从上往下找foNode)--------------------
 *  @param expModel : 从expModel下查找具象可输出;
 */
-(void) dataOut_AssociativeConcreteData:(ExpModel*)expModel complete:(void(^)(BOOL canOut,NSArray *out_ps,BOOL expModelInvalid))complete{
    __block BOOL invokedComplete = false;
    __block BOOL expModelInvalid = false;
    if (expModel) {
        //1. 联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息;(可行性判定)
        NSObject *expMvNode = [SMGUtils searchObjectForPointer:expModel.exp_p fileName:FILENAME_Node time:cRedisNodeTime];
        AIFrontOrderNode *expOutFoNode = [self dataOut_AssociativeConcreteData_ExpOut:expMvNode except_ps:expModel.exceptExpOut_ps];
        
        //2. 有执行方案,则对执行方案进行反思检查;
        if (expOutFoNode != nil) {
            [self dataOut_CheckScore_ExpOut:expOutFoNode complete:^(CGFloat score, NSArray *out_ps) {
                expModel.order += score;//联想对当前expModel的order影响;
                NSLog(@" >> 执行经验输出: (%@) (%f) (%@)",score >= 3 ? @"成功" : @"失败",score,[NVUtils convertOrderPs2Str:out_ps]);
                if (score >= 3) {
                    complete(true,out_ps,expModelInvalid);
                    invokedComplete = true;
                }
            }];
        }else{
            //4. 没有执行方案,转向对抽象宏节点进行尝试输出;
            AINetAbsFoNode *tryOutAbsNode = [self dataOut_AssociativeConcreteData_TryOut:expMvNode exceptTryOut_ps:expModel.exceptTryOut_ps];
            if (tryOutAbsNode != nil) {
                [self dataOut_CheckScore_TryOut:tryOutAbsNode complete:^(CGFloat score, NSArray *out_ps) {
                    expModel.order += score;//联想对当前expModel的order影响;
                    NSLog(@" >> 执行尝试输出: (%@) (%f) (%@)",score > 10 ? @"成功" : @"失败",score,[NVUtils convertOrderPs2Str:out_ps]);
                    if (score > 10) {
                        complete(true,out_ps,expModelInvalid);
                        invokedComplete = true;
                    }
                }];
            }else{
                //5. 本expModel彻底无效,
                expModelInvalid = true;
            }
        }
    }
    
    if (!invokedComplete) {
        NSLog(@" >> 本次输出不过关,toLoop...");
        complete(false,nil,expModelInvalid);
    }
}


/**
 *  MARK:--------------------联想具象 (从上往下找foNode)--------------------
 *  @param baseMvNode : mv节点经验(有可能是AICMVNode也有可能是AIAbsCMVNode)
 *  @param checkMvNode : 当前正在检查的节点 (初始状态下=baseMvNode)
 *  @param checkMvNode_p : 当前正在检查的节点地址 (初始状态下=nil,然后=checkMvNode.pointer) (用于当网络中mv或mv指向foNode为null的情况下,能够继续执行下去)
 *  @param except_ps : 当前已排除的;
 *  功能 : 找到曾输出经验;
 *  TODO:加上预测功能
 *  TODO:加上联想到mv时,传回给demandManager;
 *  注:每一次输出,只是决策与预测上的一环;并不意味着结束;
 *  //1. 记录思考mv结果到叠加demandModel.order;
 *  //2. 记录思考data结果到thinkFeedCache;
 *  //3. 如果mindHappy_No,可以再尝试下一个getNetNodePointersFromDirectionReference_Single;找到更好的解决方法;
 *  //4. 最终更好的解决方法被输出,并且解决问题后,被加强;
 *  //5. 是数据决定了下一轮循环思维想什么,但数据仅能通过mv来决定,无论是思考的方向,还是思考的能量,还是思考的目标,都是以mv为准的;而mv的一切关联,又是以数据为规律进行关联的;
 *  注: 先从最强关联的最底层foNode开始,逐个取用;直到energy<=0,或其它原因中止;
 *
 */
-(AIFrontOrderNode*) dataOut_AssociativeConcreteData_ExpOut:(NSObject*)baseMvNode except_ps:(nonnull NSMutableArray*)except_ps{
    return [self dataOut_AssociativeConcreteData_ExpOut:baseMvNode checkMvNode:baseMvNode checkMvNode_p:nil except_ps:except_ps];
}
-(AIFrontOrderNode*) dataOut_AssociativeConcreteData_ExpOut:(NSObject*)baseMvNode checkMvNode:(NSObject*)checkMvNode checkMvNode_p:(AIPointer*)checkMvNode_p except_ps:(nonnull NSMutableArray*)except_ps {
    
    //1. 当前神经元异常时,回归到checkBase; 注:(异常判定: <(类型无效 | null) & checkMvNode!=nil>);
    __block AIFrontOrderNode *foNode = nil;
    AIFrontOrderNode* (^ CheckIsNullOrException)() = ^{
        BOOL nullOrException = (checkMvNode_p != nil);
        if (nullOrException) {
            [except_ps addObject:checkMvNode_p];
            foNode = [self dataOut_AssociativeConcreteData_ExpOut:baseMvNode except_ps:except_ps];
        }
        return foNode;
    };
    
    //2. 具象mv
    if (ISOK(checkMvNode, AICMVNode.class)) {
        AICMVNode *cmvNode = (AICMVNode*)checkMvNode;
        AIFrontOrderNode *foNode = [ThinkingUtils getFoNodeFromCmvNode:cmvNode];
        if (foNode) {
            [except_ps addObject:cmvNode.pointer];
            NSLog(@" >> 找到经验cmvModel: %@",[NVUtils getCmvModelDesc:foNode cmvNode:cmvNode]);
            return foNode;
        }else{
            //3. 前因时序列为null的异常;
            return CheckIsNullOrException();
        }
    }else if(ISOK(checkMvNode, AIAbsCMVNode.class)){
        //4. 抽象mv
        AIAbsCMVNode *checkAbsMvNode = (AIAbsCMVNode*)checkMvNode;
        AIPort *findConPort = [checkAbsMvNode getConPortWithExcept:except_ps];
        if (!findConPort) {
            //5. 没找到conPort,说明checkMvNode的所有conPort都已排除,则checkMvNode本身也被排除;
            [except_ps addObject:checkAbsMvNode.pointer];
            
            //6. 被排除的不是base才可以递归回checkBase;
            if (![baseMvNode isEqual:checkMvNode]) {
                return [self dataOut_AssociativeConcreteData_ExpOut:baseMvNode except_ps:except_ps];
            }
        }else{
            //7. 找到conPort,则递归判断类型是否foNode;
            AICMVNodeBase *findConNode = [SMGUtils searchObjectForPointer:findConPort.target_p fileName:FILENAME_Node];
            NSLog(@" >> 找到经验cmvNode: %@ 强度: %ld",[NVUtils getCmvNodeDesc:findConNode],(long)findConPort.strong.value);
            return [self dataOut_AssociativeConcreteData_ExpOut:baseMvNode checkMvNode:findConNode checkMvNode_p:findConPort.target_p except_ps:except_ps];
        }
    }else{
        //8. 类型异常
        return CheckIsNullOrException();
    }
    
    //9. 连base自己也被排除了,还未找到foNode,就只能返回nil了;
    return nil;
}


/**
 *  MARK:--------------------联想具象 (从下往上找absNode)--------------------
 *  @param expMvNode :  当前在判断的mv节点经验(有可能是AICMVNode也有可能是AIAbsCMVNode)
 *  @result : 返回前因节点地址(仅absNode_p,不要foNode_p)
 *  功能 : 找可尝试输出 (激活输出);
 *  1. 从上至下的联想absNode;
 *  注:目前仅支持每层1个,与最分支向下联想,即abs的最强关联的下层前1;
 */
-(AINetAbsFoNode*) dataOut_AssociativeConcreteData_TryOut:(NSObject*)expMvNode exceptTryOut_ps:(nonnull NSMutableArray*)exceptTryOut_ps{
    if(ISOK(expMvNode, AIAbsCMVNode.class)){
        //1. 判断是否已排除
        AIAbsCMVNode *expAbsCmvNode = (AIAbsCMVNode*)expMvNode;
        BOOL excepted = false;
        for (AIPointer *except_p in exceptTryOut_ps) {
            if ([except_p isEqual:expAbsCmvNode.pointer]) {
                excepted = true;
                break;
            }
        }
        
        //2. 未排除,返回;
        if (!excepted) {
            [exceptTryOut_ps addObject:expAbsCmvNode.foNode_p];
            AINetAbsFoNode *result = [SMGUtils searchObjectForPointer:expAbsCmvNode.foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
            return result;
        }else{
            //3. 已排除,递归下一层;
            AIPort *firstConPort = [expAbsCmvNode getConPort:0];
            if (firstConPort != nil) {
                NSObject *firstConNode = [SMGUtils searchObjectForPointer:firstConPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
                return [self dataOut_AssociativeConcreteData_TryOut:firstConNode exceptTryOut_ps:exceptTryOut_ps];
            }
        }
    }
    return nil;
}

/**
 *  MARK:--------------------可行性判定 (经验执行方案)--------------------
 *  注:TODO:后续可以增加energy的值,并在此方法中每一次scoreForce就energy--;以达到更加精细的思维控制;
 *
 *  A:根据out_ps联想(分析可行性)
 *  >assHavResult : 其有没有导致mv-和mv+;
 *    > mv-则:联想conPort,思考具象;
 *    > mv+则:score+分;
 *  >assNoResult :
 *
 */
-(void) dataOut_CheckScore_ExpOut:(AIFrontOrderNode*)foNode complete:(void(^)(CGFloat score,NSArray *out_ps))complete{
    if (!foNode) {
        complete(0,nil);
    }
    CGFloat score = 0;
    
    //1. 取出outLog;
    NSArray *out_ps = [ThinkingUtils filterOutPointers:foNode.orders_kvp];
    
    //2. 评价 (根据当前foNode的mv果,处理cmvNode评价影响力;(系数0.2))
    score = [ThinkingUtils getScoreForce:foNode.cmvNode_p ratio:0.2f];
    
    ////4. v1.0评价方式: (目前outLog在foAbsNode和index中,无法区分,所以此方法仅对foNode的foNode.out_ps直接抽象部分进行联想,作为可行性判定原由)
    /////1. 取foNode的抽象节点absNodes;
    //for (AIPort *absPort in ARRTOOK(foNode.absPorts)) {
    //
    //    ///2. 判断absNode是否是由out_ps抽象的 (根据"微信息"组)
    //    AINetAbsFoNode *absNode = [SMGUtils searchObjectForPointer:absPort.target_p fileName:FILENAME_Node time:cRedisNodeTime];
    //    if (absNode) {
    //        BOOL fromOut_ps = [SMGUtils containsSub_ps:absNode.orders_kvp parent_ps:out_ps];
    //
    //        ///3. 根据当前absNode的mv果,处理absCmvNode评价影响力;(系数0.2)
    //        if (fromOut_ps) {
    //            CGFloat scoreForce = [ThinkingUtils getScoreForce:absNode.cmvNode_p ratio:0.2f];
    //            score += scoreForce;
    //        }
    //    }
    //}
    
    complete(score,out_ps);
}

/**
 *  MARK:--------------------可行性判定 (尝试激活执行方案)--------------------
 */
-(void) dataOut_CheckScore_TryOut:(AINetAbsFoNode*)absFoNode complete:(void(^)(CGFloat score,NSArray *out_ps))complete{
    CGFloat score = 0;
    if (!absFoNode) {
        complete(0,nil);
    }
    
    //2. 根据microArr_p联想到对应的assAbsCmvNode; (去除组微信息absValue,并且此处如果联想最强引用的absValue,会导致 跨全网区执行的bug)
    //AIKVPointer *absValue_p = [theNet getNetAbsIndex_AbsPointer:absFoNode.absValue_p];
    //AIPointer *absNode_p = [theNet getItemAbsNodePointer:absValue_p];
    //AINetAbsFoNode *assAbsNode = [SMGUtils searchObjectForPointer:absNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    
    //3. 处理assAbsNode评价影响力;(系数0.8)
    CGFloat scoreForce = [ThinkingUtils getScoreForce:absFoNode.cmvNode_p ratio:0.8f];
    score += scoreForce;
    complete(score,absFoNode.orders_kvp);
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
-(void) dataOut_TryOut:(ExpModel*)expModel outArr:(NSArray*)outArr{
    //1. 尝试输出找到解决问题的实际操作 (取到当前cacheModel中的最佳决策,并进行输出;)
    BOOL tryOutSuccess = false;
    if (expModel && ARRISOK(outArr)) {
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
        [self dataOut_Reflex:AIMoodType_Anxious];
    }
}

/**
 *  MARK:--------------------反射输出--------------------
 */
-(void) dataOut_Reflex:(AIMoodType)moodType{
    [Output output_Mood:moodType];
}

@end
