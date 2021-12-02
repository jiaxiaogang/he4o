//
//  TIForecast.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------反馈 & 预测--------------------
 */
@interface TIForecast : NSObject

+(void) rForecastFront:(AIShortMatchModel*)model;
+(void) rForecastBack:(AIShortMatchModel*)model pushOldDemand:(BOOL)pushOldDemand;
+(void) pForecast:(AICMVNode*)cmvNode;
+(void) forecastIRT:(AIShortMatchModel*)model pushOldDemand:(BOOL)pushOldDemand;
+(void) forecastSubDemand:(AIShortMatchModel*)model;

@end
