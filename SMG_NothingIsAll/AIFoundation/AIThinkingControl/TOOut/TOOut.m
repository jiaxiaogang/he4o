//
//  TOOut.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TOOut.h"

@implementation TOOut

/**
 *  MARK:--------------------入口--------------------
 */
+(void) out:(TOAlgModel*)algModel{
    //1. 无论是P-模式的Alg,还是R-中非S的Alg,都要走以下第1,第2,第3级流程;
    //1. 第0级: 本身即是cHav节点,不用行为化,即成功 (但不用递归,等外循环返回行为结果);
    if ([TOUtils isHNGL_toModel:algModel]) {
        
        //TODOTOMORROW20211126: actYes转feedback;
        algModel.status = TOModelStatus_ActYes;//只需要等
        [self actYes:algModel];
    }else if (algModel.content_p.isOut) {
        
        //TODOTOMORROW20211126: isOut转input;
        //2. 第1级: 本身即是isOut时,直接行为化返回;
        OFTitleLog(@"行为输出", @"\n%@",AlgP2FStr(algModel.content_p));
        //2. 输出前改为ActYes (避免重复决策当前demand) (isOut=true暂无需反省类比);
        algModel.status = TOModelStatus_ActYes;
        
        //2. 消耗活跃度并输出
        [theTC updateEnergy:-1.0f];
        [self output:algModel];
    }else{
        
        //TODOTOMORROW20211125: dsFo废弃
        //1. 此处dsFo已废弃,但arsTime评价还是有必要的,看看迭代下支持新架构;
        //2. 做arsTime评价: (判断solutionFo.alg在demand.fo里是否有抽具象关联);
        //  a. 失败时,转为actYes状态;
        //  b. 通过时,转至chav();
        
        
        //R-模式理性静默成功迭代: R-模式_Hav首先是为了避免forecastAlg,其次才是为了达成curFo解决方案 (参考22153);
        //1. 判断当前是R-模式,则进行ARS_Time评价;
        
        ReasonDemandModel *rDemand = (ReasonDemandModel*)algModel.baseOrGroup.baseOrGroup;//改为取最近R任务rDemand,而不管取几个base.base.base...;
        TOFoModel *dsFo = (TOFoModel*)algModel.baseOrGroup;
        BOOL arsTime = [AIScore ARS_Time:dsFo demand:rDemand];
        if (!arsTime) {
            //2. 评价不通过,则直接ActYes,等待其自然出现 (参考22153-A2);
            NSLog(@"==> arsTime弄巧成拙评价,子弹再飞一会儿");
            algModel.status = TOModelStatus_ActYes;
            [self actYes:algModel];
            return;
        }
        
        //TODOTOMORROW20211126: notOut转jump;
        [self chav:algModel];
    }
}

//MARK:===============================================================
//MARK:                     < 出口 (三个) >
//MARK:===============================================================
+(void) chav:(TOAlgModel*)algModel{
    [TIInput jump:algModel];
}

+(void) actYes:(TOAlgModel*)algModel{
    //TODOTOMORROW20211201: 初始化触发器等 (从旧有actYes处复制代码过来用);-------------
    //[self.delegate toAction_SubModelActYes:algModel];
    
    
    
    
    
    
}

+(void) output:(TOAlgModel*)algModel{
    //TODOTOMORROW20211128: 输出,用旧有代码;
    //[self.delegate toAction_Output:@[algModel.content_p]];
}
+(void) rActYes:(TOFoModel*)foModel{
    //fo执行完成时,actYes;
}

@end
