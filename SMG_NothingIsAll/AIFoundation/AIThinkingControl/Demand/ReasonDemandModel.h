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
 *  @version
 *      2021.01.27: 将inModel改为单条mModel和protoFo;
 */
@class AIShortMatchModel,TOFoModel,AIMatchFoModel;
@interface ReasonDemandModel : DemandModel

/**
 *  MARK:--------------------newWith--------------------
 *  @param mModel   : notnull
 *  @param inModel  : notnull
 */
+(ReasonDemandModel*) newWithMModel:(AIMatchFoModel*)mModel inModel:(AIShortMatchModel*)inModel;

@property (strong, nonatomic) AIMatchFoModel *mModel;       //R-预测时序
@property (strong, nonatomic) AIShortMatchModel *inModel;   //需求来源inModel;

@end
