//
//  TCRefrection.h
//  SMG_NothingIsAll
//
//  Created by jia on 2022/8/23.
//  Copyright © 2022年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TOFoModel,DemandModel;
@interface TCRefrection : NSObject

+(BOOL) refrection:(TOFoModel*)checkCanset demand:(DemandModel*)demand debugMode:(BOOL)debugMode;
+(BOOL) actionRefrection:(TOFoModel*)baseFoModel;

@end
