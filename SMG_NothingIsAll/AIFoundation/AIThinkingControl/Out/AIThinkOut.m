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
#import "AIThinkOutMvModel.h"
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

-(void) dataOut {
    //1. 重排序 & 取当前序列最前;
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_GetCurrentDemand)] && [self.delegate respondsToSelector:@selector(aiThinkOut_EnergyValid)]) {
        DemandModel *demandModel = [self.delegate aiThinkOut_GetCurrentDemand];
        if (demandModel != nil) {
            
            //2. energy判断;
            if ([self.delegate aiThinkOut_EnergyValid]) {
                //3. 从expCache中,排序并取到首个值得思考的outMvModel;
                __block AIThinkOutMvModel *outMvModel = [demandModel getCurrentAIThinkOutMvModel];
                
                //4. mvScheme (如果,没有一个想可行的,则再联想一个新的相关"解决经验";并重新循环下去;)
                if (!outMvModel) {
                    outMvModel = [self dataOut_MvScheme:demandModel];
                }
                
                //5. 有可具象思考的outMvModel则执行;
                if (outMvModel) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(aiThinkOut_UpdateEnergy:)]) {
                        [self.delegate aiThinkOut_UpdateEnergy:-1];//思考与决策消耗能量;
                    }
                    
                    //6. foScheme (联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息;(可行性判定))
                    [self dataOut_FoScheme:outMvModel complete:^(BOOL canOut, NSArray *out_ps,BOOL outMvModelInvalid) {
                        if (canOut) {
                            
                            //7. actionScheme (行为方案输出)
                            [self dataOut_ActionScheme:out_ps];
                        }else{
                            if (outMvModelInvalid) {
                                [demandModel.exceptOutMvModels addObject:outMvModel];  //排除无效的outMvModel;(一次无效,不表示永远无效,所以彻底无效时,再排除)
                            }
                            [self dataOut];               //并递归到最初;
                        }
                    }];
                }else{
                    //8. 无解决经验,反射输出;//V2TODO:此处不应放弃联想,应该先看下当前有哪些信息,是可以联想分析出解决方案的; (跳出递归)
                    [self dataOut_ActionScheme:nil];
                }
            }else{
                //9. 如果energy<=0,(未找到可行性,直接反射输出 || 尝试输出"可行性之首"并找到实际操作)
                [self dataOut_ActionScheme:nil];
            }
        }
    }
}

//MARK:===============================================================
//MARK:                     < privateMethod >
//MARK:===============================================================

/**
 *  MARK:--------------------mvScheme--------------------
 *  用于找到新的mv经验;
 */
