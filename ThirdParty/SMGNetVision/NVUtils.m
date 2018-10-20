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

//MARK:===============================================================
//MARK:                     < conPorts & absPorts >
//MARK:===============================================================

//conPorts的描述 (conPorts >>\n > 1\n > 2)
+(NSString*) getFoNodeConPortsDesc:(AINetAbsNode*)absNode{
    //1. 数据检查
    if (absNode) {
        NSMutableString *mStr = [NSMutableString new];
        
        //2. absNode.conPorts.desc
        for (AIPort *conPort in absNode.conPorts) {
            AIFoNodeBase *conNode = [SMGUtils searchObjectForPointer:conPort.target_p fileName:FILENAME_Node];
            [mStr appendFormat:@"\n > %@",[self getFoNodeDesc:conNode]];
        }
        return mStr;
    }
    return nil;
}

//absPorts的描述 (absPorts >>\n > 1\n > 2)
+(NSString*) getFoNodeAbsPortsDesc:(AIFoNodeBase*)foNode{
    //1. 数据检查
    if (foNode) {
        NSMutableString *mStr = [NSMutableString new];
        
        //2. absNode.absPorts.desc
        for (AIPort *conPort in foNode.absPorts) {
            AIFoNodeBase *conNode = [SMGUtils searchObjectForPointer:conPort.target_p fileName:FILENAME_Node];
            [mStr appendFormat:@"\n > %@",[self getFoNodeDesc:conNode]];
        }
        return mStr;
    }
    return nil;
}

@end
