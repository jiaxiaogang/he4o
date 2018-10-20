//
//  AINetAbsCMV.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/27.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AINetAbsCMV.h"
#import "AIAbsCMVNode.h"
#import "AICMVNode.h"
#import "AIKVPointer.h"
#import "AINetAbsCMVUtil.h"
#import "AINet.h"
#import "AIPort.h"

/**
 *  MARK:--------------------生成AINetAbsCMVNode--------------------
 */
@implementation AINetAbsCMV


/**
 *  MARK:--------------------在两个cmvNode基础上构建抽象--------------------
 *  @params absNode_p : 抽象宏节点(前因)
 *  @params aMv_p : cmv节点A
 *  @params bMv_p : cmv节点B
 */
-(AIAbsCMVNode*) create:(AIKVPointer*)absNode_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p {
    //1. 数据
    BOOL valid = ISOK(aMv_p, AIKVPointer.class) && ISOK(bMv_p, AIKVPointer.class) && [STRTOOK(aMv_p.algsType) isEqualToString:bMv_p.algsType] && ISOK(absNode_p, AIKVPointer.class);
    if (!valid) {
        return nil;
    }
    NSString *algsType = aMv_p.algsType;
    NSString *dataSource = aMv_p.dataSource;
    
    //2. 取cmvNode
    AICMVNodeBase *aMv = [SMGUtils searchObjectForPointer:aMv_p fileName:FILENAME_Node time:cRedisNodeTime];
    AICMVNodeBase *bMv = [SMGUtils searchObjectForPointer:bMv_p fileName:FILENAME_Node time:cRedisNodeTime];
    if (!ISOK(aMv, AICMVNodeBase.class) || !ISOK(bMv, AICMVNodeBase.class)) {
        return nil;
    }
    
    //2. 创建absCMVNode;
    AIAbsCMVNode *result_acn = [[AIAbsCMVNode alloc] init];
    result_acn.pointer = [SMGUtils createPointer:PATH_NET_ABS_CMV_NODE algsType:algsType dataSource:dataSource];
    result_acn.foNode_p = absNode_p;
    
    //3. absUrgentTo
    NSInteger absUrgentTo = [AINetAbsCMVUtil getAbsUrgentTo:aMv bMv_p:bMv];
    AIPointer *urgentTo_p = [theNet getNetDataPointerWithData:@(absUrgentTo) algsType:algsType dataSource:dataSource];
    if (ISOK(urgentTo_p, AIKVPointer.class)) {
        result_acn.urgentTo_p = (AIKVPointer*)urgentTo_p;
        [theNet setAbsIndexReference:result_acn.urgentTo_p target_p:result_acn.pointer difValue:1];//引用插线
    }
    
    //4. absDelta
    NSInteger absDelta = [AINetAbsCMVUtil getAbsDelta:aMv bMv_p:bMv];
    AIPointer *delta_p = [theNet getNetDataPointerWithData:@(absDelta) algsType:algsType dataSource:dataSource];
    if (ISOK(delta_p, AIKVPointer.class)) {
        result_acn.delta_p = (AIKVPointer*)delta_p;
        [theNet setAbsIndexReference:result_acn.delta_p target_p:result_acn.pointer difValue:1];//引用插线
    }
    
    //5. 关联conPorts插口
    AIPort *aConPort = [[AIPort alloc] init];
    aConPort.target_p = aMv_p;
    [result_acn addConPorts:aConPort difValue:1];
    
    AIPort *bConPort = [[AIPort alloc] init];
    bConPort.target_p = bMv_p;
    [result_acn addConPorts:bConPort difValue:1];
    
    //6. 关联absPort插口
    AIPort *absNPort = [[AIPort alloc] init];
    absNPort.target_p = result_acn.pointer;
    [aMv.absPorts addObject:absNPort];
    [bMv.absPorts addObject:absNPort];
    [SMGUtils insertObject:aMv rootPath:aMv.pointer.filePath fileName:FILENAME_Node];
    [SMGUtils insertObject:bMv rootPath:bMv.pointer.filePath fileName:FILENAME_Node];
    
    //7. 报告添加direction引用
    [self createdAbsCMVNode:result_acn.pointer delta:absDelta urgentTo:absUrgentTo];
    
    //8. 存储absNode并返回
    [SMGUtils insertObject:result_acn rootPath:result_acn.pointer.filePath fileName:FILENAME_Node time:cRedisNodeTime];
    return result_acn;
}


//MARK:===============================================================
//MARK:                     < private_Method >
//MARK:===============================================================
-(void) createdAbsCMVNode:(AIKVPointer*)absCmvNode_p delta:(NSInteger)delta urgentTo:(NSInteger)urgentTo{
    MVDirection direction = delta < 0 ? MVDirection_Negative : MVDirection_Positive;
    NSInteger difStrong = urgentTo * 2;//暂时先x2;(因为一般是两个相抽象)
    if (ISOK(absCmvNode_p, AIKVPointer.class)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(aiNetCMVNode_createdAbsCMVNode:mvAlgsType:direction:difStrong:)]) {
            [self.delegate aiNetCMVNode_createdAbsCMVNode:absCmvNode_p mvAlgsType:absCmvNode_p.algsType direction:direction difStrong:difStrong];
        }
    }
}

@end
