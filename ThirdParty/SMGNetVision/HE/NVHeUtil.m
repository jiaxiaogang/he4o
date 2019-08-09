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

+(NSString*) getLightStr:(AIKVPointer*)node_p{
    if (ISOK(node_p, AIKVPointer.class)) {
        if ([kPN_VALUE isEqualToString:node_p.folderName]) {
            NSInteger value = [NUMTOOK([AINetIndex getData:node_p]) integerValue];
            if ([@"sizeWidth" isEqualToString:node_p.dataSource]) {
                return @"一";
            }else if ([@"sizeHeight" isEqualToString:node_p.dataSource]) {
                return @"|";
            }else if ([@"colorRed" isEqualToString:node_p.dataSource]) {
                return @"R";
            }else if ([@"colorBlue" isEqualToString:node_p.dataSource]) {
                return @"B";
            }else if ([@"colorGreen" isEqualToString:node_p.dataSource]) {
                return @"G";
            }else if ([@"radius" isEqualToString:node_p.dataSource]) {
                return @"角";
            }else if([EAT_RDS isEqualToString:node_p.dataSource]){
                return @"吃";
            }else if([FLY_RDS isEqualToString:node_p.dataSource]){
                return @"飞";
            }else if(value == cHav){
                return @"有";
            }else if(value == cNone){
                return @"无";
            }else if(value == cGreater){
                return @"大";
            }else if(value == cLess){
                return @"小";
            }
        }else if ([kPN_ALG_NODE isEqualToString:node_p.folderName] ||
                  [kPN_ALG_ABS_NODE isEqualToString:node_p.folderName]) {
            if (node_p.isOut) {
                return @"动";
            }
        }
    }
    return @"";
}

@end
