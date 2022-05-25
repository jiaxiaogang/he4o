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
 *  @param pFos     : List<AIMatchFoModel>
 *  @param inModel  : notnull
 *  @param baseFo   : 当前为子任务时,传入baseFo,非子任务传空即可;
 */
+(ReasonDemandModel*) newWithAlgsType:(NSString*)algsType pFos:(NSArray*)pFos inModel:(AIShortMatchModel*)inModel baseFo:(TOFoModel*)baseFo;


/**
 *  MARK:--------------------R-的预测时序们--------------------
 *  @类型 List<AIMatchFoModel>
 *  @version
 *      2022.05.18: 替换原单个mModel,改成pFos多个 (参考26042-TODO2);
 */
@property (strong, nonatomic) NSArray *pFos;

/**
 *  MARK:--------------------需求来源inModel--------------------
 *  @version
 *      2022.03.23: 弃用inModel,改用fromIden标识 (参考25184);
 */
//@property (strong, nonatomic) AIShortMatchModel *inModel;
@property (strong, nonatomic) NSString *fromIden;

/**
 *  MARK:--------------------触发了此任务的protoFo记录--------------------
 *  @desc 作用: 可用于Solution思考;
 */
@property (strong, nonatomic) AIKVPointer *protoFo;

@end
