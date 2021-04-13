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

/**
 *  MARK:--------------------dataLoop联想(每次循环的检查执行点)--------------------
 *  注:assExp联想经验(饿了找瓜)(递归)
 *  注:loopAssExp中本身已经是内心活动联想到的mv
 *  1. 有条件(energy>0)
 *  2. 有尝(energy-1)
 *  3. 不指定model (从cmvCache取)
 *  4. 每一轮循环不仅是想下一个singleMvPort;也有可能在当前port上,进行二次思考;
 *  5. 从expCache下,根据可行性,选定一个解决方案;
 *  6. 有需求时,找出outMvModel,尝试决策并解决;
 *
 *  框架: index -> mvNode -> foNode -> algNode -> action
 *  注:
 *  1. return           : 决策思维中止;
 *  2. [self dataOut]   : 递归再跑
 *
 */
-(void) dataOut;

@end
