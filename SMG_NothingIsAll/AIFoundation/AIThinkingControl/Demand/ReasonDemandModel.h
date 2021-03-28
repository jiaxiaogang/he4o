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
 *      2021.03.28: 允许作为子任务;
 */
@class AIShortMatchModel,TOFoModel,AIMatchFoModel;
@interface ReasonDemandModel : DemandModel

/**
 *  MARK:--------------------newWith--------------------
 *  @param mModel   : notnull
 *  @param inModel  : notnull
 *  @param baseFo   : 当前为子任务时,传入baseFo,非子任务传空即可;
 */
+(ReasonDemandModel*) newWithMModel:(AIMatchFoModel*)mModel inModel:(AIShortMatchModel*)inModel baseFo:(TOFoModel*)baseFo;

@property (strong, nonatomic) AIMatchFoModel *mModel;       //R-预测时序
@property (strong, nonatomic) AIShortMatchModel *inModel;   //需求来源inModel;
@property (strong, nonatomic) TOFoModel *baseFo;            //当前为子任务时,baseFo表示基于哪个时序的任务;

@end
