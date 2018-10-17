//
//  NVUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/29.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "NVUtils.h"
#import "AINetAbsNode.h"
#import "AIPort.h"
#import "AIFrontOrderNode.h"
#import "AIKVPointer.h"
#import "AICMVNode.h"
#import "ThinkingUtils.h"

@implementation NVUtils

//MARK:===============================================================
//MARK:                     < value的可视化 >
//MARK:===============================================================

+(NSString*) convertValuePs2Str:(NSArray*)value_ps{
    value_ps = ARRTOOK(value_ps);
    NSMutableString *mStr = [NSMutableString new];
    for (AIKVPointer *value_p in value_ps) {
        NSNumber *valueNum = [SMGUtils searchObjectForPointer:value_p fileName:FILENAME_Value];
        if (valueNum) {
            char c = [valueNum charValue];
            [mStr appendFormat:@"%@%c ", value_p.isOut ? @"O" : @"I", c];
        }
    }
    return mStr;
}


//MARK:===============================================================
//MARK:                       < node的可视化 >
//MARK:===============================================================

+(NSString*) getAbsNodeDesc:(AINetAbsNode*)absNode {
    //1. 数据检查
    NSMutableString *mStr = [NSMutableString new];
    if (!absNode) {
        return mStr;
    }
    
    //2. absNode.desc
    NSArray *value_ps = [SMGUtils searchObjectForPointer:absNode.absValue_p fileName:FILENAME_AbsValue];
    [mStr appendFormat:@"\npointerId : %d content: %@\n",absNode.pointer.pointerId,[NVUtils convertValuePs2Str:value_ps]];
        
    //3. absNode.conPorts.desc
    for (AIPort *conPort in absNode.conPorts) {
        id con = [SMGUtils searchObjectForPointer:conPort.target_p fileName:FILENAME_Node];
        NSMutableString *micDesc = [NSMutableString new];
        NSString *conPath = nil;
        if (ISOK(con, AIFrontOrderNode.class)) {
            AIFrontOrderNode *foNode = (AIFrontOrderNode*)con;
            NSString *content = [NVUtils convertValuePs2Str:foNode.orders_kvp];
            [mStr appendFormat:@"con %@/%@/%@/%ld content:%@",foNode.pointer.folderName,foNode.pointer.algsType,foNode.pointer.dataSource,(long)foNode.pointer.pointerId,content];
        }else if(ISOK(con, AINetAbsNode.class)){
            AINetAbsNode *conAbsNode = (AINetAbsNode*)con;
            NSArray *value_ps = [SMGUtils searchObjectForPointer:conAbsNode.absValue_p fileName:FILENAME_AbsValue];
            NSString *content = [NVUtils convertValuePs2Str:value_ps];
            [mStr appendFormat:@"con %@/%@/%@/%ld content:%@",conAbsNode.pointer.folderName,conAbsNode.pointer.algsType,conAbsNode.pointer.dataSource,(long)conAbsNode.pointer.pointerId,content];
        }
    }
    return mStr;
}


//MARK:===============================================================
//MARK:           < cmvModel的可视化(foOrder->cmvNode) >
//MARK:===============================================================

+(NSString*) getFoNodeDesc:(AIFrontOrderNode*)foNode{
    AICMVNode *cmvNode = nil;
    if (foNode) {
        cmvNode = [SMGUtils searchObjectForPointer:foNode.cmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
    }
    return [self getCmvModelDesc:foNode cmvNode:cmvNode];
}

+(NSString*) getCmvNodeDesc:(AICMVNode*)cmvNode{
    AIFrontOrderNode *foNode = [ThinkingUtils getFoNodeFromCmvNode:cmvNode];
    return [self getCmvModelDesc:foNode cmvNode:cmvNode];
}

+(NSString*) getCmvModelDesc:(AIFrontOrderNode*)foNode cmvNode:(AICMVNode*)cmvNode{
    //1. 前因时序列描述
    NSString *foDesc = nil;
    if (foNode) {
        foDesc = [NVUtils convertValuePs2Str:foNode.orders_kvp];
    }
    
    //2. cmv描述
    NSString *cmvDesc = nil;
    if (cmvNode) {
        NSNumber *urgentToNum = [SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime];
        NSNumber *deltaNum = [SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime];
        cmvDesc = STRFORMAT(@"ur%@_de%@",urgentToNum,deltaNum);
    }
    
    //3. 拼desc返回
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"(fo: %@ => cmv: %@)",foDesc,cmvDesc];
    
    return desc;
}


@end
