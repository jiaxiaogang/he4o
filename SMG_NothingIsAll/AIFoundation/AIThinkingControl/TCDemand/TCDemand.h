//
//  TCDemand.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCDemand : NSObject

+(NSArray*) rDemand:(AIShortMatchModel*)model;//R任务
+(void) pDemand:(AICMVNode*)cmvNode;        //P任务
+(void) feedbackDemand:(AIShortMatchModel*)model foModel:(TOFoModel*)foModel;   //反馈R子任务;
+(void) hDemand:(TOAlgModel*)algModel;      //H任务 (用来转移某概念的H任务);

@end
