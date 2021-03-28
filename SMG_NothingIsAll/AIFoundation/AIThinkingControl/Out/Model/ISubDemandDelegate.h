//
//  ISubDemandDelegate.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/3/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------子任务接口--------------------
 *  @implement
 *      1. TOFoModel    : 用于挂载子任务们 (比如反思到此举可能有三害,那么就有3个子任务);
 */
@protocol ISubDemandDelegate <NSObject>

-(NSMutableArray*) subDemands;

@end