-(AIThinkOutMvModel*) dataOut_MvScheme:(DemandModel*)demandModel{
    //1. 判断mv方向
    __block AIThinkOutMvModel *outMvModel = nil;
    [ThinkingUtils getDemand:demandModel.algsType delta:demandModel.delta complete:^(BOOL upDemand, BOOL downDemand) {
        MVDirection direction = downDemand ? MVDirection_Negative : MVDirection_Positive;
        
        //2. filter筛选器取曾经历的除已有outMvModels之外的最强解决;
        NSArray *mvRefs = [theNet getNetNodePointersFromDirectionReference:demandModel.algsType direction:direction filter:^NSArray *(NSArray *protoArr) {
            protoArr = ARRTOOK(protoArr);
            for (NSInteger i = 0; i < protoArr.count; i++) {
                AIPort *port = ARR_INDEX(protoArr, protoArr.count - i - 1);
                BOOL cacheContains = false;
                for (AIThinkOutMvModel *expCacheItem in demandModel.outMvModels) {
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
            outMvModel = [AIThinkOutMvModel newWithExp_p:referenceMvPort.target_p];
            [demandModel addToExpCache:outMvModel];
        }
    }];
    return outMvModel;
}


/**
 *  MARK:--------------------联想具象 (从上往下找foNode)--------------------
 *  @param outMvModel : 从outMvModel下查找具象可输出;
 */
-(void) dataOut_FoScheme:(AIThinkOutMvModel*)outMvModel complete:(void(^)(BOOL canOut,NSArray *out_ps,BOOL outMvModelInvalid))complete{
    
    //1. 从抽象方向找到fo节点;
    //2. 评价fo节点;
    //3. 筛选出out_ps和 "条件"
    //4. 注: 目前条件为"视觉看到的坚果" (已抽象的,如无距离)
    //5. 难点: 在于如何去满足这个条件;
    //6. 在外界去找到"条件";
    
    
    
    __block BOOL invokedComplete = false;
    __block BOOL outMvModelInvalid = false;
    if (outMvModel) {
        //1. 联想"解决经验"对应的cmvNode & 联想具象数据,并取到决策关键信息;(可行性判定)
        NSObject *expMvNode = [SMGUtils searchObjectForPointer:outMvModel.mvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        
        
        
        //明日计划;
        //1. 从抽象方向开始找foNode (而不是当前的具象方向);
        //2. 对找到的absFoNode装成outFoModel & 对条件进行判定;
        
        //3. 与现实世界的交互; (可通过内存out模型的方式来解决) (以后必须再回归到网络中,而不是太多模型)
        
        
        
        
        
        AIFrontOrderNode *expOutFoNode = [self dataOut_ConFoScheme:expMvNode except_ps:outMvModel.exceptExpOut_ps];
        
        //2. 有执行方案,则对执行方案进行反思检查;
        if (expOutFoNode != nil) {
            [ThinkingUtils dataOut_CheckScore_ExpOut:expOutFoNode complete:^(CGFloat score, NSArray *out_ps) {
                outMvModel.order += score;//联想对当前outMvModel的order影响;
                NSLog(@" >> 执行经验输出: (%@) (%f) (%@)",score >= 3 ? @"成功" : @"失败",score,[NVUtils convertOrderPs2Str:out_ps]);
                if (score >= 3) {
                    complete(true,out_ps,outMvModelInvalid);
                    invokedComplete = true;
                }
            }];
        }else{
            //4. 没有执行方案,转向对抽象宏节点进行尝试输出;
            AINetAbsFoNode *tryOutAbsNode = [self dataOut_AbsFoScheme:expMvNode exceptTryOut_ps:outMvModel.exceptTryOut_ps];
            if (tryOutAbsNode != nil) {
                [ThinkingUtils dataOut_CheckScore_TryOut:tryOutAbsNode complete:^(CGFloat score, NSArray *out_ps) {
                    outMvModel.order += score;//联想对当前outMvModel的order影响;
                    NSLog(@" >> 执行尝试输出: (%@) (%f) (%@)",score > 10 ? @"成功" : @"失败",score,[NVUtils convertOrderPs2Str:out_ps]);
                    if (score > 10) {
                        complete(true,out_ps,outMvModelInvalid);
                        invokedComplete = true;
                    }
                }];
            }else{
                //5. 本outMvModel彻底无效,
                outMvModelInvalid = true;
            }
        }
    }
    
    if (!invokedComplete) {
        NSLog(@" >> 本次输出不过关,toLoop...");
        complete(false,nil,outMvModelInvalid);
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
-(AIFrontOrderNode*) dataOut_ConFoScheme:(NSObject*)baseMvNode except_ps:(nonnull NSMutableArray*)except_ps{
    return [self dataOut_ConFoScheme:baseMvNode checkMvNode:baseMvNode checkMvNode_p:nil except_ps:except_ps];
}
-(AIFrontOrderNode*) dataOut_ConFoScheme:(NSObject*)baseMvNode checkMvNode:(NSObject*)checkMvNode checkMvNode_p:(AIPointer*)checkMvNode_p except_ps:(nonnull NSMutableArray*)except_ps {
    
    //1. 当前神经元异常时,回归到checkBase; 注:(异常判定: <(类型无效 | null) & checkMvNode!=nil>);
    __block AIFrontOrderNode *foNode = nil;
    AIFrontOrderNode* (^ CheckIsNullOrException)() = ^{
        BOOL nullOrException = (checkMvNode_p != nil);
        if (nullOrException) {
            [except_ps addObject:checkMvNode_p];
            foNode = [self dataOut_ConFoScheme:baseMvNode except_ps:except_ps];
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
                return [self dataOut_ConFoScheme:baseMvNode except_ps:except_ps];
            }
        }else{
            //7. 找到conPort,则递归判断类型是否foNode;
            AICMVNodeBase *findConNode = [SMGUtils searchObjectForPointer:findConPort.target_p fileName:FILENAME_Node];
            NSLog(@" >> 找到经验cmvNode: %@ 强度: %ld",[NVUtils getCmvNodeDesc:findConNode],(long)findConPort.strong.value);
            return [self dataOut_ConFoScheme:baseMvNode checkMvNode:findConNode checkMvNode_p:findConPort.target_p except_ps:except_ps];
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
-(AINetAbsFoNode*) dataOut_AbsFoScheme:(NSObject*)expMvNode exceptTryOut_ps:(nonnull NSMutableArray*)exceptTryOut_ps{
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
                return [self dataOut_AbsFoScheme:firstConNode exceptTryOut_ps:exceptTryOut_ps];
            }
        }
    }
    return nil;
}


/**
 *  MARK:--------------------algScheme--------------------
 *  1. 对祖母条件进行判定;
 */
-(void) dataOut_AlgScheme{
    
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
