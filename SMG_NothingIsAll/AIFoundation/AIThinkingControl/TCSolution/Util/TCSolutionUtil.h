//
//  TCSolutionUtil.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/6/5.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HDemandModel,ReasonDemandModel;
@interface TCSolutionUtil : NSObject

//MARK:===============================================================
//MARK:                     < 求解 >
//MARK:===============================================================
+(TOFoModel*) hSolutionV2:(HDemandModel *)demand;
+(TOFoModel*) debugHSolution:(HDemandModel *)demand;
+(TOFoModel*) rSolution:(ReasonDemandModel *)demand;

/**
 *  MARK:--------------------Cansets实时竞争--------------------
 */
+(TOFoModel*) realTimeRankCansets:(DemandModel *)demand zonHeScoreBlock:(double(^)(TOFoModel *obj))zonHeScoreBlock;

/**
 *  MARK:--------------------获取aleardayCount--------------------
 */
+(NSInteger) getRAleardayCount:(ReasonDemandModel*)rDemand pFo:(AIMatchFoModel*)pFo;

/**
 *  MARK:--------------------更新状态besting和bested (参考31073-TODO2d)--------------------
 */
+(void) updateCansetStatus:(TOFoModel*)bestCanset demand:(DemandModel*)demand;

@end
