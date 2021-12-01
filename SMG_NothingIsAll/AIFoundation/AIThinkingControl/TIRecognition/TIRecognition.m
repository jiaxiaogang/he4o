//
//  TIRecognition.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TIRecognition.h"

@implementation TIRecognition

+(void) rRecognition:(AIShortMatchModel*)model{
    //4. 识别时序;
    [AIThinkInReason TIR_Fo_FromShortMem:@[model.protoFo.pointer,model.matchAFo.pointer] decoratorInModel:model];
    
    //5. 内类比
    [AIAnalogy analogyInner:model];
    
    //6. 理性反馈;
    [TIForecast feedbackTIR:model];
    
    //7. R任务_预测mv价值变化;
    [TIForecast rForecast:model];
    
    //8. IRT触发器;
    [TIForecast forecastIRT:model];
}

+(void) recognition:(TOFoModel*)foModel{
    //1. 数据准备
    AIFoNodeBase *curFo = [SMGUtils searchNode:foModel.content_p];
    OFTitleLog(@"行为化Fo", @"\n时序:%@->%@ 类型:(%@)",Fo2FStr(curFo),Mvp2Str(curFo.cmvNode_p),curFo.pointer.typeStr);
    
    
    //3. 对HNGL任务首帧执行前做评价;
    
    //4. MC反思: 回归tir反思,重新识别理性预测时序,预测价值; (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价)
    AIShortMatchModel *rtInModel = [theTC to_Rethink:foModel];
    
    //5. 生成子任务;
    [TIForecast forecastSubDemand:rtInModel];
    
    
    //TODOTOMORROW20211201: 反思子任务
    //1. 所有反思有子任务的,都形成子任务;
    //2. 子任务能解决便解决,解决不了的(也有可能是因为来不及,所以解决方案失败);
    //3. 无论子任务是否解决,都回来判综合评分pk,比如子任务不解决我也要继续父任务;
    
    
    
    
}

+(void) pRecognition:(AIFoNodeBase*)protoFo{
    //2. 取cmvNode
    AICMVNode *cmvNode = [SMGUtils searchNode:protoFo.cmvNode_p];
    if (!ISOK(cmvNode, AICMVNode.class)) {
        return;
    }
    
    //3. 学习
    [TIForecast feedbackLearning:protoFo];
    
    //4. tip反馈 & 生成p任务;
    [TIForecast pForecast:cmvNode];
}

@end
