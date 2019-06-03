//
//  NVUtils.m
//  SMG_NothingIsAll
//
//  Created by jiaxiaogang on 2018/9/29.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "NVUtils.h"
#import "AINetAbsFoNode.h"
#import "AIPort.h"
#import "AIFrontOrderNode.h"
#import "AIKVPointer.h"
#import "AICMVNode.h"
#import "ThinkingUtils.h"
#import "AIAbsCMVNode.h"
#import "AIAlgNodeBase.h"
#import "AINetIndex.h"

@implementation NVUtils

//MARK:===============================================================
//MARK:                     < 组可视化 >
//MARK:===============================================================

+(NSString*) convertValuePs2Str:(NSArray*)value_ps{
    //1. 数据准备
    value_ps = ARRTOOK(value_ps);
    NSMutableString *mStr = [NSMutableString new];
    
    //2. 将祖母嵌套展开
    NSMutableArray *mic_ps = [SMGUtils convertValuePs2MicroValuePs:value_ps];
    for (AIKVPointer *value_p in mic_ps) {
        NSNumber *valueNum = [AINetIndex getData:value_p];
        if (valueNum) {
            [mStr appendFormat:@"%@%@:%@ ", value_p.dataSource,(value_p.isOut ? @"^" : @"ˇ"), valueNum];
        }
    }
    return mStr;
}

+(NSString*) convertOrderPs2Str:(NSArray*)order_ps{
    order_ps = ARRTOOK(order_ps);
    NSMutableString *mStr = [NSMutableString new];
    for (AIKVPointer *algNode_p in order_ps) {
        AIAlgNodeBase *algNode = [SMGUtils searchNode:algNode_p];
        if (ISOK(algNode, AIAlgNodeBase.class)) {
            [mStr appendFormat:@"%@%@",(mStr.length == 0 ? @"":@"\n"),[self convertValuePs2Str:algNode.content_ps]];
        }
    }
    return mStr;
}


//MARK:===============================================================
//MARK:                       < node的可视化 >
//MARK:===============================================================

+(NSString*) getAlgNodeDesc:(AIAlgNodeBase*)algNode {
    if (ISOK(algNode, AIAlgNodeBase.class)) {
        return [NVUtils convertValuePs2Str:((AIAlgNodeBase*)algNode).content_ps];
    }
    return nil;
}

//foNode前时序列的描述 (i3 o4)
+(NSString*) getFoNodeDesc:(AIFoNodeBase*)foNode {
    if (ISOK(foNode, AIFoNodeBase.class)) {
        return [NVUtils convertOrderPs2Str:((AIFrontOrderNode*)foNode).orders_kvp];
    }
    return nil;
}

//cmvNode的描述 ("ur0_de0"格式)
+(NSString*) getCmvNodeDesc:(AICMVNodeBase*)cmvNode {
    NSString *cmvDesc = nil;
    if (cmvNode) {
        NSNumber *urgentToNum = [AINetIndex getData:cmvNode.urgentTo_p];
        NSNumber *deltaNum = [AINetIndex getData:cmvNode.delta_p];
        cmvDesc = STRFORMAT(@"ur%@_de%@",urgentToNum,deltaNum);
    }
    return cmvDesc;
}

//MARK:===============================================================
//MARK:           < cmvModel的可视化(foOrder->cmvNode) >
//MARK:===============================================================

+(NSString*) getCmvModelDesc_ByFoNode:(AIFoNodeBase*)foNode{
    if (foNode) {
        AICMVNodeBase *cmvNode = [SMGUtils searchNode:foNode.cmvNode_p];
        return [self getCmvModelDesc:foNode cmvNode:cmvNode];
    }
    return nil;
}

+(NSString*) getCmvModelDesc_ByCmvNode:(AICMVNodeBase*)cmvNode{
    if (cmvNode) {
        AIFoNodeBase *foNode = [SMGUtils searchNode:cmvNode.foNode_p];
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
    return STRFORMAT(@"\nFO>>>>\n%@\nCMV>>>>\n%@",foDesc,cmvDesc);
}

//MARK:===============================================================
//MARK:                     < conPorts & absPorts >
//MARK:===============================================================

//conPorts的描述 (conPorts >>\n > 1\n > 2)
+(NSString*) getFoNodeConPortsDesc:(AINetAbsFoNode*)absNode{
    //1. 数据检查
    if (absNode) {
        NSMutableString *mStr = [NSMutableString new];
        
        //2. absNode.conPorts.desc
        for (AIPort *conPort in absNode.conPorts) {
            AIFoNodeBase *conNode = [SMGUtils searchNode:conPort.target_p];
            [mStr appendFormat:@"具象FO:\n%@",[self getFoNodeDesc:conNode]];
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
            AIFoNodeBase *conNode = [SMGUtils searchNode:conPort.target_p];
            [mStr appendFormat:@"抽象FO:\n%@",[self getFoNodeDesc:conNode]];
        }
        return mStr;
    }
    return nil;
}

@end
