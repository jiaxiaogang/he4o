//
//  AICMVManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AICMVManager.h"
#import "PINCache.h"
#import "AIKVPointer.h"
#import "ThinkingUtils.h"
#import "AIFrontOrderNode.h"
#import "AICMVNode.h"
#import "AIAlgNode.h"
#import "AINetUtils.h"

@implementation AICMVManager

-(AIFrontOrderNode*) create:(NSArray*)imvAlgsArr order:(NSArray*)order{
    //1. 数据
    __block NSString *mvAlgsType = @"cmv";
    __block AIKVPointer *deltaPointer = nil;
    __block AIKVPointer *urgentToPointer = nil;
    __block NSInteger deltaValue = 0;
    __block NSInteger urgentToValue = 0;
    [ThinkingUtils parserAlgsMVArr:imvAlgsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
        deltaPointer = delta_p;
        mvAlgsType = algsType;
        urgentToPointer = urgentTo_p;
        deltaValue = delta;
        urgentToValue = urgentTo;
    }];
    
    //2. 打包cmvNode;
    AICMVNode *cmvNode = [[AICMVNode alloc] init];
    cmvNode.pointer = [SMGUtils createPointer:PATH_NET_CMV_NODE algsType:mvAlgsType dataSource:@""];
    cmvNode.delta_p = deltaPointer;
    cmvNode.urgentTo_p = urgentToPointer;
    [self createdNode:cmvNode.delta_p nodePointer:cmvNode.pointer];//reference
    [self createdNode:cmvNode.urgentTo_p nodePointer:cmvNode.pointer];
    [self createdCMVNode:cmvNode.pointer delta:deltaValue urgentTo:urgentToValue];
    
    //3. 打包foNode;
    AIFrontOrderNode *foNode = [[AIFrontOrderNode alloc] init];//node
    foNode.pointer = [SMGUtils createPointer:PATH_NET_FRONT_ORDER_NODE algsType:@"" dataSource:@""];
    for (AIPointer *conAlgNode_p in ARRTOOK(order)) {
        if (ISOK(conAlgNode_p, AIPointer.class)) {
            [foNode.orders_kvp addObject:conAlgNode_p];
            
            ///1. foNode引用报备;
            AIAlgNode *algNode = [SMGUtils searchObjectForPointer:conAlgNode_p fileName:FILENAME_Node time:cRedisNodeTime];
            [AINetUtils insertPointer:foNode.pointer toPorts:algNode.refPorts ps:foNode.orders_kvp];
            [SMGUtils insertObject:algNode rootPath:algNode.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
        }
    }
    
    //4. 互指向
    cmvNode.foNode_p = foNode.pointer;
    foNode.cmvNode_p = cmvNode.pointer;
    
    //5. 存储foNode & cmvNode
    [SMGUtils insertObject:cmvNode rootPath:cmvNode.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
    
    [SMGUtils insertObject:foNode rootPath:foNode.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
    
    //6. 返回给thinking
    return foNode;
}


/**
 *  MARK:--------------------用于,创建node后,将其插线到引用序列;--------------------
 */
-(void) createdNode:(AIPointer*)indexPointer nodePointer:(AIKVPointer*)nodePointer{
    if (self.delegate && [self.delegate respondsToSelector:@selector(aiNetCMV_CreatedNode:nodePointer:)]) {
        [self.delegate aiNetCMV_CreatedNode:indexPointer nodePointer:nodePointer];
    }
}

-(void) createdCMVNode:(AIKVPointer*)cmvNode_p delta:(NSInteger)delta urgentTo:(NSInteger)urgentTo{
    MVDirection direction = delta < 0 ? MVDirection_Negative : MVDirection_Positive;
    NSInteger difStrong = urgentTo;//暂时先相等;
    if (ISOK(cmvNode_p, AIKVPointer.class)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(aiNetCMV_CreatedCMVNode:mvAlgsType:direction:difStrong:)]) {
            [self.delegate aiNetCMV_CreatedCMVNode:cmvNode_p mvAlgsType:cmvNode_p.algsType direction:direction difStrong:difStrong];
        }
    }
}

@end
