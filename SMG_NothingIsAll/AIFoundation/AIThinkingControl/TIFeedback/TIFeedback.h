//
//  TIFeedback.h
//  SMG_NothingIsAll
//
//  Created by jia on 2021/12/2.
//  Copyright © 2021年 XiaoGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIFeedback : NSObject

+(void) feedbackTIR:(AIShortMatchModel*)model;
+(void) feedbackTOR:(AIShortMatchModel*)model;
+(void) feedbackTIP:(AICMVNode*)cmvNode;
+(void) feedbackTOP:(AICMVNode*)cmvNode;
+(void) feedbackSubDemand:(AIShortMatchModel*)model;

@end
