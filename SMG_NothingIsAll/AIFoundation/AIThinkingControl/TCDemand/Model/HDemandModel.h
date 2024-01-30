//
//  HDemandModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "DemandModel.h"

/**
 *  MARK:--------------------H任务模型--------------------
 *  @desc 用于概念ATHav任务;
 *  @version
 *      2021.12.05: 将alg目标字段废弃,因为取hDemand.base就是它,没必要单存一份;
 *      2021.12.05: 新增feedbackAlg字段,将实际feedbackTOR的存在此处,用于regroup时使用;
 *      2021.12.05: feedbackAlg废弃,用旧有base.feedbackAlg即可;
 */
@interface HDemandModel : DemandModel

+(HDemandModel*) newWithAlgModel:(TOAlgModel*)base;

/**
 *  MARK:--------------------H任务无计可施时调用--------------------
 */
-(void) setStatus2WithOut;

@end
