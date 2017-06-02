//
//  Decision.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Decision.h"
#import "MindHeader.h"

@implementation Decision


/**
 *  MARK:--------------------Mind->Understand->Feel->Output--------------------
 */
-(void) commitWithMindNeedModelArr:(NSArray*)modelArr{
    NSLog(@"分析理解Mind需求,作出下步行为输出");
    //1,心情影响输出
    [[SMG sharedInstance].mindControl.mindAAA refreshDecisionByOutputTask:modelArr];
    //2,偏好影响输出
    [[SMG sharedInstance].mindControl.mindBBB refreshDecisionByOutputTask:modelArr];
    //3,生理需求影响输出^_^!!
    //[[SMG sharedInstance].mindControl.mindCCC refreshDecisionByOutputTask:modelArr];
}

/**
 *  MARK:--------------------Mind引擎的需求 分析 & 决策--------------------
 */
+(void) commitFromMindWithNeed:(id)need{
    NSLog(@"分析决策 Mind的需求 ");
}

@end
