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

/**
 *  MARK:--------------------输入mindValue--------------------
 *  所有值域,转换为0-10;(例如:hunger时0为不饿,10为非常饿)
 */
+(void) commitIMV:(MVType)type from:(NSInteger)from to:(NSInteger)to{
    //1. 生成imvModel
    ImvAlgsModelBase *imvModel = [[ImvAlgsModelBase alloc] init];
    imvModel.urgentValue = [self getAlgsUrgentValue:to];
    imvModel.targetType = [self getAlgsTargetType:type];
    imvModel.type = type;
    
    //2. 结果给Thinking
    [[AIThinkingControl shareInstance] commitInput:imvModel];
}

+(CGFloat) getAlgsUrgentValue:(CGFloat)to{
    return to * to;
}

+(AITargetType) getAlgsTargetType:(MVType)type{
    if (type == MVType_Hunger || type == MVType_Anxious) {
        return AITargetType_Down;
    }
    return AITargetType_Down;
}

@end
