//
//  TCDemand.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCDemand : NSObject

+(void) rDemandFront:(AIShortMatchModel*)model;
+(void) rDemandBack:(AIShortMatchModel*)model;
+(void) pDemand:(AICMVNode*)cmvNode;
+(void) subDemand:(AIShortMatchModel*)rtInModel;
+(void) hDemand:(TOAlgModel*)algModel;    //H任务 (用来转移某概念的H任务);

@end
