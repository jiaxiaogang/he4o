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
#import "AIAlgNodeBase.h"

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
        if ([self isValue:node_p]) {
            return [self getLightStr_ValueP:node_p];
        }else if ([self isAlg:node_p]) {
            AIAlgNodeBase *algNode = [SMGUtils searchNode:node_p];
            if (algNode && algNode.content_ps.count == 1) {
                AIKVPointer *value_p = algNode.content_ps[0];
                return [self getLightStr_ValueP:value_p];
            }else if (node_p.isOut) {
                return @"动";
            }
        }else if([self isFo:node_p]){
            AIFoNodeBase *foNode = [SMGUtils searchNode:node_p];
            if (foNode) {
                AIAlgNodeBase *lastAlgNode = [SMGUtils searchNode:ARR_INDEX(foNode.content_ps, foNode.content_ps.count - 1)];
                if (lastAlgNode && lastAlgNode.content_ps.count == 1) {
                    return [self getLightStr_ValueP:lastAlgNode.content_ps[0]];
                }
            }
        }
    }
    return @"";
}

//获取value_p的light描述;
+(NSString*) getLightStr_ValueP:(AIKVPointer*)value_p{
    NSInteger value = [NUMTOOK([AINetIndex getData:value_p]) integerValue];
    NSString *valueStr = [self getLightStr_Value:value];
    if ([@"sizeWidth" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"宽%@",valueStr);
    }else if ([@"sizeHeight" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"高%@",valueStr);
    }else if ([@"colorRed" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"R%@",valueStr);
    }else if ([@"colorBlue" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"B%@",valueStr);
    }else if ([@"colorGreen" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"G%@",valueStr);
    }else if ([@"radius" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"形状%@",valueStr);
    }else if ([@"direction" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"方向%@",valueStr);
    }else if ([@"distance" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"距离%@",valueStr);
    }else if ([@"speed" isEqualToString:value_p.dataSource]) {
        return STRFORMAT(@"速度%@",valueStr);
    }else if([EAT_RDS isEqualToString:value_p.algsType]){
        return STRFORMAT(@"吃%@",valueStr);
    }else if([FLY_RDS isEqualToString:value_p.algsType]){
        return STRFORMAT(@"飞%@",valueStr);
    }
    return valueStr;
}

//获取value的light描述;
+(NSString*) getLightStr_Value:(NSInteger)value{
    if(value == cHav){
        return @"有";
    }else if(value == cNone){
        return @"无";
    }else if(value == cGreater){
        return @"大";
    }else if(value == cLess){
        return @"小";
    }
    return STRFORMAT(@"%ld",value);
}


//MARK:===============================================================
//MARK:                     < 节点类型判断 >
//MARK:===============================================================
+(BOOL) isValue:(AIKVPointer*)node_p{
    return [kPN_VALUE isEqualToString:node_p.folderName] || [kPN_DATA isEqualToString:node_p.folderName] || [kPN_INDEX isEqualToString:node_p.folderName];
}

+(BOOL) isAlg:(AIKVPointer*)node_p{
    return [kPN_ALG_NODE isEqualToString:node_p.folderName] || [kPN_ALG_ABS_NODE isEqualToString:node_p.folderName];
}

+(BOOL) isFo:(AIKVPointer*)node_p{
    return [kPN_FRONT_ORDER_NODE isEqualToString:node_p.folderName] || [kPN_FO_ABS_NODE isEqualToString:node_p.folderName];
}

+(BOOL) isMv:(AIKVPointer*)node_p{
    return [kPN_CMV_NODE isEqualToString:node_p.folderName] || [kPN_ABS_CMV_NODE isEqualToString:node_p.folderName];
}

+(BOOL) isAbs:(AIKVPointer*)node_p{
    return [kPN_FO_ABS_NODE isEqualToString:node_p.folderName] || [kPN_ABS_CMV_NODE isEqualToString:node_p.folderName] || [kPN_ALG_ABS_NODE isEqualToString:node_p.folderName];
}

@end
