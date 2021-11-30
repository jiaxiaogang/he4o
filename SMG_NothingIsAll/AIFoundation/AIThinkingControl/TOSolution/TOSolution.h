//
//  TOSolution.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOSolution : NSObject

+(void) solution;
+(void) rSolution:(ReasonDemandModel*)demand;
+(void) hSolution:(HDemandModel*)hDemand;

@end
