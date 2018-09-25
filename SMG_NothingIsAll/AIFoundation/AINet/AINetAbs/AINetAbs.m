//
//  AINetAbs.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/30.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbs.h"
#import "AINetCMV.h"
#import "AIPort.h"
#import "PINCache.h"
#import "AIKVPointer.h"
#import "SMGUtils.h"
#import "XGRedisUtil.h"
#import "AINet.h"
#import "AINetAbsUtils.h"
#import "AIFrontOrderNode.h"
#import "AINetAbsNode.h"

@implementation AINetAbs

-(AINetAbsNode*) create:(NSArray*)con_nodes refs_p:(NSArray*)refs_p{
    //1. 从宏信息索引中,查找是否已经存在针对refs_p的抽象;(有则复用)(无则创建)
    AIKVPointer *absValue_p = [theNet getNetAbsIndex_AbsPointer:refs_p];
    AIKVPointer *absNode_p = [theNet getItemAbsNodePointer:absValue_p];
    AINetAbsNode *absNode = [SMGUtils searchObjectForPointer:absNode_p fileName:FILENAME_Node];
    
    //2. absNode:无则创建;
    if (absNode == nil) {
        absNode = [[AINetAbsNode alloc] init];
        absNode.pointer = [SMGUtils createPointerForNode:PATH_NET_ABS_NODE];
        absNode.absValue_p = absValue_p;//指定微信息
        [[AINet sharedInstance] setAbsIndexReference:absValue_p target_p:absNode.pointer difValue:1];//引用插线
    }
    
    //3. 关联
    for (NSObject *node in ARRTOOK(con_nodes)) {
        if (ISOK(node, AIFrontOrderNode.class)) {
            AIFrontOrderNode *foNode = (AIFrontOrderNode*)node;
            //4. conPorts插口(有则强化 & 无则创建)
            AIPort *findConPort = [AINetAbsUtils searchPortWithTargetP:foNode.pointer fromPorts:absNode.conPorts];
            if (findConPort) {
                [findConPort strongPlus];
            }else{
                AIPort *conPort = [[AIPort alloc] init];
                conPort.target_p = foNode.pointer;
                [absNode.conPorts addObject:conPort];
            }
            
            //5. absPorts插口(有则强化 & 无则创建)
            AIPort *findAbsPort = [AINetAbsUtils searchPortWithTargetP:absNode.pointer fromPorts:foNode.absPorts];
            if (findAbsPort) {
                [findAbsPort strongPlus];
            }else{
                AIPort *absPort = [[AIPort alloc] init];
                absPort.target_p = absNode.pointer;
                [foNode.absPorts addObject:absPort];
            }
            
            //6. 存foNode
            [SMGUtils insertObject:foNode rootPath:foNode.pointer.filePath fileName:FILENAME_Node];
        }else if(ISOK(node, AINetAbsNode.class)){
            AINetAbsNode *absNode = (AINetAbsNode*)node;
            
            
            
            
            
            
            
            
            
            
            
            
        }
    }
    
    //7. 存储absNode并返回
    [SMGUtils insertObject:absNode rootPath:absNode.pointer.filePath fileName:FILENAME_Node];
    return absNode;
}

@end
