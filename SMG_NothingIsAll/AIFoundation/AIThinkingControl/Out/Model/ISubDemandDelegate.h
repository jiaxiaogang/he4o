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
 *      1. TOFoModel    : self是fo时,subDemands中放着R子任务subRDemands (比如反思到此举可能有三害,那么就有3个子任务);
 *      2. TOAlgModel   : self是alg时,subDemands中放着一条子H任务subHDemand (alg下只有一个HDemand);
 */
@protocol ISubDemandDelegate <NSObject>

-(NSMutableArray*) subDemands;

@end
