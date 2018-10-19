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
#import "AIAbsCMVNode.h"

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

//foNode前时序列的描述 (i3 o4)
+(NSString*) getFoNodeDesc:(AIFoNodeBase*)foNode {
    NSString *foDesc = nil;
    if (ISOK(foNode, AIFrontOrderNode.class)) {
        foDesc = [NVUtils convertValuePs2Str:((AIFrontOrderNode*)foNode).orders_kvp];
    }else if(ISOK(foNode, AINetAbsNode.class)){
        NSArray *value_ps = [SMGUtils searchObjectForPointer:((AINetAbsNode*)foNode).absValue_p fileName:FILENAME_AbsValue time:cRedisValueTime];
        foDesc = [NVUtils convertValuePs2Str:value_ps];
    }
    return foDesc;
}

//cmvNode的描述 ("ur0_de0"格式)
+(NSString*) getCmvNodeDesc:(AICMVNodeBase*)cmvNode {
    NSString *cmvDesc = nil;
    if (cmvNode) {
        NSNumber *urgentToNum = [SMGUtils searchObjectForPointer:cmvNode.urgentTo_p fileName:FILENAME_Value time:cRedisValueTime];
        NSNumber *deltaNum = [SMGUtils searchObjectForPointer:cmvNode.delta_p fileName:FILENAME_Value time:cRedisValueTime];
        cmvDesc = STRFORMAT(@"ur%@_de%@",urgentToNum,deltaNum);
    }
    return cmvDesc;
}

//MARK:===============================================================
//MARK:           < cmvModel的可视化(foOrder->cmvNode) >
//MARK:===============================================================

+(NSString*) getCmvModelDesc_ByFoNode:(AIFoNodeBase*)foNode{
    if (foNode) {
        AICMVNodeBase *cmvNode = [SMGUtils searchObjectForPointer:foNode.cmvNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        return [self getCmvModelDesc:foNode cmvNode:cmvNode];
    }
    return nil;
}

+(NSString*) getCmvModelDesc_ByCmvNode:(AICMVNodeBase*)cmvNode{
    if (cmvNode) {
        AIFoNodeBase *foNode = [SMGUtils searchObjectForPointer:cmvNode.foNode_p fileName:FILENAME_Node time:cRedisNodeTime];
        return [self getCmvModelDesc:foNode cmvNode:cmvNode];
    }
    return nil;
}

+(NSString*) getCmvModelDesc:(AIFoNodeBase*)absNode cmvNode:(AICMVNodeBase*)cmvNode{
    //1. 前因时序列描述
    NSString *foDesc = [self getFoNodeDesc:absNode];
    
    //2. cmv描述
    NSString *cmvDesc = [self getCmvNodeDesc:cmvNode];
    
    //3. 拼desc返回
    return STRFORMAT(@"(fo: %@ => cmv: %@)",foDesc,cmvDesc);
}

@end
