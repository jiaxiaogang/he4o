//
//  TCForecast.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MARK:--------------------反省触发器--------------------
 */
@interface TCForecast : NSObject

+(void) forecast_Multi:(NSArray*)newRoots;
+(void) forecast_Single:(AIMatchFoModel*)item;

@end
