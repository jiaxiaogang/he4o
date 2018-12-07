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
#import "AINetAbsFoNode.h"

@implementation AINetAbs

-(AINetAbsFoNode*) create:(NSArray*)conFoNodes refs_p:(NSArray*)refs_p{
    //1. 从宏信息索引中,查找是否已经存在针对refs_p的抽象;(有则复用)(无则创建)
    AIKVPointer *absValue_p = [theNet getNetAbsIndex_AbsPointer:refs_p];
    AIPointer *absNode_p = [theNet getItemAbsNodePointer:absValue_p];
    AINetAbsFoNode *absNode = [SMGUtils searchObjectForPointer:absNode_p fileName:FILENAME_Node];
    
    //2. absNode:无则创建;
    if (absNode == nil) {
        absNode = [[AINetAbsFoNode alloc] init];
        absNode.pointer = [SMGUtils createPointerForNode:PATH_NET_ABS_NODE];
        absNode.absValue_p = absValue_p;//指定微信息
        [[AINet sharedInstance] setAbsIndexReference:absValue_p target_p:absNode.pointer difValue:1];//引用插线
    }
    
    //3. 关联
    for (AIFoNodeBase *con_node in ARRTOOK(conFoNodes)) {
        if (ISOK(con_node, AINodeBase.class)) {
            //4. conPorts插口(有则强化 & 无则创建)
            AIPort *findConPort = [AINetAbsUtils searchPortWithTargetP:con_node.pointer fromPorts:absNode.conPorts];
            if (findConPort) {
                [findConPort strongPlus];
            }else{
                AIPort *conPort = [[AIPort alloc] init];
                conPort.target_p = con_node.pointer;
                [absNode.conPorts addObject:conPort];
            }
            
            //5. absPorts插口(有则强化 & 无则创建)
            AIPort *findAbsPort = [AINetAbsUtils searchPortWithTargetP:absNode.pointer fromPorts:con_node.absPorts];
            if (findAbsPort) {
                [findAbsPort strongPlus];
            }else{
                AIPort *absPort = [[AIPort alloc] init];
                absPort.target_p = absNode.pointer;
                [con_node.absPorts addObject:absPort];
            }
            
            //6. 存foNode
            [SMGUtils insertObject:con_node rootPath:con_node.pointer.filePath fileName:FILENAME_Node];
        }
    }
    
    //7. 存储absNode并返回
    [SMGUtils insertObject:absNode rootPath:absNode.pointer.filePath fileName:FILENAME_Node];
    return absNode;
}

@end
