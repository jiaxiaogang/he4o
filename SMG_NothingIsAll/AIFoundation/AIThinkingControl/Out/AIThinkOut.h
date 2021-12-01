//
//  AIThinkOut.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/31.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIShortMatchModel,AIThinkOutPercept,AIThinkOutReason;
@interface AIThinkOut : NSObject

@property (strong, nonatomic) AIThinkOutPercept *tOP;       //感性决策
@property (strong, nonatomic) AIThinkOutReason *tOR;        //理性决策

@end
