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
 *  @desc 由TIP调用,执行条件为:当imv与预测mv相符时,执行类比;
 *  @desc 如: (距20,经233) 与 (距20,经244) 可类比为: (距20)->{mv};
 *  解释:
 *   1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *   2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 *  步骤:
 *   > 联想->类比->规律->抽象->关联->网络
 *  @param protoFo : 传瞬时记忆的protoFo;
 *  @version
 *      2020.03.04: a.去掉外类比; b.外类比拆分为:正向类比和反向类比;
 *      2021.01.24: 支持多时序识别,更全面的触发外类比 (参考22073-todo4);
 *      2021.09.28: ATSame改为传ATDefault (参考24022-BUG5);
 *      2021.12.02: 将TCLearning独立成类 (参考24164);
 */
+(void) pLearning:(AIFoNodeBase*)protoFo{
    //1. 获取最近的识别模型;
    IFTitleLog(@"P学习", @"\n输入ProtoFo:%@->%@", Fo2FStr(protoFo),Mvp2Str(protoFo.cmvNode_p));
    NSArray *inModels = ARRTOOK(theTC.inModelManager.models);
    for (AIShortMatchModel *item in inModels) {
        for (AIMatchFoModel *pFo in item.matchPFos) {
            //2. 检查同向;
            BOOL isSame = [AIScore sameIdenSameScore:pFo.matchFo.cmvNode_p mv2:protoFo.cmvNode_p];
            if (!isSame) continue;
            
            //3. 正向反馈类比 (外类比);
            [AIAnalogy analogyOutside:protoFo assFo:pFo.matchFo type:ATDefault createAbsAlgBlock:nil];
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
 *      2021.12.26: GL和HN已全废弃了,所以删掉内类比调用 (参考Note24 & Note25);
 *      2022.01.17: BUG_找不到hSolution经验的问题,将P树R树衔接,共参与抽象 (参考25104);
 */
+(void) rLearning:(AIShortMatchModel*)model recognitionMaskFo:(AIFoNodeBase*)recognitionMaskFo{
    //1. 收集pFos和rFos都用于外类比学习;
    NSArray *matchFos = [SMGUtils collectArrA:model.matchRFos arrB:model.matchPFos];
    
    //2. 学习 for matchFos: 加强matchFos的抽具象关联;
    for (AIMatchFoModel *item in matchFos) {
        AIFoNodeBase *absRFo = [AIAnalogy analogyOutside:recognitionMaskFo assFo:item.matchFo type:ATSame createAbsAlgBlock:nil];
        if (Log4AnalogyAbsRFo) NSLog(@">>> 再抽象absFo: %@\t\tFrom MatchFo: F%ld",Fo2FStr(absRFo),item.matchFo.pointer.pointerId);
    }
    
    //3. TIR反馈;
    [TCFeedback feedbackTIR:model];
}

@end
