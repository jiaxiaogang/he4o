//
//  NVHeUtil.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/7/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "NVHeUtil.h"
#import "AINetIndex.h"
#import "AIKVPointer.h"

@implementation NVHeUtil

+(BOOL) isHeight:(CGFloat)height fromContent_ps:(NSArray*)fromContent_ps {
    for (AIKVPointer *p in ARRTOOK(fromContent_ps)) {
        if ([p.dataSource isEqualToString:@"sizeHeight"]) {
            if ([NUMTOOK([AINetIndex getData:p]) floatValue] == 5) {
                return true;
            }
        }
    }
    return false;
}

+(NSString*) getLightStrForValue:(AIKVPointer*)value_p{
    if (ISOK(value_p, AIKVPointer.class)) {
        if ([@"sizeWidth" isEqualToString:value_p.dataSource]) {
            return @"一";
        }else if ([@"sizeHeight" isEqualToString:value_p.dataSource]) {
            return @"|";
        }else if ([@"colorRed" isEqualToString:value_p.dataSource]) {
            return @"R";
        }else if ([@"colorBlue" isEqualToString:value_p.dataSource]) {
            return @"B";
        }else if ([@"colorGreen" isEqualToString:value_p.dataSource]) {
            return @"G";
        }else if ([@"radius" isEqualToString:value_p.dataSource]) {
            return @"角";
        }
    }
    return @"";
}

@end
