//
//  MindStrategy.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/6/7.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "MindStrategy.h"

@implementation MindStrategy

+(MindStrategyModel*) getModelWithMin:(NSInteger)min withMax:(NSInteger)max withOriValue:(NSInteger)oriValue withType:(MindType)type{
    MindStrategyModel *model = [[MindStrategyModel alloc] init];
    model.type = type;
    model.value = [self getValueWithMin:min withMax:max withOriValue:oriValue withType:type];
    return model;
}

+(MindStrategyModel*) getModelForDemandWithArr:(NSArray*)arr{
    MindStrategyModel *value = nil;
    if (ARRISOK(arr)) {
        for (MindStrategyModel *model in arr) {
            if (!value || model.value < value.value) {
                value = model;
            }
        }
    }
    return value;
}

/**
 *  MARK:--------------------private--------------------
 */
//判断mindType的方向;true是正向;false是反向;
+(BOOL) getIsForward:(MindType)type{
    if (type == MindType_Hunger || type == MindType_Curiosity) {
        return true;
    }else{
        return false;
    }
}

+(NSInteger) getValueWithMin:(NSInteger)min withMax:(NSInteger)max withOriValue:(NSInteger)oriValue withType:(MindType)type{
    BOOL isForward = [MindStrategy getIsForward:type];
    if (max > min) {
        //1,原始值范围检查;
        NSInteger checkValue = MIN(MAX(oriValue, min), max);
        //2,checkValue所在的值
        NSInteger value = 100 / (max - min) * (checkValue - min);
        //3,返回策略值
        if (isForward) {
            return value;
        }else{
            return 100 - value;
        }
    }else{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"ERROR!!!(MindStrategy)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
        }
        return isForward ? 100 : 0;
    }
}

@end


@implementation MindStrategyModel
@end
