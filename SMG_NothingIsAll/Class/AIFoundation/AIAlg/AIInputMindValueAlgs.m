//
//  AIInputMindValueAlgs.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIInputMindValueAlgs.h"
#import "AIInputMindValue.h"
#import "AIThinkingControl.h"

@implementation AIInputMindValueAlgs

+(void) commitInput:(AIInputMindValue*)model{
    if (ISOK(model, AIInputMindValue.class)) {
        //1. 结果给Thinking
        [[AIThinkingControl shareInstance] activityByShallow:model];
    }
}

@end
