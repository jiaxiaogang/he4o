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
+(AISolutionModel*) rSolution_Fast:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps;
+(AISolutionModel*) hSolution_Fast:(HDemandModel *)hDemand except_ps:(NSArray*)except_ps;

@end
