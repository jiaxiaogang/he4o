//
//  TCDemand.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCDemand : NSObject

+(void) rDemand:(AIShortMatchModel*)model;  //R任务
+(void) pDemand:(AICMVNode*)cmvNode;        //P任务
+(void) subDemand:(AIShortMatchModel*)rtInModel foModel:(TOFoModel*)foModel;
+(void) feedbackDemand:(AIShortMatchModel*)model;
+(void) hDemand:(TOAlgModel*)algModel;      //H任务 (用来转移某概念的H任务);

@end
