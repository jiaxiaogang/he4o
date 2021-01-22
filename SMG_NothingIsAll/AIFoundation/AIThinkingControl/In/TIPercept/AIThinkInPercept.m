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
#import "AIAnalogy.h"
#import "AINetIndex.h"
#import "ShortMatchManager.h"
#import "AIShortMatchModel.h"
#import "AIAlgNodeBase.h"
#import "AIScore.h"

@implementation AIThinkInPercept

/**
 *  MARK:--------------------入口--------------------
 *  @version
 *      20200416 - 将先"mv需求处理"后"学习",改为先"学习"后"mv需求处理",因为外层死循环 (参考n19p5-B组BUG2);
 *      20210120 - 支持tir_OPush()反向反馈类比;
 */
-(void) dataIn_FindMV:(NSArray*)algsArr
   createMvModelBlock:(AIFrontOrderNode*(^)(NSArray *algsArr,BOOL isMatch))createMvModelBlock
          finishBlock:(void(^)(AICMVNode *commitMvNode))finishBlock{
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
    [self dataIn_FindMV_Learning:protoFo cmvNode:cmvNode];
    
    //4. OPushM
    [AIThinkInPercept tip_OPushM:cmvNode];
    
    //5. 思考mv,需求处理
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
-(void) dataIn_FindMV_Learning:(AIFrontOrderNode*)protoFo cmvNode:(AICMVNode*)cmvNode{
    //1. 数据检查 & 准备
    if (protoFo == nil || cmvNode == nil) {
        return;
    }
    
    //2. 获取最近的识别模型;
    NSArray *mModels = ARRTOOK([self.delegate tir_getShortMatchModel]);
    for (AIShortMatchModel *mModel in mModels) {
        //a. 正向反馈类比;
        [AIAnalogy analogy_Feedback_Same:mModel shortFo:protoFo];
    }
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 认知--------------------
 *  @title 外层输入对In短时记忆的影响处理 (参考22052-2);
 */
+(void) tip_OPushM:(AICMVNode*)newMv{
    //1. 数据检查
    NSArray *inModels = theTC.inModelManager.models;
    if (!newMv) return;
    
    //2. 取出所有等待中的inModel;
    NSArray *waitModels = [SMGUtils filterArr:inModels checkValid:^BOOL(AIShortMatchModel *item) {
        return item.status == TIModelStatus_LastWait && item.matchFo.cmvNode_p;
    }];
    NSLog(@"\n\n=============================== tip_OPushM ===============================\n输入MV:%@\n等待中任务数:%lu",Mv2FStr(newMv),(long)waitModels.count);
    
    //3. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    for (AIShortMatchModel *waitModel in waitModels) {
        AIFoNodeBase *waitMatchFo = waitModel.matchFo;
        if (Log4OPushM) NSLog(@"==> checkTIModel=MatchFo: %@",Fo2FStr(waitMatchFo));
        
        //4. 判断hope(wait)和real(new)之间是否相符 (同区且同向);
        BOOL isSame = [AIScore sameScoreOfMV1:waitMatchFo.cmvNode_p mv2:newMv.pointer];
        if (isSame) {
            waitModel.status = TIModelStatus_OutBackYes;
            NSLog(@"tip_OPushM: MV有效");
        }
    }
}

@end

