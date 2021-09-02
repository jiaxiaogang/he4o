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
#import "AIMatchFoModel.h"
#import "AINetUtils.h"

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
    
    //4. tip_OPushM
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
 *      2020.03.04: a.去掉外类比; b.外类比拆分为:正向类比和反向类比;
 *      2021.01.24: 支持多时序识别,更全面的触发外类比 (参考22073-todo4);
 */
-(void) dataIn_FindMV_Learning:(AIFrontOrderNode*)protoFo cmvNode:(AICMVNode*)cmvNode{
    //1. 数据检查 & 准备
    if (protoFo == nil || cmvNode == nil) {
        return;
    }
    
    //2. 获取最近的识别模型;
    NSArray *mModels = ARRTOOK([self.delegate tir_getShortMatchModel]);
    for (AIShortMatchModel *mModel in mModels) {
        for (AIMatchFoModel *foModel in mModel.matchPFos) {
            
            //3. 正向反馈类比 (外类比);
            [AIAnalogy analogy_Feedback_Same:foModel.matchFo shortFo:protoFo];
        }
    }
}

/**
 *  MARK:--------------------"外层输入" 推进 "中层循环" 认知--------------------
 *  @title 外层输入对In短时记忆的影响处理 (参考22052-2);
 *  @version
 *      2021.01.24: 对多时序识别结果支持,及时全面的改变status为OutBackYes (参考22073-todo5);
 *      2021.02.04: In反省支持虚mv,所以此处也要支持虚mv的OPush判断 (参考22108);
 *  @bug
 *      2021.01.25: 修复witMatchFo.cmvNode_p空判断逻辑反了,导致无法执行修改状态为OutBackYes,从而反省类比永远为"逆";
 */
+(void) tip_OPushM:(AICMVNode*)newMv{
    //1. 数据检查
    NSArray *inModels = theTC.inModelManager.models;
    if (!newMv) return;
    OFTitleLog(@"tip_OPushM", @"\n输入MV:%@",Mv2FStr(newMv));
    
    //3. 判断最近一次input是否与等待中outModel相匹配 (匹配,比如吃,确定自己是否真吃了);
    for (AIShortMatchModel *inModel in inModels) {
        for (AIMatchFoModel *waitModel in inModel.matchPFos) {
            //3. 非等待中的跳过;
            AIFoNodeBase *waitMatchFo = waitModel.matchFo;
            if (Log4OPushM) NSLog(@"==> checkTIModel=MatchFo: %@ (%@)",Fo2FStr(waitMatchFo),TIStatus2Str(waitModel.status));
            if (waitModel.status != TIModelStatus_LastWait || !waitMatchFo.cmvNode_p) continue;
            
            //4. 等待中的inModel_判断hope(wait)和real(new)之间是否相符;
            if ([AINetUtils isVirtualMv:waitMatchFo.cmvNode_p]) {
                //a. 虚mv仅标记同区反向反馈;
                if ([AIScore sameIdenDiffDelta:waitMatchFo.cmvNode_p mv2:newMv.pointer]) {
                    waitModel.status = TIModelStatus_OutBackDiffDelta;
                    NSLog(@"tip_OPushM: 虚MV 反向反馈");
                }
            }else{
                //b. 实mv仅标记同区同向反馈;
                if ([AIScore sameIdenSameScore:waitMatchFo.cmvNode_p mv2:newMv.pointer]) {
                    waitModel.status = TIModelStatus_OutBackSameDelta;
                    NSLog(@"tip_OPushM: 实MV 正向反馈");
                }
            }
        }
    }
}

@end

