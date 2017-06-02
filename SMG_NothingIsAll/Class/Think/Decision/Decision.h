//
//  Decision.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/27.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------输出_(Decision决策)--------------------
 *
 *       (产生需求)            (产生可表达需求)      (生成表达方式及内容)
 *  Mind---------->Understand--------------->Feel------------------>Output
 *
 *  1,理解分析需求
 *  2,任务队列(本地化)
 *
 *  1,用于分析Mind的需求;
 *  2,根据数据分析决策;
 *  3,定制输出方式;
 *
 *
 */
@interface Decision : NSObject


-(void) commitWithMindNeedModelArr:(NSArray*)modelArr;

/**
 *  MARK:--------------------Mind引擎的需求 分析 & 决策--------------------
 */
+(void) commitFromMindWithNeed:(id)need;

@end
