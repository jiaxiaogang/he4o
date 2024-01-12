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
//MARK:                     < 快思考 >
//MARK:===============================================================
+(AICansetModel*) rSolution_Fast:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps;
+(AICansetModel*) hSolution_Fast:(HDemandModel *)hDemand except_ps:(NSArray*)except_ps;


//MARK:===============================================================
//MARK:                     < 慢思考 >
//MARK:===============================================================
+(AICansetModel*) hSolution_SlowV2:(HDemandModel *)demand except_ps:(NSArray*)except_ps;
+(AICansetModel*) hSolution_SlowV4:(HDemandModel *)demand except_ps:(NSArray*)except_ps;
+(AICansetModel*) rSolution_Slow:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps;

/**
 *  MARK:--------------------获取aleardayCount--------------------
 */
+(NSInteger) getRAleardayCount:(ReasonDemandModel*)rDemand pFo:(AIMatchFoModel*)pFo;

@end
