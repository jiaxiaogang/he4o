//
//  AINetEditor_Node.m
//  SMG_NothingIsAll
//
//  Created by 贾  on 2017/9/28.
//  Copyright © 2017年 XiaoGang. All rights reserved.
//

#import "AINetEditor_Node.h"

@implementation AINetEditor_Node

+(id) newWithNode:(AINode*)node eId:(NSString*)eId{
    AINetEditor_Node *value = [[AINetEditor_Node alloc] init];
    value.node = node;
    value.eId = STRTOOK(eId);
    return value;
}

@end
