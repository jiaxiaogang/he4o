//
//  AIImvAlgs.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIImvAlgs.h"
#import "ImvAlgsHungerModel.h"
#import "ImvAlgsModelBase.h"

@implementation AIImvAlgs

/**
 *  MARK:--------------------输入mindValue--------------------
 *  @param from | to : 值域,转换为0-10;(例如:hunger时表示电量,0为无电,10为满电);
 */
+(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to{
    //1. 生成imvModel
    if (type == MVType_Hunger) {
        ImvAlgsHungerModel *imvModel = [[ImvAlgsHungerModel alloc] init];
        imvModel.urgentTo = [self getHungerAlgsUrgentValue:to];
        CGFloat urgentFrom = [self getHungerAlgsUrgentValue:from];
        imvModel.delta = imvModel.urgentTo - urgentFrom;
        [theTC commitInput:imvModel];
    }else if(type == MVType_Anxious){
        
    }
}

+(CGFloat) getHungerAlgsUrgentValue:(CGFloat)to{
    to = MAX(0, MIN(10,to));
    return 100 - to * to;
}

@end
