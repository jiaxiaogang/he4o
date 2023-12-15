//
//  TCInput.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCInput.h"

@implementation TCInput

/**
 *  MARK:--------------------输入非mv信息时--------------------
 *  @todo
 *      1. 远古TODO: 看到西瓜会开心 : 对自身状态的判断, (比如,看到西瓜,想吃,那么当前状态是否饿)
 *          > 已解决,废弃了useNode,并由mModel替代,且会交由demandManager做此处理;
 *      2. TODOWAIT: TIR_Alg识别后,要进行类比,并构建网络关联; (参考n16p7)
 *      3. 点击饥饿,再点击乱投,此处返回了matchFo:nil matchValue:0;
 *          > 已解决,因为fromMemShort是4层alg,而fromRethink是两层;
 *  @version
 *      20200416 - 修复时序识别的bug: 因概念节点去重不够,导致即使概念内容一致,在时序识别时,也会无法匹配 (参考n19p5-A组BUG4);
 *      20200731 - 将protoFo和matchAFo的构建改为isMem=false (因为构建到内存的话,在内类比构建时序具象指向为空,参考20151-BUG);
 *      20200817 - 赋值protoAlg和matchAlg即是存瞬时记忆,因为瞬时与短时整合了;
 *      20201019 - 将mModel更提前保留至mModelManager中;
 *      20201112 - TIR_Fo支持不应其except_ps,将protoF和matchAF都设为不应期,避免AF识别P回来 (参考21144);
 *      20201113 - 构建matchAFo时,MatchA为空时,兼容取part首条,否则会导致时序识别失败 (参考21144);
 *      20210118 - 支持生物钟触发器 (未完成) (参考22052-1);
 *      20210119 - 支持TIR_OPushM (参考22052-2);
 *      20211016 - 将预测调整到R决策之后,因为R决策总会卡住,而预测中将来的UI变化迟迟不来 (参考24058-方案1);
 *      20211017 - 在执行决策前,先到OPushM将TIModel.status更新了,因为有些IRT触发器已经失效了 (参考24061);
 *      20230301 - 输出行为不必再触发`时序识别&学习&任务&反省` (参考28137-修复);
 *      20230531 - r时序识别结束后,调用识别二次过滤器 (参考29107-todo3);
 *      20231107 - 将feedbackTIR调整到feedbackTOR之前 (参考30154-todo4.2);
 */
