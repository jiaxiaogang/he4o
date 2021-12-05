//
//  TCLearning.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCLearning.h"

@implementation TCLearning

/**
 *  MARK:--------------------学习--------------------
 *  @desc 外类比;
 *  @desc 输入mv时调用,执行OPushM + 更新P任务池 + 执行P决策;
 *  解释:
 *   1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *   2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 *  步骤:
 *   > 联想->类比->规律->抽象->关联->网络
 *  @version
 *      2020.03.04: a.去掉外类比; b.外类比拆分为:正向类比和反向类比;
 *      2021.01.24: 支持多时序识别,更全面的触发外类比 (参考22073-todo4);
 *      2021.12.02: 将TCLearning独立成类 (参考24164);
 */
+(void) pLearning:(AIFoNodeBase*)protoFo{
    
    //2. 获取最近的识别模型;
    NSArray *inModels = ARRTOOK(theTC.inModelManager.models);
    for (AIShortMatchModel *item in inModels) {
        for (AIMatchFoModel *pFo in item.matchPFos) {
            
            //3. 正向反馈类比 (外类比);
            [AIAnalogy analogy_Feedback_Same:pFo.matchFo shortFo:protoFo];
        }
    }
    
    //4. 取cmvNode: tip反馈 & 生成p任务;
    AICMVNode *cmvNode = [SMGUtils searchNode:protoFo.cmvNode_p];
    if (!ISOK(cmvNode, AICMVNode.class)) {
        return;
    }
    
    //4. tip_OPushM
    [TCFeedback feedbackTIP:cmvNode];
    
    //2. top_OPushM
    [TCFeedback feedbackTOP:cmvNode];
}

/**
 *  MARK:--------------------理性noMv输入处理--------------------
 *  @desc 输入noMv时调用,执行OPushM + 更新R任务池 + 执行R决策;
 *  联想网络杏仁核得来的则false;
 *  @version
 *      2020.10.19: 将add至ShortMatchManager代码前迁;
 *      2021.12.05: 将feedbackTOR前迁到概念识别之后 (参考24171-9);
 */
+(void) rLearning:(AIShortMatchModel*)model recognitionMaskFo:(AIFoNodeBase*)recognitionMaskFo{
    //3. 学习 for RFos: 加强RFos的抽具象关联;
    for (AIMatchFoModel *item in model.matchRFos) {
        AIFoNodeBase *absRFo = [AIAnalogy analogyOutside:recognitionMaskFo assFo:item.matchFo type:ATSame createAbsAlgBlock:nil];
        if (Log4AnalogyAbsRFo) NSLog(@">>> 抽象absRFo: %@\t\tFrom MatchRFo: F%ld",Fo2FStr(absRFo),item.matchFo.pointer.pointerId);
        if (absRFo && ![model.absRFos containsObject:absRFo]) [model.absRFos addObject:absRFo];
    }
    
    //5. 学习 for 内类比
    [AIAnalogy analogyInner:model];
    
    //5. TIR反馈;
    [TCFeedback feedbackTIR:model];
}

+(void) subDemandLearning:(AIShortMatchModel*)model{
    [TCFeedback feedbackSubDemand:model];
}

@end
