//
//  AIMvFoManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/6.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIMvFoManager.h"
#import "AINetAbsFoUtils.h"

@implementation AIMvFoManager

/**
 *  MARK:--------------------创建fo和mv的指向--------------------
 *  @param mv notnull
 */
-(AIFrontOrderNode*) create:(NSTimeInterval)inputTime order:(NSArray*)order mv:(AICMVNode*)mv{
    //1. foNode;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:mv.urgentTo_p]) integerValue];
    AIFrontOrderNode *foNode = [AIMvFoManager createConFo:order difStrong:urgentTo];

    //2. 将mv.inputTime传入,在relateFo之前,将inputTime赋值fo.mvDeltaTime;
    if (ARRISOK(order)) {
        AIShortMatchModel_Simple *lastOrderTime = ARR_INDEX_REVERSE(order, 0);
        foNode.mvDeltaTime = inputTime - lastOrderTime.inputTime;
    }
    
    //3. 互指向
    [AINetUtils relateFo:foNode mv:mv];

    //4. 返回给thinking
    return foNode;
}

-(AICMVNode*) createConMv:(NSArray*)imvAlgsArr {
    //1. 数据解析 & 打包cmvNode;
    __block AICMVNode *cmvNode = nil;
    [ThinkingUtils parserAlgsMVArr:imvAlgsArr success:^(AIKVPointer *delta_p, AIKVPointer *urgentTo_p, NSInteger delta, NSInteger urgentTo, NSString *algsType) {
        //2. 打包cmvNode (imv的价值节点先放内存中);
        cmvNode = [self createConMv:urgentTo_p delta_p:delta_p at:algsType];
    }];
    return cmvNode;
}
-(AICMVNode*) createConMv:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p at:(NSString*)at {
    //1. 数据
    if (!urgentTo_p || !delta_p || !at) return nil;
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:urgentTo_p]) integerValue];

    //2. 打包cmvNode;
    AICMVNode *cmvNode = [[AICMVNode alloc] init];
    cmvNode.pointer = [SMGUtils createPointer:kPN_CMV_NODE algsType:at dataSource:DefaultDataSource isOut:false type:ATDefault];
    cmvNode.delta_p = delta_p;
    cmvNode.urgentTo_p = urgentTo_p;
    [AINetUtils insertRefPorts_AllMvNode:cmvNode.pointer value_p:cmvNode.delta_p difStrong:1];//引用插线
    [AINetUtils insertRefPorts_AllMvNode:cmvNode.pointer value_p:cmvNode.urgentTo_p difStrong:1];//引用插线
    [theNet setMvNodeToDirectionReference:cmvNode difStrong:urgentTo];//difStrong暂时先相等;

    //5. 存储cmvNode
    [SMGUtils insertNode:cmvNode];
    return cmvNode;
}


/**
 *  MARK:--------------------构建conFo--------------------
 *  @result notnull
 *  @callers
 *      1. 新帧输入时,构建matchAFo;
 *      2. 新帧输入时,构建protoFo;
 */
+(AIFrontOrderNode*) createConFo:(NSArray*)order{
    return [self createConFo:order difStrong:1];
}
+(AIFrontOrderNode*) createConFo:(NSArray*)order difStrong:(NSInteger)difStrong{
    //1. foNode
    AIFrontOrderNode *foNode = [[AIFrontOrderNode alloc] init];

    //2. pointer (最终生成conFo时,全是ATDefault类型);
    foNode.pointer = [SMGUtils createPointer:kPN_FRONT_ORDER_NODE algsType:DefaultAlgsType dataSource:DefaultDataSource isOut:false type:ATDefault];

    //3. content_ps
    NSArray *content_ps = [AINetAbsFoUtils convertOrder2Alg_ps:order];
    
    //4. foNode.orders收集
    [foNode setContent_ps:content_ps];

    //5. foNode引用conAlg;
    [AINetUtils insertRefPorts_AllFoNode:foNode.pointer order_ps:foNode.content_ps ps:foNode.content_ps difStrong:difStrong];
    
    //6. 提取findAbsNode的deltaTimes;
    foNode.deltaTimes = [AINetAbsFoUtils convertOrder2DeltaTimes:order];
    
    //7. 存储foNode
    [SMGUtils insertNode:foNode];
    [AITest test8:foNode.content_ps type:ATDefault];
    return foNode;
}

@end
