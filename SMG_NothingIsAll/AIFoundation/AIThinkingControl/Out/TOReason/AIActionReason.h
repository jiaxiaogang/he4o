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
 */
@interface AIActionReason : AIThinkOutAction

//用于RDemand.Begin时调用;
-(void) convert2Out_Demand:(ReasonDemandModel*)demand;

@end
