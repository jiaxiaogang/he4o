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
    
    //4. 概念反馈 -> 重组 & 反思;
    [TCFeedback feedbackTOR:mModel];
    
    //5. 转regroup生成protoFo;
    [TCRegroup rRegroup:mModel];
    AIFoNodeBase *protoFo = ARRISOK(mModel.matchAlgs) ? mModel.protoFo : mModel.matchAFo;
    
    //6. 行为不触发识别和学习 (参考28137-修复);
    if (!algNode.pointer.isOut || Switch4IsOutReIn) {
        //7. 时序识别
        [TCRecognition rRecognition:mModel];
        
        //8. 学习;
        [TCLearning rLearning:mModel protoFo:protoFo];
    }
    
    //9. TIR反馈;
    [TCFeedback feedbackTIR:mModel];
    
    //10. 行为不构建任务和预测 (参考28137-修复);
    if (!algNode.pointer.isOut || Switch4IsOutReIn) {
        //11. 任务;
        NSArray *newRoots = [TCDemand rDemand:mModel];
        
        //12. 为新roots构建反省触发器;
        [TCForecast forecast_Multi:newRoots];
    }
    
    //13. 转继续决策;
    [TCScore score];
}

/**
 *  MARK:--------------------pInput--------------------
 *  @version
 *      2023.03.11: mv也生成shortModel,并加入瞬时序列
 */
+(void) pInput:(AICMVNode*)mv{
    ISGroupLog(@"input P");
    [theTC updateLoopId];
    [theTC updateOperCount:kFILENAME];
    Debug();
    //1. 数据准备 (瞬时记忆,理性匹配出的模型);
    __block AIShortMatchModel *shortModel = [[AIShortMatchModel alloc] init];
    shortModel.protoAlg = mv;
    shortModel.inputTime = [[NSDate date] timeIntervalSince1970];
    DebugE();
    
    //TODOTOMORROW20230311:
    //1. shortModel的potoAlg支持mv类型;
    //2. 看生成时序时,收集元素兼容收集mv元素;
    
    
    
    
    
    //2. 转regroup生成protoFo;
    [TCRegroup pRegroup:mv shortModel:shortModel];
    
    //3. P不需要概念识别,但可以直接生成AIShortMatchModel,并收集到瞬时序列 => 将mModel保留 (只有先保留后,构建时序时,才会含新帧概念);
    [theTC.inModelManager add:shortModel];
    
    //4. P不需要时序识别,但可以触发学习 => 提交学习识别;
    [TCRecognition pRecognition:shortModel.protoFo];
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
