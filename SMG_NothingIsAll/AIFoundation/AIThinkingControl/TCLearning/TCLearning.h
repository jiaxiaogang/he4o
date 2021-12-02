//
//  TCLearning.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCLearning : NSObject

+(void) pLearning:(AIFoNodeBase*)protoFo;
+(void) rLearning:(AIShortMatchModel*)model recognitionMaskFo:(AIFoNodeBase*)recognitionMaskFo;
+(void) subDemandLearning:(AIShortMatchModel*)model;

@end
