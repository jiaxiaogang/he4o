//
//  CortexAlgorithmsUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2023/3/13.
//  Copyright © 2023年 XiaoGang. All rights reserved.
//

#import "CortexAlgorithmsUtil.h"

@implementation CortexAlgorithmsUtil

/**
 *  MARK:--------------------返回首尾循环码的最大值--------------------
 *  @desc 值说明 (参考28174-todo2):
 *          1. 首尾相连的稀疏码最小值一般都为0;
 *          2. 因为最大值等于最小值,所以此处将最大值返回,以方便计算差值;
 *  @version
 *      2023.03.14: 飞行方向也是首尾循环码 (参考28174-todo2-另外);
 *  @result 首尾循环的返回最大值,如果不循环的值则返回0;
 */
+(double) maxOfLoopValue:(NSString*)at ds:(NSString*)ds {
    //1. 视觉方向有360个值;
    if ([@"AIVisionAlgs" isEqualToString:at] && [@"direction" isEqualToString:ds]) {
        return 360;
    } else if ([@"FLY_RDS" isEqualToString:at]) {
        return 1;
    }
    return 0;
}

@end
