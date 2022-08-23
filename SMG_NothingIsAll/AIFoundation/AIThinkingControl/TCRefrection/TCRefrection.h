//
//  TCRefrection.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/8/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AISolutionModel,DemandModel;
@interface TCRefrection : NSObject

+(BOOL) refrection:(AISolutionModel*)checkCanset cansets:(NSArray*)cansets demand:(DemandModel*)demand;

@end
