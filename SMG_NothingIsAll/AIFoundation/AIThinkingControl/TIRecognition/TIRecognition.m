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
    [TIForecast foreastMv:model];
    
    //8. IRT触发器;
    [TIForecast foreastIRT:model];
}
+(void) recognition:(TOFoModel*)foModel{
    //1. 数据准备
    AIFoNodeBase *curFo = [SMGUtils searchNode:foModel.content_p];
    OFTitleLog(@"行为化Fo", @"\n时序:%@->%@ 类型:(%@)",Fo2FStr(curFo),Mvp2Str(curFo.cmvNode_p),curFo.pointer.typeStr);
    
    
    //3. 对HNGL任务首帧执行前做评价;
    
    //4. MC反思: 回归tir反思,重新识别理性预测时序,预测价值; (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价)
    AIShortMatchModel *rtInModel = [theTC to_Rethink:foModel];
    
    
}

@end
