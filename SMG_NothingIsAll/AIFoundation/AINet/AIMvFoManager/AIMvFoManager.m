//
//  AIMvFoManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIMvFoManager.h"
#import "PINCache.h"
#import "AIKVPointer.h"
#import "ThinkingUtils.h"
#import "AIFrontOrderNode.h"
#import "AICMVNode.h"
#import "AIAlgNode.h"
#import "AINetUtils.h"
#import "AINet.h"

@implementation AIMvFoManager

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
    cmvNode.pointer = [SMGUtils createPointer:kPN_CMV_NODE algsType:mvAlgsType dataSource:@"" isOut:false isMem:true];
    cmvNode.delta_p = deltaPointer;
    cmvNode.urgentTo_p = urgentToPointer;
    [AINetUtils insertRefPorts_AllMvNode:cmvNode.pointer value_p:cmvNode.delta_p difStrong:1];//引用插线
    [AINetUtils insertRefPorts_AllMvNode:cmvNode.pointer value_p:cmvNode.urgentTo_p difStrong:1];//引用插线
    [theNet setMvNodeToDirectionReference:cmvNode.pointer delta:deltaValue difStrong:urgentToValue];//difStrong暂时先相等;
    
    //3. 打包foNode;
    AIFrontOrderNode *foNode = [[AIFrontOrderNode alloc] init];//node
    foNode.pointer = [SMGUtils createPointer:kPN_FRONT_ORDER_NODE algsType:@"" dataSource:@"" isOut:false isMem:true];
    //3.1. foNode.orders收集
    for (AIPointer *conAlgNode_p in ARRTOOK(order)) {
        if (ISOK(conAlgNode_p, AIPointer.class)) {
            [foNode.orders_kvp addObject:conAlgNode_p];
        }
    }
    //3.2. foNode引用conAlg;
    [AINetUtils insertRefPorts_AllFoNode:foNode.pointer order_ps:foNode.orders_kvp ps:foNode.orders_kvp];
    
    //4. 互指向
    cmvNode.foNode_p = foNode.pointer;
    foNode.cmvNode_p = cmvNode.pointer;
    
    //5. 存储foNode & cmvNode
    [SMGUtils insertNode:cmvNode];
    [SMGUtils insertNode:foNode];
    
    //6. 返回给thinking
    return foNode;
}

@end
