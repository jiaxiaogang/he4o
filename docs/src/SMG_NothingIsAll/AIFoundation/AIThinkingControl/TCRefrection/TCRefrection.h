//
//  TCRefrection.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/8/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AICansetModel,DemandModel;
@interface TCRefrection : NSObject

+(BOOL) refrection:(AICansetModel*)checkCanset demand:(DemandModel*)demand;
+(BOOL) actionRefrection:(TOFoModel*)baseFoModel;

@end
