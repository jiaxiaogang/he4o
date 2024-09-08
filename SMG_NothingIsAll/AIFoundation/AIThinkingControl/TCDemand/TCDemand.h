//
//  TCDemand.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/11/28.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCDemand : NSObject

+(NSArray*) rDemand:(AIShortMatchModel*)model protoFo:(AIFoNodeBase*)protoFo;//R任务
+(void) pDemand:(AICMVNodeBase*)cmvNode;        //P任务
+(void) subDemand:(AIShortMatchModel*)model foModel:(TOFoModel*)foModel;   //反思识别形成子任务;
+(void) hDemand:(TOAlgModel*)algModel;      //H任务 (用来转移某概念的H任务);

@end
