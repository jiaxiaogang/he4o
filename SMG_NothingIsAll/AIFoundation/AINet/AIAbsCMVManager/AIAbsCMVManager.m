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

/**
 *  MARK:--------------------生成AINetAbsCMVNode--------------------
 */
@implementation AIAbsCMVManager

-(AIAbsCMVNode*) create:(AIKVPointer*)absFo_p aMv_p:(AIKVPointer*)aMv_p bMv_p:(AIKVPointer*)bMv_p {
    //1. 数据
    BOOL valid = ISOK(aMv_p, AIKVPointer.class) && ISOK(bMv_p, AIKVPointer.class) && [STRTOOK(aMv_p.algsType) isEqualToString:bMv_p.algsType] && ISOK(absFo_p, AIKVPointer.class);
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
    NSMutableArray *conMvs = [[NSMutableArray alloc] init];
    for (AIKVPointer *mv_p in conMv_ps) {
        AICMVNodeBase *conMvNode = [SMGUtils searchNode:mv_p];
        if (ISOK(conMvNode, AICMVNodeBase.class)){
            [conMvs addObject:conMvNode];
        }
    }
    
    //4. 创建absCMVNode;
    AIAbsCMVNode *result = [[AIAbsCMVNode alloc] init];
    result.pointer = [SMGUtils createPointer:kPN_ABS_CMV_NODE algsType:algsType dataSource:dataSource isOut:false isMem:false];
    result.foNode_p = absFo_p;
    if (absFo_p.isMem) NSLog(@"!!!!警告,mv基本模型中,foNode在内存网络中,请检查createAbsFo()中转移是否成功;");
    
    //5. absUrgentTo
    NSInteger absUrgentTo = [AINetAbsCMVUtil getAbsUrgentTo:conMvs];
    AIPointer *urgentTo_p = [theNet getNetDataPointerWithData:@(absUrgentTo) algsType:algsType dataSource:dataSource];
    if (ISOK(urgentTo_p, AIKVPointer.class)) {
        result.urgentTo_p = (AIKVPointer*)urgentTo_p;
        [AINetUtils insertRefPorts_AllMvNode:result.pointer value_p:result.urgentTo_p difStrong:1];//引用插线
    }
    
    //6. absDelta
    NSInteger absDelta = [AINetAbsCMVUtil getAbsDelta:conMvs];
    AIPointer *delta_p = [theNet getNetDataPointerWithData:@(absDelta) algsType:algsType dataSource:dataSource];
    if (ISOK(delta_p, AIKVPointer.class)) {
        result.delta_p = (AIKVPointer*)delta_p;
        [AINetUtils insertRefPorts_AllMvNode:result.pointer value_p:result.delta_p difStrong:1];//引用插线
    }
    
    //7. 抽具象关联插线 & 存储抽具象节点;
    [AINetUtils relateMvAbs:result conNodes:conMvs];
    
    //8. 报告添加direction引用 (difStrong暂时先x2;(因为一般是两个相抽象))
    NSInteger strong = absUrgentTo;
    [theNet setMvNodeToDirectionReference:result difStrong:strong];
    return result;
}

@end
