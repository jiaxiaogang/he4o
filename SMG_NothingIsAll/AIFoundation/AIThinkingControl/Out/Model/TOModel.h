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
 *  @desc   1. 不应期会上报给上一级except_ps (或许由TOModelStatus来替代此功能);
 *          2.
 */
@interface TOModel : TOModelBase

@property (assign, nonatomic) NSInteger actionIndex;                //当前正在行为化的下标;
@property (strong, nonatomic) NSMutableDictionary *itemSubModels;   //每个下标,对应的subModels字典;
@property (strong, nonatomic) TOModelBase *activateSubModel;        //当前正在激活中的subModel;


/**
 *  MARK:--------------------当前model的状态--------------------
 */
@property (assign, nonatomic) TOModelStatus status;

@end
