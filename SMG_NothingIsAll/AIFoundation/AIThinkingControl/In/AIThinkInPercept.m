//
//  AIThinkInPercept.m
//  SMG_NothingIsAll
//
//  Created by jia on 2019/9/2.
//  Copyright © 2019年 XiaoGang. All rights reserved.
//

#import "AIThinkInPercept.h"
#import "AIFrontOrderNode.h"
#import "AICMVNode.h"
#import "AIKVPointer.h"
#import "AIPort.h"
#import "AINet.h"
#import "AIThinkInAnalogy.h"
#import "AINetIndex.h"

@implementation AIThinkInPercept

+(void) dataIn_FindMV:(NSArray*)algsArr
   createMvModelBlock:(AIFrontOrderNode*(^)(NSArray *algsArr))createMvModelBlock
          finishBlock:(void(^)(AICMVNode *commitMvNode))finishBlock
               canAss:(BOOL(^)())canAss
         updateEnergy:(void(^)(CGFloat delta))updateEnergy{
    //1. 联想到mv时,创建CmvModel取到FoNode;
    AIFrontOrderNode *foNode = nil;
    if (createMvModelBlock) {
        foNode = createMvModelBlock(algsArr);
    }
    if (!ISOK(foNode, AIFrontOrderNode.class)) {
        return;
    }
    
    //2. 取cmvNode
    AICMVNode *cmvNode = [SMGUtils searchNode:foNode.cmvNode_p];
    if (!ISOK(cmvNode, AICMVNode.class)) {
        return;
    }
    [theNV setNodeData:foNode.pointer lightStr:@"新"];
    [theNV setNodeData:cmvNode.pointer lightStr:@"新"];
    
    //3. 思考mv,需求处理
    if (finishBlock) {
        finishBlock(cmvNode);
    }
    
    //4. 学习
    [self dataIn_FindMV_Learning:foNode cmvNode:cmvNode canAss:canAss updateEnergy:updateEnergy];
}

/**
 *  MARK:--------------------学习--------------------
 *  分为:
 *   1. 外类比
 *   2. 内类比
 *  解释:
 *   1. 无需求时,找出以往同样经历,类比规律,抽象出更确切的意义;
 *   2. 注:此方法为abs方向的思维方法总入口;(与其相对的决策处
 *  步骤:
 *   > 联想->类比->规律->抽象->关联->网络
 */
+(void) dataIn_FindMV_Learning:(AIFrontOrderNode*)foNode cmvNode:(AICMVNode*)cmvNode canAss:(BOOL(^)())canAss updateEnergy:(void(^)(CGFloat delta))updateEnergy{
    //1. 数据检查 & 准备
    if (foNode == nil || cmvNode == nil) {
        return;
    }
    NSInteger delta = [NUMTOOK([AINetIndex getData:cmvNode.delta_p]) integerValue];
    MVDirection direction = delta < 0 ? MVDirection_Negative : MVDirection_Positive;
    
    //2. 联想相似mv数据_内存网络取1个;(联想内存类比,用以发现新的时序,比如学玩新游戏)
    NSArray *memMvPorts = [theNet getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:direction isMem:true filter:^NSArray *(NSArray *protoArr) {
        protoArr = ARRTOOK(protoArr);
        for (AIPort *protoItem in protoArr) {
            if (![cmvNode.pointer isEqual:protoItem.target_p]) {
                return @[protoItem];
            }
        }
        return nil;
    }];
    
    //2. 联想相似mv数据_硬盘网络取2个; (并strong+1)(联想硬盘类比,用以找出当下很确切的时序,比如每天加强吃饭-饱)
    NSArray *hdMvPorts = [theNet getNetNodePointersFromDirectionReference:cmvNode.pointer.algsType direction:direction isMem:false limit:2];
    for (AIPort *hdPort in hdMvPorts) {
        AICMVNodeBase *cmvNode = [SMGUtils searchNode:hdPort.target_p];
        [theNet setMvNodeToDirectionReference:cmvNode difStrong:1];
    }
    
    //2. 收集联想到的mv到一块儿
    NSMutableArray *assDirectionPorts = [[NSMutableArray alloc] init];
    [assDirectionPorts addObjectsFromArray:memMvPorts];
    [assDirectionPorts addObjectsFromArray:hdMvPorts];
    
    //3. 外类比_以mv为方向,联想assFo
    for (AIPort *assDirectionPort in assDirectionPorts) {
        AICMVNodeBase *assMvNode = [SMGUtils searchNode:assDirectionPort.target_p];
        
        if (ISOK(assMvNode, AICMVNodeBase.class)) {
            //4. 排除联想自己(随后写到reference中)
            if (![cmvNode.pointer isEqual:assMvNode.pointer]) {
                AIFoNodeBase *assFrontNode = [SMGUtils searchNode:assMvNode.foNode_p];
                
                if (ISOK(assFrontNode, AINodeBase.class)) {
                    [theNV setNodeData:assFrontNode.pointer lightStr:@"旧"];
                    [theNV setNodeData:assFrontNode.cmvNode_p lightStr:@"旧"];
                    //5. 执行外类比;
                    [AIThinkInAnalogy analogyOutside:foNode assFo:assFrontNode canAss:^BOOL{
                        return canAss();
                    } updateEnergy:^(CGFloat delta) {
                        updateEnergy(delta);
                    } fromInner:false];
                }
            }
        }
    }
    
    //12. 内类比
    [AIThinkInAnalogy analogyInner:foNode canAss:^BOOL{
        return canAss();
    } updateEnergy:^(CGFloat delta) {
        updateEnergy(delta);
    }];
}

@end
