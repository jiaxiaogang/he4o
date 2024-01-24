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
//MARK:                     < 思考 >
//MARK:===============================================================
+(TOFoModel*) hSolutionV2:(HDemandModel *)demand except_ps:(NSArray*)except_ps;
+(TOFoModel*) hSolutionV4:(HDemandModel *)demand except_ps:(NSArray*)except_ps;
+(TOFoModel*) rSolution:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps;

/**
 *  MARK:--------------------获取aleardayCount--------------------
 */
+(NSInteger) getRAleardayCount:(ReasonDemandModel*)rDemand pFo:(AIMatchFoModel*)pFo;

/**
 *  MARK:--------------------更新状态besting和bested (参考31073-TODO2d)--------------------
 */
+(void) updateCansetStatus:(TOFoModel*)bestCanset demand:(DemandModel*)demand;

@end
