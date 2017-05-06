//
//  Understand+OutPut.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/5/6.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Understand.h"

/**
 *  MARK:--------------------输出_(Decision决策)--------------------
 *
 *       (产生需求)            (产生可表达需求)      (生成表达方式及内容)
 *  Mind---------->Understand--------------->Feel------------------>Output
 *
 *  1,理解分析需求
 *  2,任务队列(本地化)
 *
 *
 */
@interface Understand (OUTPUT)

/**
 *  MARK:--------------------Mind->Understand->Feel->Output--------------------
 */
-(void) commitWithMindDemandModelArr:(NSArray*)modelArr;

@end
