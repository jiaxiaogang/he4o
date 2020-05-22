//
//  TOModel.h
//  SMG_NothingIsAll
//
//  Created by air on 2020/5/22.
//  Copyright © 2020年 XiaoGang. All rights reserved.
//

#import "TOModelBase.h"

/**
 *  MARK:--------------------决策模型_时序--------------------
 */
@interface TOModel : TOModelBase

@property (assign, nonatomic) NSInteger actionIndex;                //当前正在行为化的下标;
@property (strong, nonatomic) NSMutableDictionary *itemSubModels;   //每个下标,对应的subModels字典;
@property (strong, nonatomic) TOModelBase *activateSubModel;        //当前正在激活中的subModel;
@property (assign, nonatomic) NSInteger status;                     //1.acting 2.failure 3.success

@end
