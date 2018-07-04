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
+(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to{
    //1. 生成imvModel
    ImvAlgsModelBase *imvModel = [[ImvAlgsModelBase alloc] init];
    imvModel.urgentFrom = [self getAlgsUrgentValue:from];
    imvModel.urgentTo = [self getAlgsUrgentValue:to];
    imvModel.type = type;
    
    //2. 结果给Thinking
    [[AIThinkingControl shareInstance] commitInput:imvModel];
}

+(CGFloat) getAlgsUrgentValue:(CGFloat)to{
    return to * to;
}

@end
