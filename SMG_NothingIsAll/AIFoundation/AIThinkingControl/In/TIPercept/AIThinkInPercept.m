//
//  AIThinkInPercept.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkInPercept.h"
#import "AIFrontOrderNode.h"
#import "AICMVNode.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "AINet.h"
#import "AIThinkInAnalogy.h"
#import "AINetIndex.h"

@implementation AIThinkInPercept

/**
 *  MARK:--------------------入口--------------------
 *  @version
 *      20200416 - 将先"mv需求处理"后"学习",改为先"学习"后"mv需求处理",因为外层死循环 (参考n19p5-B组BUG2);
 */
-(void) dataIn_FindMV:(NSArray*)algsArr
   createMvModelBlock:(AIFrontOrderNode*(^)(NSArray *algsArr,BOOL isMatch))createMvModelBlock
          finishBlock:(void(^)(AICMVNode *commitMvNode))finishBlock
               canAss:(BOOL(^)())canAss
         updateEnergy:(void(^)(CGFloat delta))updateEnergy{
    //1. 联想到mv时,创建CmvModel取到FoNode;
    if (!createMvModelBlock) return;
    AIFrontOrderNode *protoFo = createMvModelBlock(algsArr,false);
    if (!protoFo) return;
    
    //2. 取cmvNode
    AICMVNode *cmvNode = [SMGUtils searchNode:protoFo.cmvNode_p];
    if (!ISOK(cmvNode, AICMVNode.class)) {
        return;
    }
    
    //3. 学习
    [self dataIn_FindMV_Learning:protoFo cmvNode:cmvNode canAss:canAss updateEnergy:updateEnergy];
    
    //4. 思考mv,需求处理
    if (finishBlock) finishBlock(cmvNode);
}

/**
 *  MARK:--------------------学习--------------------
 *  分为:
 *   1. 外类比
 *   2. 内类比
 *  解释:
 *   1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *   2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 *  步骤:
 *   > 联想->类比->规律->抽象->关联->网络
 *  @version
 *      202003-04: a.去掉外类比; b.外类比拆分为:正向类比和反向类比;
 */
-(void) dataIn_FindMV_Learning:(AIFrontOrderNode*)protoFo cmvNode:(AICMVNode*)cmvNode canAss:(BOOL(^)())canAss updateEnergy:(void(^)(CGFloat delta))updateEnergy{
    //1. 数据检查 & 准备
    if (protoFo == nil || cmvNode == nil) {
        return;
    }
    
    //2. 获取最近的识别模型;
    NSArray *mModels = ARRTOOK([self.delegate tir_getShortMatchModel]);
    for (AIShortMatchModel *mModel in mModels) {
        //a. 正向反馈类比;
        [AIThinkInAnalogy analogy_Feedback_Same:mModel shortFo:protoFo];
        
        //b. 反向反馈类比;
        [AIThinkInAnalogy analogy_Feedback_Diff:mModel shortFo:protoFo];
    }
}

@end