+(void) rInput:(AIAlgNodeBase*)algNode except_ps:(NSArray*)except_ps{
    ISGroupLog(@"input R");
    [theTC updateLoopId];
    [theTC updateOperCount:kFILENAME];
    Debug();
    //1. 数据准备 (瞬时记忆,理性匹配出的模型);
    __block AIShortMatchModel *mModel = [[AIShortMatchModel alloc] init];
    mModel.protoAlg = algNode;
    mModel.inputTime = [[NSDate date] timeIntervalSince1970];
    
    //2. 识别概念;
    [TIUtils TIR_Alg:algNode.pointer except_ps:except_ps inModel:mModel];
    
    //3. 将mModel保留 (只有先保留后,构建时序时,才会含新帧概念);
    [theTC.inModelManager add:mModel];
    DebugE();
    
    //4. 概念反馈 -> TIR反馈;
    //todo: 加了二次过滤后,此处过滤后,仅剩几条了 (可能导致tir太难feedback成功了) (先不改,等测得具体有影响的bug时再改);
    NSArray *feedbackedPFos = [TCFeedback feedbackTIR:mModel];
    
    //4. 概念反馈 -> 重组 & 反思;
    //todo: 加了二次过滤后,此处过滤前,可能太杂了,毕竟pAlgs过过滤了50% (可能导致tor才容易feedback成功了) (先不改,等测得具体有影响的bug时再改);
    [TCFeedback feedbackTOR:mModel];
    
    //5. 转regroup生成protoFo;
    [TCRegroup rRegroup:mModel];
    AIFoNodeBase *protoFo = ARRISOK(mModel.matchAlgs) ? mModel.protoFo : mModel.matchAFo;
    
    //6. 行为不触发识别和学习 (参考28137-修复);
    if (!algNode.pointer.isOut || Switch4IsOutReIn) {
        //7. 时序识别
        [TCRecognition rRecognition:mModel];
        
        //8. 识别二次过滤器;
        [AIFilter secondRecognitionFilter:mModel];
        
        //8. 学习;
        [TCLearning rLearning:mModel protoFo:protoFo];
    }
    
    //10. 行为不构建任务和预测 (参考28137-修复);
    if (!algNode.pointer.isOut || Switch4IsOutReIn) {
        //11. 任务;
        [TCDemand rDemand:mModel protoFo:mModel.protoFo];
        
        for (AIMatchFoModel *feedbackedPFo in feedbackedPFos) {
//            feedbackedPFo.baseRDemand.status = TOModelStatus_ScoreNo;
            NSLog(@"旧的往后送 %@",Pit2FStr(feedbackedPFo.matchFo));
            
            //1. 手训步骤,看下solution过度执行的问题;
            //复现: FZ917x2,路边出生,饿,路中扔带皮果,棒
            //日志: 测得以下日志,TO确实一直在执行,每次不是果饿果饿,就是饿果饿果;
            //分析: 此时看起来已经是去皮成功了,只差飞过去吃掉;
            //尝试: 可以试下feedbackTIP是不是也要收集往后送 / 或者pInput时,也要调用feedbackTIR吧,因为现在mv也会入时序中;
            /*
             任务源:饿 protoFo:F15380[饿] 已有方案数:0 任务分:-10.23
             任务源:饿 protoFo:F15406[棒,果,饿,果] 已有方案数:0 任务分:-14.29
             任务源:饿 protoFo:F15404[饿,棒,果,饿] 已有方案数:0 任务分:-9.75
             任务源:饿 protoFo:F15422[果,饿,果,饿] 已有方案数:0 任务分:-9.79
             任务源:饿 protoFo:F15432[饿,果,饿,果] 已有方案数:0 任务分:-15.27
             任务源:饿 protoFo:F15430[果,饿,果,饿] 已有方案数:0 任务分:-9.81
             任务源:饿 protoFo:F15440[饿,果,饿,果] 已有方案数:0 任务分:-15.31
             任务源:饿 protoFo:F15438[果,饿,果,饿] 已有方案数:0 任务分:-9.84
             任务源:饿 protoFo:F15448[饿,果,饿,果] 已有方案数:0 任务分:-15.35
             任务源:饿 protoFo:F15446[果,饿,果,饿] 已有方案数:0 任务分:-9.87
             任务源:饿 protoFo:F15456[饿,果,饿,果] 已有方案数:0 任务分:-15.38
             任务源:饿 protoFo:F15454[果,饿,果,饿] 已有方案数:0 任务分:-9.90
             任务源:饿 protoFo:F15464[饿,果,饿,果] 已有方案数:0 任务分:-15.41
             任务源:饿 protoFo:F15466[果,饿,果,饿] 已有方案数:0 任务分:-9.93
             任务源:饿 protoFo:F15474[果,饿,果,饿] 已有方案数:0 任务分:-9.96
             任务源:饿 protoFo:F15482[果,饿,果,饿] 已有方案数:0 任务分:-9.99
             任务源:饿 protoFo:F15492[饿,果,饿,果] 已有方案数:0 任务分:-15.50
             任务源:饿 protoFo:F15490[果,饿,果,饿] 已有方案数:0 任务分:-10.01
             任务源:饿 protoFo:F15500[饿,果,饿,果] 已有方案数:0 任务分:-15.52
             任务源:饿 protoFo:F15498[果,饿,果,饿] 已有方案数:0 任务分:-10.04
             任务源:饿 protoFo:F15508[饿,果,饿,果] 已有方案数:0 任务分:-15.54
             任务源:饿 protoFo:F15506[果,饿,果,饿] 已有方案数:0 任务分:-10.06
             任务源:饿 protoFo:F15516[饿,果,饿,果] 已有方案数:0 任务分:-15.56
             任务源:饿 protoFo:F15514[果,饿,果,饿] 已有方案数:0 任务分:-10.09
             任务源:饿 protoFo:F15524[饿,果,饿,果] 已有方案数:0 任务分:-15.57
             任务源:饿 protoFo:F15522[果,饿,果,饿] 已有方案数:0 任务分:-10.11
             任务源:饿 protoFo:F15532[饿,果,饿,果] 已有方案数:0 任务分:-15.59
             */
            
            
            
            //2. 再试下训练"学H去皮",看下日志关于过度执行solution的问题;
            
            
        }
        
        //12. 为新matchPFos & matchRFos构建反省触发器;
        [TCForecast forecast_Multi:mModel.matchPFos];
        [TCForecast forecast_Multi:mModel.matchRFos];
    }
    
    //13. 转继续决策;
    [TCScore scoreFromIfTCNeed];
}

