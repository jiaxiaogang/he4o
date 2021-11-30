//
//  TIForecast.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIForecast : NSObject

+(void) feedbackTIR:(AIShortMatchModel*)model;
+(void) foreastMv:(AIShortMatchModel*)model;
+(void) foreastIRT:(AIShortMatchModel*)model;

@end
