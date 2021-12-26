//
//  TCOut.m
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "TCOut.h"

@implementation TCOut

/**
 *  MARK:--------------------新螺旋架构out--------------------
 *  @version
 *      2021.11.26: 最终未输出时,转给TCInput.jump();
 *      2021.12.26: H类型达到目标帧时,不会调用out,而是在action()中直接判断为末帧,并调用hActYes了 (参考25031-9);
 */
+(void) out:(TOAlgModel*)algModel{
    //1. 无论是P-模式的Alg,还是R-中非S的Alg,都要走以下第1,第2,第3级流程;
    if (algModel.content_p.isOut) {
        //2. 第1级: 本身即是isOut时,直接行为化返回;
        OFTitleLog(@"行为输出", @"\n%@",AlgP2FStr(algModel.content_p));
        //2. 输出前改为ActYes (避免重复决策当前demand) (isOut=true暂无需反省类比);
        algModel.status = TOModelStatus_ActYes;
        
        //2. 消耗活跃度并输出
        [theTC updateEnergy:-1.0f];
        
        //3. 输出_用旧有代码->输出后转给TCInput.rInput();
        BOOL invoked = [Output output_FromTC:algModel.content_p];
        NSLog(@"===执行%@",invoked ? @"success" : @"failure");
    }else{
        //@desc: 下标不急评价说明: R模式_Hav首先是为了避免forecastAlg,其次才是为了达成curFo解决方案 (参考22153);
        //5. 下标不急(弄巧成拙)评价_数据准备 (参考24171-12);
        //TODO: 考虑改成,取base最近的一个R任务;
        TOFoModel *solutionFo = (TOFoModel*)algModel.baseOrGroup;
        ReasonDemandModel *baseDemand = (ReasonDemandModel*)solutionFo.baseOrGroup;
        
        //6. 只有R类型,才参与下标不急评价;
        if(ISOK(baseDemand, ReasonDemandModel.class)){
            BOOL arsTime = [AIScore ARS_Time:solutionFo demand:baseDemand];
            if (!arsTime) {
                //7. 评价不通过,则直接ActYes,等待其自然出现 (参考22153-A2);
                NSLog(@"==> arsTime弄巧成拙评价,子弹再飞一会儿");
                algModel.status = TOModelStatus_ActYes;
                [TCActYes arsTimeActYes:algModel];
                return;
            }
        }
        
        //8. notOut转jump;
        [TCInput jump:algModel];
    }
}

@end
