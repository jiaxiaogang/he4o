//
//  AIImvAlgs.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIImvAlgs.h"
#import "ImvAlgsHungerModel.h"
#import "AIThinkingControl.h"
#import "ImvAlgsModelBase.h"

@implementation AIImvAlgs

+(void) commitInputIMV:(IMVType)type value:(NSInteger)value{
    if (type == IMVType_Hunger) {
        ImvAlgsHungerModel *model = [[ImvAlgsHungerModel alloc] init];
        model.urgentValue = [self getAlgsUrgentValue:value];
        model.targetType = [self getAlgsTargetType:model.urgentValue];
        
        //1. 结果给Thinking
        [[AIThinkingControl shareInstance] inputByShallow:model];
    }
}

+(CGFloat) getAlgsUrgentValue:(CGFloat)inputValue{
    CGFloat algsValue = inputValue * inputValue;
    if (inputValue < 0) {
        algsValue = -algsValue;
    }
    return algsValue;
}

+(AITargetType) getAlgsTargetType:(CGFloat)urgentValue{
    if (urgentValue < 0) {
        return AITargetType_Up;
    }else if(urgentValue > 0) {
        return AITargetType_Down;
    }else{
        return AITargetType_None;
    }
}

@end
