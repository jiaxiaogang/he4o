//
//  AIThinkOut.h
//  SMG_NothingIsAll
//
//  Created by jia on 2019/1/24.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DemandModel;
@protocol AIThinkOutDelegate <NSObject>

-(DemandModel*) aiThinkOut_GetCurrentDemand;            //获取当前需求;
-(BOOL) aiThinkOut_EnergyValid;                         //能量值是否>0;
-(void) aiThinkOut_UpdateEnergy:(NSInteger)delta;       //更新思维能量值;

@end

//MARK:===============================================================
//MARK:                     < dataOut (回归具象之旅) >
//MARK:
//MARK: 说明: 在helix内核的决策中,helix经历了5个关键节点;
//MARK:     1. mv需求(input或其它状态触发)
//MARK:     2. mv经验查找(从网络索引找)
//MARK:     3. 经验模型(从网络关联找)
//MARK:     4. 执行方案(从网络具体经历单位找(时序等))
//MARK:     5. 正式输出(这里会用到小脑,helix未实现小脑网络);
//MARK: 总结: 这整个过程算是helix的具象之旅,也是output循环的几个关键节点
//MARK:===============================================================
@interface AIThinkOut : NSObject

@property (weak, nonatomic) id<AIThinkOutDelegate> delegate;

/**
 *  MARK:--------------------dataLoop联想(每次循环的检查执行点)--------------------
 *  注:assExp联想经验(饿了找瓜)(递归)
 *  注:loopAssExp中本身已经是内心活动联想到的mv
 *  1. 有条件(energy>0)
 *  2. 有尝(energy-1)
 *  3. 不指定model (从cmvCache取)
 *  4. 每一轮循环不仅是想下一个singleMvPort;也有可能在当前port上,进行二次思考;
 *  5. 从expCache下,根据可行性,选定一个解决方案;
 *  6. 有需求时,找出expModel,尝试决策并解决;
 *
 */
-(void) dataOut;


@end