/**
 *  MARK:--------------------pInput--------------------
 *  @desc pInput时:
 *          1. 生成的protoFo构建指向mv的时序,并用于learning学习;
 *          2. 生成的protoFo4PInput构建mv放到content末帧的时序,并用于pInput时的时序识别 (参考30094-todo3);
 *  @version
 *      2023.03.11: mv也生成shortModel,并加入瞬时序列 (参考28171-todo6);
 *      2023.03.11: 捋一下mv输入不需要概念识别和时序识别 (参考28171-todo5);
 *      2023.08.08: pInput时支持时序识别 & 构建任务 & 预测 (参考30094-todo3 & todo5);
 */
+(void) pInput:(AICMVNodeBase*)mv{
    ISGroupLog(@"input P");
    [theTC updateLoopId];
    [theTC updateOperCount:kFILENAME];
    Debug();
    //1. 数据准备 (瞬时记忆,理性匹配出的模型);
    __block AIShortMatchModel *shortModel = [[AIShortMatchModel alloc] init];
    shortModel.protoAlg = mv;
    shortModel.inputTime = [[NSDate date] timeIntervalSince1970];
    DebugE();
    
    //2. 识别概念;
    [TIUtils TIR_Alg:mv.pointer except_ps:nil inModel:shortModel];
    
    //2. 转regroup生成protoFo;
    [TCRegroup pRegroup:mv shortModel:shortModel];
    
    //3. P不需要概念识别,但可以直接生成AIShortMatchModel,并收集到瞬时序列 => 将mModel保留 (只有先保留后,构建时序时,才会含新帧概念);
    [theTC.inModelManager add:shortModel];
    
    //4. protoFo4PInput是以mv为结尾构建时序,然后又想以mv为一帧来识别 (参考30093-方案1-改动点 & 30094-todo3);
    shortModel.protoFo4PInput = [theNet createConFo:[theTC.inModelManager shortCache:false]];
    
    //5. P不需要时序识别,但可以触发学习 => 提交学习识别;
    [TCRecognition pRecognition:shortModel];
    
    //6. 学习
    [TCLearning pLearning:shortModel.protoFo];
    
    //7. 取cmvNode: tip反馈: tip_OPushM & top_OPushM;
    AICMVNode *cmvNode = [SMGUtils searchNode:shortModel.protoFo.cmvNode_p];
    if (!ISOK(cmvNode, AICMVNode.class)) {
        return;
    }
    [TCFeedback feedbackTIP:shortModel.protoFo cmvNode:cmvNode];
    [TCFeedback feedbackTOP:cmvNode];
    
    //8. 任务=>生成p任务: 行为不构建任务和预测 (参考28137-修复);
    [TCDemand rDemand:shortModel protoFo:shortModel.protoFo4PInput];

    //9. 为新matchPFos & matchRFos构建反省触发器;
    [TCForecast forecast_Multi:shortModel.matchPFos];
    [TCForecast forecast_Multi:shortModel.matchRFos];
}

+(void) hInput:(TOAlgModel*)algModel{
    ISGroupLog(@"input H");
    [theTC updateLoopId];
    [theTC updateOperCount:kFILENAME];
    Debug();
    DebugE();
    [TCDemand hDemand:algModel];
}

@end
