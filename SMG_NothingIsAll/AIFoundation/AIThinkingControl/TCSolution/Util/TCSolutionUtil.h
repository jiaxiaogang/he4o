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


//MARK:===============================================================
//MARK:                     < 慢思考 >
//MARK:===============================================================
+(AISolutionModel*) hSolution_Slow:(HDemandModel *)hDemand except_ps:(NSArray*)except_ps;
+(AISolutionModel*) rSolution_Slow:(ReasonDemandModel *)demand except_ps:(NSArray*)except_ps;

/**
 *  MARK:--------------------条件满足时: 获取前段indexDic--------------------
 */
+(NSDictionary*) getFrontIndexDic:(AIFoNodeBase*)protoFo absFo:(AIFoNodeBase*)absFo absCutIndex:(NSInteger)absCutIndex;
@end
