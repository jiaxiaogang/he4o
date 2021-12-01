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

+(void) feedbackTIR:(AIShortMatchModel*)model;
+(BOOL) feedbackTOR:(AIShortMatchModel*)model;
+(void) feedbackTIP:(AICMVNode*)cmvNode;
+(void) feedbackTOP:(AICMVNode*)cmvNode;

+(void) rForecast:(AIShortMatchModel*)model;
+(void) pForecast:(AICMVNode*)cmvNode;
+(void) forecastIRT:(AIShortMatchModel*)model;
+(void) forecastSubDemand:(AIShortMatchModel*)model;

@end
