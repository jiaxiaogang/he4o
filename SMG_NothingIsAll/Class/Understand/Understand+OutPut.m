//
//  Understand+OutPut.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "Understand+OutPut.h"
#import "MindHeader.h"


/**
 *  MARK:--------------------输出理解--------------------
 *
 *       (产生需求)            (产生可表达需求)      (生成表达方式及内容)
 *  Mind---------->Understand--------------->Feel------------------>Output
 *
 *  1,理解分析需求
 *  2,任务队列(本地化)
 *
 *
 */
@implementation Understand (OUTPUT)

/**
 *  MARK:--------------------Mind->Understand->Feel->Output--------------------
 */
-(void) commitWithMindDemandModelArr:(NSArray*)modelArr{
    NSLog(@"分析理解Mind需求,作出下步行为输出");
    //1,心情影响输出
    [[SMG sharedInstance].mindControl.mindAAA refreshDecisionByOutputTask:modelArr];
    //2,偏好影响输出
    [[SMG sharedInstance].mindControl.mindBBB refreshDecisionByOutputTask:modelArr];
    //3,生理需求影响输出^_^!!
    //[[SMG sharedInstance].mindControl.mindCCC refreshDecisionByOutputTask:modelArr];
}

@end
