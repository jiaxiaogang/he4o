//
//  TCRegroup.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCRegroup.h"

@implementation TCRegroup

+(void) rRegroup:(AIShortMatchModel*)shortModel{
    //1. 构建时序 (把每次dic输入,都作为一个新的内存时序);
    [theTC updateOperCount:kFILENAME];
    Debug();
    NSArray *matchAShortMem = [theTC.inModelManager shortCache:true];
    shortModel.matchAFo = [theNet createConFo_NoRepeat:matchAShortMem];
    NSArray *protoAShortMem = [theTC.inModelManager shortCache:false];
    shortModel.protoFo = [theNet createConFo_NoRepeat:protoAShortMem];
    DebugE();
}

/**
 *  MARK:--------------------入口--------------------
 *  @version
 *      20200120 - 构建protoFo后,瞬时记忆改为不清空,为解决外层死循环问题 (因为外层循环需要行为输出后,将时序连起来) 参考n18p5-BUG9
 *      20200416 - 将先"mv需求处理"后"学习",改为先"学习"后"mv需求处理",因为外层死循环 (参考n19p5-B组BUG2);
 *      20210120 - 支持tir_OPush()反向反馈类比;
 */
+(void) pRegroup:(AICMVNodeBase*)mv shortModel:(AIShortMatchModel*)shortModel{
    //1. 联想到mv时,创建CmvModel取到FoNode;
    [theTC updateOperCount:kFILENAME];
    Debug();
    
    //2. 创建CmvModel取到FoNode;
    shortModel.protoFo = [theNet createCMVFo:shortModel.inputTime order:[theTC.inModelManager shortCache:false] mv:mv];
    //[self.shortMemory clear] (参考注释2020.01.20);
    DebugE();
}

/**
 *  MARK:--------------------feedbackTOR后重组--------------------
 *  @desc
 *      说明: 在foModel下找到subAlgModel,其中feedbackAlg有值的,替换到foModel中,并重组成新的时序;
 *      例如: [我要吃水果],结果反馈了榴莲,重组成[我要吃榴莲];
 *  @param feedbackFrameOfMatchAlgs : 触发调用此反馈重组方法的protoAlg的识别matchAlgs结果 (参考28103-2.2);
 *  @version
 *      2023.07.08: 写了action行为化反思后,这里已经没用了,所以关掉 (参考30054-另外);
 */
+(void) feedbackRegroup:(TOFoModel*)foModel feedbackFrameOfMatchAlgs:(NSArray*)feedbackFrameOfMatchAlgs {
    //1. 数据准备;
    if (!Switch4FeedbackRegroup) return;
    [theTC updateOperCount:kFILENAME];
    Debug();
    
    //3. 数据准备 (收集除末位外的content为order);
    NSArray *order = [foModel getOrderUseMatchAndFeedbackAlg:true];
    
    //6. 将时序元素生成新时序;
    AIFoNodeBase *regroupFo = [theNet createConFo_NoRepeat:order];
    
    //7. 识别时序 (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价);
    DebugE();
    [TCRecognition feedbackRecognition:regroupFo foModel:foModel feedbackFrameOfMatchAlgs:feedbackFrameOfMatchAlgs];
}

/**
 *  MARK:--------------------action输出前重组--------------------
 *  @desc 将瞬时记忆几帧 + canset要cutIndex之后要输出的几帧 = 拼接起来 (参考30054-方案&另外1);
 *  @version
 *      2023.07.09: 修复上帧为输出或mv时,未生成protoFo,导致收集不到前半部分order的问题 (参考30056);
 *      2023.07.09: 修复order的时间错乱的问题 (将前后部分统一为时间戳,以使regroupFo生成deltaTimes正确);
 *      2023.11.16: 修复order的inputTime时间前大后小的BUG (每次循环后更新lastInputTime即可);
 *      2023.11.16: 简化代码: 直接改成isTimestamp=false方式来收集后半部分;
 *      2024.08.30: 上回迭代TCPlanV2时R子任务已经废弃了(现在TCPlanV2没为R子任务做流程处理),但这里忘关掉了,现在关掉,等写派生Root任务时,再来打开改这里建子任务部分代码 (参考32071-问题2-TODO);
 */
+(void) actionRegroup:(TOFoModel*)actionFoModel {
    //1. 数据准备;
    if (!Switch4FeedbackRegroup) return;
    [theTC updateOperCount:kFILENAME];
    Debug();
    NSMutableArray *order = [[NSMutableArray alloc] init];
    
    //2. 收集瞬时记忆"刚已发生的protoFo"做为前半部分 (参考30054-todo1);
    [order addObjectsFromArray:[theTC.inModelManager shortCache:false]];
    
    //3. 收集cansetFo"即将行为化的部分"做为后半部分 (参考30054-todo2);
    AIFoNodeBase *actionFo = [SMGUtils searchNode:actionFoModel.content_p];
    for (NSInteger i = actionFoModel.cansetCutIndex + 1; i <= MIN(actionFoModel.cansetTargetIndex, actionFo.count - 1); i++) {
        AIKVPointer *item_p = ARR_INDEX(actionFo.content_ps, i);
        NSTimeInterval deltaTime = [NUMTOOK(ARR_INDEX(actionFo.deltaTimes, i)) doubleValue];
        [order addObject:[AIShortMatchModel_Simple newWithAlg_p:item_p inputTime:deltaTime isTimestamp:false]];
    }
    
    //4. 将时序元素生成新时序 (参考30054-todo3);
    AIFoNodeBase *regroupFo = [theNet createConFo_NoRepeat:order];
    
    //5. 识别时序 (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价) (参考30054-todo3);
    DebugE();
    [TCRecognition actionRecognition:regroupFo baseActionFo:actionFoModel];
}

@end
