//
//  AICustomAlgs.m
//  SMG_NothingIsAll
//
//  Created by jia on 2018/2/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AICustomAlgs.h"
#import "CustomAlgsChargeModel.h"
#import "AIThinkingControl.h"

@implementation AICustomAlgs

+(void) commitCustom:(CustomInputType)type value:(NSInteger)value{
    if (type == CustomInputType_Charge) {
        CustomAlgsChargeModel *model = [[CustomAlgsChargeModel alloc] init];
        model.value = value;
        [theTC commitInput:model];
    }
}

@end
