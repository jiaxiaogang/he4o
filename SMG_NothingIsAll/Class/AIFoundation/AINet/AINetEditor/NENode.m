//
//  NENode.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/29.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "NENode.h"

@implementation NENode

+(id) newWithNode:(AINode*)node eId:(NSString*)eId{
    NENode *value = [[NENode alloc] init];
    value.node = node;
    value.eId = STRTOOK(eId);
    return value;
}

@end
