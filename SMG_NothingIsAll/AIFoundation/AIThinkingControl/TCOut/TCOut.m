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
 *      2021.12.26: 下标不急(弄巧成拙)评价,避免多余输出: 将代码前移到out输出前 (参考25031-10);
 */
+(TCResult*) run:(TOAlgModel*)algModel{
    //1. 无论是P-模式的Alg,还是R-中非S的Alg,都要走以下第1,第2,第3级流程;
    [theTC updateOperCount:kFILENAME];
    Debug();
    if (algModel.content_p.isOut) {
        //2. 第1级: 本身即是isOut时,直接行为化返回;
        NSString *fltLog1 = [NVHeUtil algIsKick:algModel.content_p] ? FltLog4YonBanYun(3) : @"";
        NSString *fltLog2 = FltLog4DefaultIf([NVHeUtil algIsFly:algModel.content_p], @"3");
        OFTitleLog(@"行为输出", @"\n%@%@%@",fltLog1,fltLog2,AlgP2FStr(algModel.content_p));
        //2. 输出前改为ActYes (避免重复决策当前demand) (isOut=true暂无需反省类比);
        algModel.status = TOModelStatus_ActYes;
        
        //2. 消耗活跃度并输出
        [theTC updateEnergyDelta:-1.0f];
        
        //3. 输出_用旧有代码->输出后转给TCInput.rInput();
        dispatch_async(dispatch_get_main_queue(), ^{//30083回同步
            [theTV updateFrame];
        });
        DebugE();
        return [Output output_FromTC:algModel.content_p];
    }else{
        //8. notOut转jump;
        DebugE();
        [TCInput hInput:algModel];
        return [[[TCResult new:true] mkMsg:@"out 此帧需要HDemand来完成,已转为h任务"] mkStep:41];
    }
}

@end
