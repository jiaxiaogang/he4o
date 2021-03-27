//
//  ISubDemandDelegate.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/3/27.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------子任务接口--------------------
 *  @version
 *      2021.03.27: 支持反思子任务;
 */
@protocol ISubDemandDelegate <NSObject>

-(NSMutableArray*) subDemands;

@end
