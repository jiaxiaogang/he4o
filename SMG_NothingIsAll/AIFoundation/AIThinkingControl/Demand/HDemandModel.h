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
 */
@interface HDemandModel : DemandModel

+(HDemandModel*) newWithAlgModel:(TOAlgModel*)algModel;

@property (strong, nonatomic) TOAlgModel *algModel;

@end
