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
+(void) out:(TOAlgModel*)algModel{
    //1. 无论是P-模式的Alg,还是R-中非S的Alg,都要走以下第1,第2,第3级流程;
    [theTC updateOperCount];
    if (algModel.content_p.isOut) {
        //2. 第1级: 本身即是isOut时,直接行为化返回;
        OFTitleLog(@"行为输出", @"\n%@",AlgP2FStr(algModel.content_p));
        //2. 输出前改为ActYes (避免重复决策当前demand) (isOut=true暂无需反省类比);
        algModel.status = TOModelStatus_ActYes;
        
        //2. 消耗活跃度并输出
        [theTC updateEnergy:-1.0f];
        
        //3. 输出_用旧有代码->输出后转给TCInput.rInput();
        [theTV updateFrame];
        BOOL invoked = [Output output_FromTC:algModel.content_p];
        NSLog(@"===执行%@",invoked ? @"success" : @"failure");
    }else{
        //8. notOut转jump;
        [TCInput hInput:algModel];
    }
}

@end
