//
//  AIAbsCMVManager.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/7/27.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "AIAbsCMVManager.h"
#import "AIAbsCMVNode.h"
#import "AICMVNode.h"
#import "AIKVPointer.h"
#import "AINetAbsCMVUtil.h"
#import "AINet.h"
#import "AIPort.h"
#import "AINetUtils.h"
#import "AINet.h"
#import "AINetIndex.h"

/**
 *  MARK:--------------------生成AINetAbsCMVNode--------------------
 */
@implementation AIAbsCMVManager

-(AIAbsCMVNode*) create:(AIKVPointer*)absFo_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p {
    //1. 数据
    BOOL valid = ISOK(aMv_p, AIKVPointer.class) && ISOK(bMv_p, AIKVPointer.class) && [STRTOOK(aMv_p.algsType) isEqualToString:bMv_p.algsType];
    if (!valid) {
        return nil;
    }

    return [self create:absFo_p conMvPs:@[aMv_p,bMv_p]];
}


-(AIAbsCMVNode*) create:(AIKVPointer*)absFo_p conMvPs:(NSArray*)conMv_ps{
    //1. 数据
    if (!ARRISOK(conMv_ps)) {
        return nil;
    }

    //2. 取algsType & dataSource (每一个conMv都一致,则继承,否则使用cMvNoneIdent)
    NSString *algsType = nil;
    NSString *dataSource = nil;
    for (AIKVPointer *mv_p in conMv_ps) {
        if (algsType == nil) {
            algsType = mv_p.algsType;
        }else if(![algsType isEqualToString:mv_p.algsType]){
            algsType = cMvNoneIdent;
        }
        if (dataSource == nil) {
            dataSource = mv_p.dataSource;
        }else if(![dataSource isEqualToString:mv_p.dataSource]){
            dataSource = cMvNoneIdent;
        }
    }

    //3. 将conMv_ps转换为conMvs
    NSArray *conMvs = [SMGUtils searchNodes:conMv_ps];

    //4. 取absUrgentTo & absDelta;
    NSInteger absUrgentTo = [AINetAbsCMVUtil getAbsUrgentTo:conMvs];
    NSInteger absDelta = [AINetAbsCMVUtil getAbsDelta:conMvs];
    AIKVPointer *urgentTo_p = [theNet getNetDataPointerWithData:@(absUrgentTo) algsType:algsType dataSource:dataSource];
    AIKVPointer *delta_p = [theNet getNetDataPointerWithData:@(absDelta) algsType:algsType dataSource:dataSource];

    //5. 构建返回
    return [self create_General:absFo_p conMvs:conMvs at:algsType ds:dataSource urgentTo_p:urgentTo_p delta_p:delta_p];
}

-(AIAbsCMVNode*) create_General:(AIKVPointer*)absFo_p conMvs:(NSArray*)conMvs at:(NSString*)at ds:(NSString*)ds urgentTo_p:(AIKVPointer*)urgentTo_p delta_p:(AIKVPointer*)delta_p{
    //1. 数据
    if (!ARRISOK(conMvs) || !urgentTo_p || !delta_p) {
        return nil;
    }
    at = STRTOOK(at);
    ds = STRTOOK(ds);
    NSInteger urgentTo = [NUMTOOK([AINetIndex getData:urgentTo_p]) integerValue];

    //2. 创建absCMVNode;
    AIAbsCMVNode *result = [[AIAbsCMVNode alloc] init];
    result.pointer = [SMGUtils createPointer:kPN_ABS_CMV_NODE algsType:at dataSource:ds isOut:false isMem:false];
    result.foNode_p = absFo_p;
    result.urgentTo_p = (AIKVPointer*)urgentTo_p;
    result.delta_p = (AIKVPointer*)delta_p;
    [AINetUtils insertRefPorts_AllMvNode:result.pointer value_p:result.urgentTo_p difStrong:1];//引用插线
    [AINetUtils insertRefPorts_AllMvNode:result.pointer value_p:result.delta_p difStrong:1];//引用插线

    //3. 抽具象关联插线 & 存储抽具象节点;
    [AINetUtils relateMvAbs:result conNodes:conMvs];

    //4. 方向索引
    NSInteger indexStrong = [AINetAbsCMVUtil getDefaultStrong_Index:result conMvs:conMvs];
    [theNet setMvNodeToDirectionReference:result difStrong:indexStrong];
    return result;
}


@end
