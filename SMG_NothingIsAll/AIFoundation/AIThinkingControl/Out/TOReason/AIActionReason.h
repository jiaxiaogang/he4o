//
//  AIActionReason.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/11.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "AIThinkOutAction.h"

/**
 *  MARK:--------------------R行为化--------------------
 *  @version
 *      2021.11.11: 独立RAction (参考24128);
 *      2021.11.18: 迭代R决策模式的模型架构 (参考24147);
 *      2021.11.25: 由宏微架构,改为功能架构,即以单轮循环各功能流程组成 (参考24154 & 24155);
 */
@interface AIActionReason : AIThinkOutAction

//用于RDemand.Begin时调用;
-(void) convert2Out_Demand:(ReasonDemandModel*)demand;

@end
