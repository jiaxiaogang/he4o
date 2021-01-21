//
//  ReasonDemandModel.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/1/21.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import "DemandModel.h"

/**
 *  MARK:--------------------理性需求模型--------------------
 *  @desc 阻止inModel.matchFo继续发生;
 *  @todo
 *      2021.01.21: algsType,urgentTo,delta属性值,可以改为cutIndex*cmvScore实时计算返回 (暂时不用);
 */
@class AIShortMatchModel,TOFoModel;
@interface ReasonDemandModel : DemandModel

@property (weak, nonatomic) AIShortMatchModel *inModel;    //预测R-时序

@end
