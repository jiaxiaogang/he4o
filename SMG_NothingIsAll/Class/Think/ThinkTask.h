//
//  ThinkTask.h
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/7/22.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------需求 & 任务--------------------
 */
@interface ThinkTask : NSObject

@property (strong,nonatomic) AIMindValueModel *currentTask;
-(void) run;

@end
