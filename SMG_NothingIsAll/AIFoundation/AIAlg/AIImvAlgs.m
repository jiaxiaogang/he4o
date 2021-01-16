//
//  AIImvAlgs.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/12/21.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AIImvAlgs.h"
#import "ImvAlgsHungerModel.h"
#import "ImvAlgsHurtModel.h"

@implementation AIImvAlgs

/**
 *  MARK:--------------------输入mindValue--------------------
 *  @param from | to : 值域,转换为0-10;(例如:hunger时表示饥饿度,10为无电非常饿,0为满电不饿);
 */
+(void) commitIMV:(MVType)type from:(CGFloat)from to:(CGFloat)to{
    //1. 生成imvModel
    if (type == MVType_Hunger) {
        ImvAlgsHungerModel *imvModel = [[ImvAlgsHungerModel alloc] init];
        imvModel.urgentTo = [self getSameMvUrgentValue:to];//36
        CGFloat urgentFrom = [self getSameMvUrgentValue:from];//25
        imvModel.delta = urgentFrom - imvModel.urgentTo;    //更饿为负;
        [theTC commitInput:imvModel];
    }else if(type == MVType_Anxious){
        
    }else if(type == MVType_Hurt){
        ImvAlgsHurtModel *imvModel = [[ImvAlgsHurtModel alloc] init];
        imvModel.urgentTo = [self getSameMvUrgentValue:to];
        CGFloat urgentFrom = [self getSameMvUrgentValue:from];
        imvModel.delta = imvModel.urgentTo - urgentFrom;    //更痛为负
        [theTC commitInput:imvModel];
    }
}

/**
 *  MARK:--------------------同向迫切度--------------------
 *  @desc 指迫切度与value在同向上,比如更饿,越饿迫切度越高;
 *  @status 目前,饥饿感和痛感都是采用了此种;
 */
+(CGFloat) getSameMvUrgentValue:(CGFloat)to{
    to = MAX(0, MIN(10,to));
    return to * to;
}

/**
 *  MARK:--------------------反向迫切度--------------------
 *  @desc 指迫切度与valud在反向上,比如更饱,越饱迫切度越低;
 *  @status 目前,饥饿感和痛感都是采用了同向迫切度,所以此处未被调用;
 */
+(CGFloat) getDiffMvUrgentValue:(CGFloat)to{
    to = MAX(0, MIN(10,to));
    return 100 - to * to;
}

@end
