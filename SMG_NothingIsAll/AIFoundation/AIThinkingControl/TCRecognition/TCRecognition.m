//
//  TCRecognition.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCRecognition.h"

@implementation TCRecognition

/**
 *  MARK:--------------------瞬时时序识别--------------------
 *  @param model : 当前帧输入期短时记忆;
 *  @version
 *      20200414 - protoFo由瞬时proto概念组成,改成瞬时match概念组成 (本方法中,去掉proto概念层到match层的联想);
 *      20200717 - 换上新版partMatching_FoV2时序识别算法;
 *      20210119 - 支持预测-触发器和反向反馈类比 (22052-1&3);
 *      20210124 - In反省类比触发器,支持多时序识别matchFos (参考22073-todo3);
 *      20210413 - TIRFoFromShortMem的参数由matchAFo改为protoFo (参考23014-分析2);
 *      20210414 - 将TIRFo参数改为matchAlg有效则protoFo,否则matchAFo (参考23015);
 *      20210421 - 加强RFos的抽具象关联,对rFo与protoFo进行类比抽象;
 *      20210422 - 将absRFo收集到inModel中 (用于GL联想assFo时方便使用,参考23041-示图);
 *  @bug
 *      2020.11.10: 在21141训练第一步,发现外类比不执行BUG,因为传入无用的matchAlg参数判空return了 (参考21142);
 */
+(void) rRecognition:(AIShortMatchModel*)model{
    //1. 数据准备;
    NSArray*except_ps = @[model.protoFo.pointer,model.matchAFo.pointer];
    AIFoNodeBase *maskFo = ARRISOK(model.matchAlgs) ? model.protoFo : model.matchAFo;
    IFTitleLog(@"瞬时时序识别", @"\n%@:%@->%@",ARRISOK(model.matchAlgs) ? @"protoFo" : @"matchAFo",Fo2FStr(maskFo),Mvp2Str(maskFo.cmvNode_p));
    
    
    //TODOTOMORROW20211202: 将识别算法移过来----------------
    
    //2. 调用通用时序识别方法 (checkItemValid: 可考虑写个isBasedNode()判断,因protoAlg可里氏替换,目前仅支持后两层)
    [AIThinkInReason partMatching_FoV1Dot5:maskFo except_ps:except_ps decoratorInModel:model findCutIndex:^NSInteger(AIFoNodeBase *matchFo, NSInteger lastMatchIndex) {
        
        //3. 当fromTIM时,cutIndex=lastAssIndex;
        return lastMatchIndex;
    }];
    
    //5. 学习;
    [TCLearning rLearning:model recognitionMaskFo:maskFo];
}

/**
 *  MARK:--------------------反思--------------------
 *  @status
 *      1. 输出反思已废弃;
 *      2. 输入反思功能整合回正向识别中 (即由重组,来调用识别实现);
 */
+(void) reflectRecognition:(TOFoModel*)foModel{
    //1. 数据准备
    AIFoNodeBase *curFo = [SMGUtils searchNode:foModel.content_p];
    OFTitleLog(@"行为化Fo", @"\n时序:%@->%@ 类型:(%@)",Fo2FStr(curFo),Mvp2Str(curFo.cmvNode_p),curFo.pointer.typeStr);
    
    
    //3. 对HNGL任务首帧执行前做评价;
    
    //4. MC反思: 回归tir反思,重新识别理性预测时序,预测价值; (预测到鸡蛋变脏,或者cpu损坏) (理性预测影响评价即理性评价)
    AIShortMatchModel *rtInModel = [theTC to_Rethink:foModel];
    
    //5. 生成子任务;
    [TCLearning subDemandLearning:rtInModel];
    
    
    //TODOTOMORROW20211201: 反思子任务
    //1. 所有反思有子任务的,都形成子任务;
    //2. 子任务能解决便解决,解决不了的(也有可能是因为来不及,所以解决方案失败);
    //3. 无论子任务是否解决,都回来判综合评分pk,比如子任务不解决我也要继续父任务;
    
    
    
    
}

+(void) pRecognition:(AIFoNodeBase*)protoFo{
    //3. 学习
    [TCLearning pLearning:protoFo];
}

@end
